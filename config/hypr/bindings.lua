-- Personal keybinding overrides and additions.

-- === UI ===
a.bind("SUPER + SPACE",     "Applications launcher",  "walker-launch")
a.bind("SUPER + ALT + RETURN", "Tmux",               a.launch("xdg-terminal-exec --dir=\"$(cmd-terminal-cwd)\" bash -c \"tmux attach || tmux new -s Work\""))
a.bind("XF86Favorites", "Documents", a.launch("zathura"))
a.bind("SUPER + B",        "waybar-theme",   a.launch("waybar-theme"))

-- === Apps ===
a.bind("SUPER + SHIFT + M", "Music",      "launch-tui rmpc")
a.bind("SUPER + SHIFT + D", "Git",        "launch-tui lazygit")
a.bind("SUPER + SHIFT + S", "Signal",     { launch = "signal-desktop", focus = "^signal$" })
a.bind("SUPER + SHIFT + O", "Obsidian",   a.launch("obsidian -disable-gpu --enable-wayland-ime"))
a.bind("SUPER + SHIFT + W", "Docs",       a.launch("zathura"))
a.bind("SUPER + SHIFT + SLASH", "Passwords", a.launch("keepassxc"))

-- === Tools ===
a.bind("ALT + M", "Toolbox", "[float; size 845 600] cozy-hub")
a.bind("ALT + B",     "Set wallpaper",   "rofi-set-bg")
a.bind("ALT + SPACE", "Select theme",    "rofi-set-theme")
a.bind("ALT + comma", "Unmount",         "cozy-hdd-unmount")
a.bind("ALT + Z",     "Dictation",       "voxtype record toggle")

-- === Emoji ===
hl.unbind("SUPER + CTRL + E")
hl.unbind("SUPER + period")
a.bind("SUPER + CTRL + E", "Emoji picker", "walker-launch -m symbols")
a.bind("SUPER + period",   "Emoji",        "walker-launch -m symbols")

-- === Clipboard ===
hl.unbind("SUPER + CTRL + V")
a.bind("SUPER + CTRL + V", "Clipboard history", "walker-launch -m clipboard")

-- === Special Keys ===
a.bind("XF86NotificationCenter", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })
a.bind("XF86HangupPhone", "Toggle dark/light mode", "cozy-toggle-mode") -- F11 without Fn (Fn Lock off)

-- === Hardware ===
a.bind("SUPER + M", "Comic (Latin)", "cozy-comic-translate lat")
a.bind("SUPER + N", "Comic (Asian)", "cozy-comic-translate cjk")
hl.unbind("SUPER + A")
a.bind("SUPER + A", "AI Agent", "cozy-agent")

-- === Floating TUI launchers ===
a.bind("ALT + C", "RMPC Music", "[float; center] foot --title=rmpc-full -e rmpc")
a.bind("ALT + X", "Study", "[float; size 700 200; center] foot --override=class=Yazi --title=Yazi -e timeout 30s yazi \"$HOME/media/tv/The Eminence in Shadow/Season 01/\"")

-- === Lock OSD ───────────────────────────────────────────────
a.bind("ALT + P", "Caps Lock OSD", "cozy-swayosd-lock caps", { description = "Toggle Caps Lock OSD", flags = { "l" } })
a.bind("ALT + L", "Num Lock OSD", "cozy-swayosd-lock num", { description = "Toggle Num Lock OSD", flags = { "l" } })
a.bind("ALT + K", "Scroll Lock OSD", "cozy-swayosd-lock scroll", { description = "Toggle Scroll Lock OSD", flags = { "l" } })

-- === Wifi QR popup ===
a.bind("SUPER + Q", "Wifi QR", "[float; size 336 416; move 940 45; pin] foot --title=wifi-qr -e cozy-wifi-qr")

-- === Plugin Bindings ===

-- === pickup ====

-- Answer WhatsApp Call (Focuses the specific window class, then sends Return)
--a.bind("XF86PickupPhone", "Answer WhatsApp Call", "hyprctl dispatch focuswindow class:^chrome-web\\.whatsapp\\.com__-Default$ && wtype -k Return")

-- Hang Up / Reject WhatsApp Call (Focuses the window class, then sends Escape)
--a.bind("XF86HangupPhone", "Hang Up WhatsApp Call", "hyprctl dispatch focuswindow class:^chrome-web\\.whatsapp\\.com__-Default$ && wtype -k Escape")
-- Bind SUPER + G to toggle HyprExpo using the raw legacy engine
