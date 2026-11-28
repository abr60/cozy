# Theming (Cozy)

- Themes live in `$COZY_PATH/Themes/`; user overrides live in `~/.config/Cozy/themes/`.
- Commands: `cozy theme set <name>`, `cozy theme list`, `cozy theme install <name>`,
  `cozy theme bg set`, `cozy theme bg next`, `cozy font set <name>`, `cozy font list`.
- Sources are under `$COZY_PATH/bin/libexec/cozy/appearance/`; `bin/cozy` dispatches `cozy theme ...`.
- Plymouth theme: `default/plymouth/cozy/` → `/usr/share/plymouth/themes/cozy/` (installed by `install/login/plymouth.sh`).
- Limine branding: `default/limine/limine.conf` (`interface_branding: Cozy`, forest-green palette).

To add a theme: copy an existing theme dir, edit `colors.toml` / `background.jpg`, then `cozy theme set <new-name>`.
