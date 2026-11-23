# Cozy Menu (Walker)

Cozy's menu is `bin/menu` (Walker dmenu). `bin/menu` is a symlink to `bin/libexec/cozy/desktop/menu`. Dispatcher is `bin/cozy` (routes `cozy <group> <action>` → `bin/cozy-*` / `bin/cozy-*`).

```
bin/menu
├── show_main_menu        → Apps / Learn / Trigger / Style / Setup / Install / Remove / Update / About / System
├── show_setup_menu       → Audio / Wifi / Bluetooth / Power / Monitors / Keybindings / Input / Defaults / DNS / Security / Config
│   └── show_setup_config_menu → Hyprland / Hypridle / Hyprlock / Hyprsunset / Swayosd / Waybar / Rofi / Walker / XCompose
│   └── show_setup_default_menu → Browser / Terminal / Editor
├── show_install_menu     → Package / AUR / Web App / TUI / Service / Style / Development / Editor / Terminal / Browser / AI / Gaming / Windows
│   └── show_install_ai_menu → Dictation / LM Studio / Ollama / Coding Agents (OpenCode, Crush, Gemini CLI, Qwen Code, Grok CLI) + AI Web Apps (ChatGPT, Claude, Gemini, Grok, DeepSeek, Mistral, NotebookLM)
├── show_trigger_menu / show_style_menu / show_update_menu / show_system_menu / ...
└── go_to_menu           (direct jump: `menu Install`, `menu Setup`, etc.)
```

- Edit: `$COZY_PATH/bin/libexec/cozy/desktop/menu` (`bin/menu` is a symlink). Add submenus as `show_*_menu()` functions, wire in `show_install_menu` / `go_to_menu` / `show_main_menu`.
- Helpers: `menu()`, `present_terminal()`, `install()`, `open_in_editor()`, `hypr_config_file()`.
- Menu UI: `bin/walker-dmenu` wraps Walker dmenu on a private D-Bus session. Use it for every dmenu call; Walker 2.17.x segfaults when its long-running service handles `--dmenu`.
- Launcher/provider menus: `bin/walker-launch` (`-m menus:cozythemes`, `-m menus:cozybackgrounds`, etc.).
- Rofi is still installed for `rofi-powermenu`, `rofi-emoji`, `cliphist-rofi`, and `rofi-applications`; the Cozy menu itself is Walker.
- User extensions: `~/.config/Cozy/extensions/menu.sh` (sourced at end of `bin/menu`).
- Install helpers: `bin/webapp-install`, `bin/webapp-remove`, `bin/tui-install`, `bin/pkg-add`, `bin/install-*`, `bin/cozy-voxtype-*`.
- Webapps: `applications/Webapps/*.desktop` + `applications/icons/*.png` → `~/.local/share/applications/` (via `install/config/applications.sh` + `bin/refresh-applications`).
