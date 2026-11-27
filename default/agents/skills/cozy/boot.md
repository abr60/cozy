# Boot Stack (Cozy)

Cozy uses a Limine + LUKS + Plymouth + Btrfs + snapper boot stack, inspired by Omarchy's mechanism but kept Cozy-branded.

## Files / ownership

- `install/login/limine.sh` — canonical boot mechanism apply script. Builds `/etc/default/limine` from `default/limine/default.conf`, deploys `default/limine/limine.conf`, installs/configures `limine`, `limine-mkinitcpio-hook`, `limine-snapper-sync`, `snapper` (btrfs root), enables `limine-snapper-sync.service`, rebuilds UKIs/entries via `limine-update`/`limine-mkinitcpio`, and carefully cleans stale archinstall Limine EFI entries only when a Limine/Cozy entry is present.
- `install/login/plymouth.sh` — installs Cozy Plymouth theme, writes `/etc/plymouth/plymouthd.conf`, maintains mkinitcpio drop-ins (`cozy_hooks.conf`, `cozy_resume.conf`), rebuilds UKIs.
- `default/limine/default.conf` — source template for `/etc/default/limine` (`@@CMDLINE@@` placeholder). Cozy-branded: `TARGET_OS_NAME=Cozy`, `CUSTOM_UKI_NAME=cozy`, snapshots enabled.
- `default/limine/limine.conf` — deployed to `/boot/limine.conf` header; boot entries are generated below it.
- `default/snapper/root` — Cozy-managed snapper root config for pre-update recovery snapshots.
- `bin/libexec/cozy/maintenance/refresh-limine` — runs canonical limine apply script.
- `bin/libexec/cozy/maintenance/refresh-plymouth` — refreshes Plymouth theme and rebuilds boot artifacts.

## Command flow

- Setup: `setup.sh` runs `login/limine.sh` then `login/plymouth.sh`.
- Update: `update.sh` runs `login/limine.sh` and `login/plymouth.sh` as part of boot stack sync.
- Manual refresh: `cozy refresh limine` / `cozy refresh plymouth` (or corresponding maintenance commands).

## Config model

- `/etc/default/limine` is the primary limine-entry-tool config generated from Cozy template.
- `/etc/limine-entry-tool.d/*.conf` drop-ins are loaded natively by limine-entry-tool; avoid appending them into `/etc/default/limine` to prevent duplicate KERNEL_CMDLINE entries.
- `/etc/kernel/cmdline` may exist for legacy/compat tooling; keep it consistent if touched.

## Snapshots

- Root btrfs systems get `snapper -c root` config from `default/snapper/root`.
- `limine-snapper-sync` is installed/enabled when available.
- Snapshot restore path remains `cozy snapshot restore` -> `limine-snapper-restore`.

## Safety

- Boot changes are risky. Test on a non-critical machine/VM first.
- Do not remove active EFI fallback entries before confirming new Limine/Cozy entry and generated boot entries.
- After changes, validate: `cat /etc/default/limine`, `cat /boot/limine.conf`, `ls /boot/EFI/Linux`, `efibootmgr -v`, `systemctl is-enabled limine-snapper-sync.service`.
