# Low-Battery Hook (`persistent-nag`)

Cozy's `battery-monitor.timer` checks the battery every 30 seconds. When the
battery first reaches 10% while discharging, it calls:

```bash
hook battery-low "$capacity"
```

The `persistent-nag` hook (ported from Omarchy's
`config/omarchy/hooks/battery-low.d/persistent-nag`) keeps nagging until the
charger is connected:

- plays `low-battery.wav` on the initial alert and on every further drop
- at 5% and below, dims the display to 5% and sends a critical notification
- restores the original brightness and stops as soon as the laptop is plugged in

## Install

The hook source lives in the repo at:

```text
install/hooks/battery-low/persistent-nag
```

`install/hardware/battery-low-hook.sh` copies it to:

```text
~/.config/Cozy/hooks/battery-low.d/persistent-nag
```

and enables `battery-monitor.timer`. The installer is wired into `setup.sh`
and `update.sh`. Run it manually with:

```bash
bash ~/.local/share/Cozy/install/hardware/battery-low-hook.sh
```

No root privileges are needed; this is a per-user hook.

## Why the timer service uses `KillMode=process`

The hook starts a detached loop so it can keep polling the battery. Cozy's
`battery-monitor.service` is a oneshot unit, so its default `KillMode` would
terminate that loop as soon as the 30-second check exits. The service sets:

```ini
KillMode=process
```

so the nag loop survives, while the next timer tick sees the existing PID and
does not start a second loop.

## Verify

```bash
# Installed?
ls -l ~/.config/Cozy/hooks/battery-low.d/persistent-nag

# Timer active?
systemctl --user status battery-monitor.timer

# Run the hook manually (starts a nag loop; plug in to stop it)
hook battery-low 10
pgrep -af 'persistent-nag|cozy-battery-nag'
```

When plugged in, the loop exits within 30 seconds and restores brightness.

## Troubleshooting

| Symptom | Check |
|---|---|
| No sound at 10% | `pactl info`, `pw-play ~/.config/hypr/assets/sounds/low-battery.wav` |
| Hook never runs | `systemctl --user list-timers battery-monitor.timer`, `systemctl --user status battery-monitor.service` |
| Nag loop dies immediately | Confirm `KillMode=process` is in `~/.config/systemd/user/battery-monitor.service`; run `systemctl --user daemon-reload` |
| Brightness not restored | `brightnessctl -m`; check `$XDG_RUNTIME_DIR/cozy-battery-nag-brightness` |
| Duplicate low-battery alerts | `cozy-battery-monitor` should only handle plug/unplug sounds and power profiles; it no longer nags below 5% |

## Uninstall

```bash
rm -f ~/.config/Cozy/hooks/battery-low.d/persistent-nag
```
