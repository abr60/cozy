-- Trackpad gesture from the active Spice configuration.
hl.gesture({
  fingers = 3,
  direction = "up",
  action = function()
    hl.exec_cmd("qs ipc -c overview call overview toggle")
  end,
})

-- Keybind: Super + ` (grave)
hl.unbind("SUPER + grave")
hl.bind("SUPER + grave", hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"))