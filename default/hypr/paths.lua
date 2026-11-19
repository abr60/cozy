-- Shared path constants for Cozy's Hyprland Lua modules.
-- Lua files loaded with require() have separate local scopes, so modules that
-- need these paths import this table instead of repeating os.getenv() lookups.

local home = os.getenv("HOME")

return {
  home        = home,
  config_home = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config"),
  state_home  = os.getenv("XDG_STATE_HOME")  or (home .. "/.local/state"),
  cozy_path   = os.getenv("COZY_PATH") or os.getenv("COZY_DIR") or (home .. "/.local/share/Cozy"),
}
