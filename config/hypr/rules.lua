-- Personal window and layer rules.

-- === Layer Rules ===

hl.layer_rule({ blur = true,        match = { namespace = "rofi" } })
hl.layer_rule({ ignore_alpha = 0,   match = { namespace = "rofi" } })

hl.layer_rule({ blur = true,        match = { namespace = "waybar" } })
hl.layer_rule({ ignore_alpha = 0.1, match = { namespace = "waybar" } })

hl.layer_rule({ blur = true,        match = { namespace = "^(notifications|swaync-control-center)$" } })
hl.layer_rule({ ignore_alpha = 0.1, match = { namespace = "^(notifications|swaync-control-center)$" } })

hl.layer_rule({ blur = true,        match = { namespace = "vicinae" } })
hl.layer_rule({ ignore_alpha = 0.1, match = { namespace = "vicinae" } })

hl.layer_rule({ blur = true,        match = { namespace = "^quickshell:overview(-blur)?$" } })
hl.layer_rule({ ignore_alpha = 0.2, match = { namespace = "^quickshell:overview(-blur)?$" } })

--hl.layer_rule({ blur = true,        match = { namespace = "swayosd" } })

-- === Window Rules ===

-- Waydroid (fullscreen)
hl.window_rule({ fullscreen = true, match = { class = "^(Waydroid)$" } })

-- Yazi floating file picker
hl.window_rule({ float = true,      match = { class = "^(foot)$", title = "^(Yazi)$" } })
hl.window_rule({ size = "700 200",  match = { class = "^(foot)$", title = "^(Yazi)$" } })
hl.window_rule({ center = true,     match = { class = "^(foot)$", title = "^(Yazi)$" } })

-- Media download float
hl.window_rule({ float = true,      match = { class = "^(foot)$", title = "^(media-download)$" } })
hl.window_rule({ size = "900 400",  match = { class = "^(foot)$", title = "^(media-download)$" } })
hl.window_rule({ center = true,     match = { class = "^(foot)$", title = "^(media-download)$" } })

-- rmpc TUI
hl.window_rule({ float = true,      match = { class = "^(foot)$", title = "^(rmpc)$" } })
hl.window_rule({ size = "449 520",  match = { class = "^(foot)$", title = "^(rmpc)$" } })
hl.window_rule({ move = "3 46",    match = { class = "^(foot)$", title = "^(rmpc)$" } })
hl.window_rule({ pin = true,        match = { class = "^(foot)$", title = "^(rmpc)$" } })

-- Wifi QR popup
hl.window_rule({ float = true,      match = { class = "^(foot)$", title = "^(wifi-qr)$" } })
hl.window_rule({ size = "336 416",  match = { class = "^(foot)$", title = "^(wifi-qr)$" } })
hl.window_rule({ move = "940 45",   match = { class = "^(foot)$", title = "^(wifi-qr)$" } })
hl.window_rule({ pin = true,        match = { class = "^(foot)$", title = "^(wifi-qr)$" } })

-- Bluetui + Impala dropdown
hl.window_rule({ float = true,      match = { class = "^(foot)$", title = "^(dropdown)$" } })
hl.window_rule({ size = "620 400",  match = { class = "^(foot)$", title = "^(dropdown)$" } })
hl.window_rule({ move = "818 368",   match = { class = "^(foot)$", title = "^(dropdown)$" } })
hl.window_rule({ pin = true,        match = { class = "^(foot)$", title = "^(dropdown)$" } })

-- Cozy floating terminal (update, post-install etc.)
hl.window_rule({ float = true,       match = { class = "org.cozy.terminal" } })
hl.window_rule({ size = "800 600",   match = { class = "org.cozy.terminal" } })
hl.window_rule({ center = true,      match = { class = "org.cozy.terminal" } })

-- Scroll sensitivity per terminal
hl.window_rule({ scroll_touchpad = 0.2, match = { class = "^(foot)$" } })

-- rmpc keybind (large centered)
hl.window_rule({ float = true,     match = { class = "^(foot)$", title = "^(rmpc-full)$" } })
hl.window_rule({ size = "900 600", match = { class = "^(foot)$", title = "^(rmpc-full)$" } })
hl.window_rule({ center = true,    match = { class = "^(foot)$", title = "^(rmpc-full)$" } })

-- Cava desktop visualizer
hl.window_rule({ float = true,      match = { class = "^(cava-desktop)$" } })
hl.window_rule({ no_focus = true,   match = { class = "^(cava-desktop)$" } })
hl.window_rule({ pin = true,        match = { class = "^(cava-desktop)$" } })
hl.window_rule({ move = "0 640",    match = { class = "^(cava-desktop)$" } })
hl.window_rule({ size = "1280 80",  match = { class = "^(cava-desktop)$" } })
hl.window_rule({ opacity = "1.0",   match = { class = "^(cava-desktop)$" } })


hl.window_rule({ float = true, match = { class = "^(audacious)$" } })
hl.window_rule({ move = "16 450", match = { class = "^(audacious)$" } })
hl.window_rule({ size = "500 300", match = { class = "^(audacious)$" } })