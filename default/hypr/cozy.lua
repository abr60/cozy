-- Cozy Hyprland setup: helpers, defaults, and current theme overrides.

require("default.hypr.helpers")

-- Use Cozy defaults, but don't edit these directly.
require("default.hypr.autostart")
require("default.hypr.bindings")
require("default.hypr.bindings.media")
require("default.hypr.bindings.clipboard")
require("default.hypr.bindings.tiling")
require("default.hypr.bindings.utilities")
require("default.hypr.bindings.webapps")
require("default.hypr.envs")
require("default.hypr.looknfeel")
require("default.hypr.input")
require("default.hypr.windows")

-- Current theme overrides.
do
  local paths = require("default.hypr.paths")
  local themes = {
    paths.config_home .. "/Cozy/current/theme/hyprland.lua",
  }
  for _, theme_path in ipairs(themes) do
    local theme = io.open(theme_path, "r")
    if theme then
      theme:close()
      dofile(theme_path)
      break
    end
  end
end