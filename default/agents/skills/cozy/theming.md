# Theming (Cozy)

- Themes live in `$COZY_PATH/themes/` and `~/.config/Cozy/themes/` (user overrides).
- Commands: `theme-set <name>`, `theme-list`, `theme-install`, `theme-bg-set`, `theme-bg-next`, `font-set`, `font-list`.
- `bin/theme-*` and `bin/theme-bg-*` are the source; `bin/cozy` dispatches `cozy theme ...`.
- Plymouth theme: `default/plymouth/cozy/` → `/usr/share/plymouth/themes/cozy/` (installed by `install/login/plymouth.sh`).
- Limine branding: `default/limine/limine.conf` (`interface_branding: Cozy`, forest-green palette).

To add a theme: copy an existing theme dir, edit `colors.toml` / `background.jpg`, then `theme-set <new-name>`.
