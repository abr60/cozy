# Hyprland (Cozy)

Cozy configures Hyprland in **Lua**. User files load after Cozy's defaults.

```
~/.config/hypr/
├── hyprland.lua       # Main (loads defaults, then user files)
├── bindings.lua       # Keybindings
├── monitors.lua       # Display / monitor layout
├── input.lua          # Keyboard / mouse
├── looknfeel.lua      # Gaps, borders, animations, blur
├── autostart.lua      # Startup apps
├── hypridle.conf      # Idle daemon
├── hyprlock.conf      # Lock screen
├── hyprsunset.conf    # Night light
└── xdph.conf          # Portal / screen sharing
```

- Hyprland auto-reloads on save; force with `hyprctl reload`.
- Validate after any Lua change: `hyprctl reload && hyprctl configerrors` — fix until clean.
- Reset to Cozy defaults: `cozy refresh hyprland` (source: `bin/libexec/cozy/maintenance/refresh-hyprland`).

Repo source: `$COZY_PATH/config/hypr/` (stowed). Edit there, then `update.sh` or `install/config/dotfiles.sh` re-applies.
