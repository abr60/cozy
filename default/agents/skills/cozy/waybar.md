# Waybar (Cozy)

Waybar is Cozy's status bar (Cozy uses Waybar rather than Quickshell/cozy-shell).

- Live config: `~/.config/waybar/config.jsonc` + `style.css`
- Repo source: `~/Cozy/config/waybar/`
- Reload: `restart-waybar` or `systemctl --user restart waybar` (or `cozy restart waybar` if wrapped)
- Reset: `refresh-waybar`

Edit the repo, not the live `~/.config/` copy directly — `update.sh` overwrites it.
