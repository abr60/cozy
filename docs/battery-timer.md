# Battery / Screen-Time Timer (`bat-screentime`)

Tracks how long the laptop has actually been awake and screen-on since the
last time it was unplugged from AC/USB-C power, excluding `s2idle` suspend
and display-off time.

For low-battery nagging, see [`battery-low-hook.md`](battery-low-hook.md).

When a charger is connected, it reports the **last completed discharge
session** instead of an ever-growing timer.

## What it reports

```
Session            : active
Unplugged at       : 2026-11-21 08:09:05 +0600
Source             : power log
Elapsed            : 3h 12m 05s
Asleep (s2idle)    : 45m 02s  (2 cycles)
Screen off (awake) : 12m 10s
Screen-on time     : 2h 14m 53s
  Idle, screen on  : 18m 04s
  Active usage     : 1h 56m 49s
Battery            : 27% · 45.5 W · Charging (BAT0)
```

- **Screen-on time** = elapsed − union(suspend, display-off).
- **Idle, screen on** = screen-on while no input activity.
- **Active usage** = screen-on − idle-on-screen.

These are wall-clock approximations. “Active” means Hyprland saw input
activity; it is not per-application usage.

## Install

The installer is idempotent and is wired into `setup.sh` and `update.sh`.

```bash
# from the Cozy repo
bash ~/.local/share/Cozy/install/system/battery-timer.sh
```

It installs:

| Path | Purpose |
|---|---|
| `/usr/local/bin/bat-screentime-hook` | root-owned udev + hypridle hook |
| `/etc/udev/rules.d/99-battery-timer.rules` | watches all `power_supply` changes |
| group `powerread` + ACLs on `/var/lib/upower` | read-only history fallback |
| `bin/bat-screentime` | user-facing CLI (symlink into the Cozy repo) |

The CLI itself stays user-owned inside the repo:

```text
bin/bat-screentime -> libexec/cozy/system/bat-screentime
```

After install, run:

```bash
bat-screentime
```

The installer also adds an explicit user ACL, so the history fallback works
immediately. Membership in `powerread` takes effect on the next login and is
there for group-based tools.

## How it works

### Power state

`udev` calls the hook on every `power_supply` change. The hook checks **all**
`Mains` and `USB` supplies, ignoring `scope=Device` USB ports, so the laptop
counts as plugged while *any* system power source is online. This matters on
the T14 because the barrel AC adapter and USB-C PD are separate supplies.

On an offline edge it writes:

- the epoch to `/var/tmp/unplugged_at`
- `<ts> offline <capacity>` to `/var/tmp/bat-screentime-power.log`

On an online edge it writes `<ts> online <capacity>` and removes
`unplugged_at`. `/var/tmp` persists across reboots.

### Suspend

The CLI reads `journalctl` since the unplug time and pairs:

- `systemd-logind[...]: Suspending...`
- `systemd-sleep[...]: System returned from sleep operation 'suspend'.`

Unmatched wakes are ignored; an unmatched start at query time counts up to
“now” and is reported as `suspended now`.

Persistent journal is recommended for cross-boot accuracy:

```bash
sudo mkdir -p /var/log/journal
sudo systemd-tmpfiles --create --prefix /var/log/journal
```

On Cozy, `/var/log/journal` already exists.

### Screen off / idle

`hypridle` writes to `/var/tmp/bat-screentime-idle.log`:

- `idle-start` / `idle-end` at 120s (screen on, no input)
- `screen-off` / `screen-on` around the existing 300s lock listener
- `screen-on` / `idle-end` after resume, so an interval opened before suspend
  is closed even if Hyprland does not deliver a normal resume event

The lock listener still calls `system-lock` / `system-wake`; the hook is
best-effort and must not prevent locking. The 300s listener turns the display
off via the existing `system-lock` path (`brightness-display off`).

### Fallback history

If there is no `unplugged_at` yet (before the udev rule was installed), the
CLI reads `/var/lib/upower/history-charge-*.dat`. It picks the file matching
`BAT0`’s `model_name` (or the largest file), sorts rows by epoch, and finds
the last `discharging → charging` transition. Rows are not chronological in
the file, so sorting is required.

The ACL grant makes this work without `sudo`; the default ACL on
`/var/lib/upower` covers files UPower creates later.

## Verify

```bash
# current power sources
for d in /sys/class/power_supply/*; do
  printf '%s type=%s online=%s\n' "$d" "$(cat "$d/type")" "$(cat "$d/online" 2>/dev/null || echo -)"
done

# watch live events while unplugging/plugging
udevadm monitor --property --subsystem-match=power_supply

# after an unplug
cat /var/tmp/unplugged_at
cat /var/tmp/bat-screentime-power.log

# after idle/lock
cat /var/tmp/bat-screentime-idle.log

# suspend accounting
journalctl -o short-unix | grep -E "Suspending\.\.\.|returned from sleep"
```

## Troubleshooting

| Symptom | Check |
|---|---|
| `No unplug session found` | udev rule installed? `udevadm control --reload-rules`; check `/var/tmp/bat-screentime-power.log`. |
| Timer doesn’t reset on plug | Hook must see **all** supplies offline. USB-C PD still online counts as plugged. |
| Screen-on equals elapsed | `hypridle` not running or idle listeners not loaded: `pgrep -x hypridle`, `restart-hypridle`. |
| Suspend time missing | Journal access or persistence: `journalctl --list-boots`, check for `not seeing messages`. |
| UPower fallback permission denied | Re-run installer; verify `getfacl /var/lib/upower` shows your user/group ACL. |
| `bat-screentime` not found | `~/.local/share/Cozy/bin` must be on `PATH`; open a new shell. |

## Uninstall

```bash
sudo rm -f /etc/udev/rules.d/99-battery-timer.rules /usr/local/bin/bat-screentime-hook
sudo udevadm control --reload-rules
sudo setfacl -x g:powerread /var/lib/upower
sudo setfacl -d -x g:powerread /var/lib/upower
sudo setfacl -x g:powerread /var/lib/upower/history-charge-*.dat
rm -f /var/tmp/unplugged_at /var/tmp/bat-screentime-*.log /var/tmp/bat-screentime-power-state
# remove the idle/screen listeners from config/hypr/hypridle.conf
```

The `powerread` group can be left in place safely.
