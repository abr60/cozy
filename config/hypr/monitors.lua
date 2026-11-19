-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and resolutions possible: hyprctl monitors all

-- Keep the active Spice monitor scale while allowing Hyprland to detect the panel.
hl.env("GDK_SCALE", "1")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.25 })

-- Uncomment to enable a secondary HDMI monitor:
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "1280x0", scale = 1 })
