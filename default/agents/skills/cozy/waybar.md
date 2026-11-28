# Waybar (Cozy)

Waybar is Cozy's status bar.

- Live config: `~/.config/waybar/config.jsonc` + `style.css`
- Repo source: `$COZY_PATH/config/waybar/`
- Reload: `cozy restart waybar` (or `systemctl --user restart waybar`)
- Reset: `cozy refresh waybar`

Edit the repo source, not the live `~/.config/` copy — `update.sh` re-applies the repo version.
