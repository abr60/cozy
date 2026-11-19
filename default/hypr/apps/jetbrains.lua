-- Disable mouse focus (upstream workaround)
hl.window_rule({ no_follow_mouse = true, match = { class = "^(jetbrains-.*)$" } })
