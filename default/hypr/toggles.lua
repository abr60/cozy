-- Toggle config flags dynamically.
-- Files in this directory are toggled on/off by Cozy scripts.

local paths     = require("default.hypr.paths")
local require_all = require("default.hypr.require_all")

require_all.files(paths.cozy_path .. "/default/hypr/toggles",       "default.hypr.toggles")
require_all.files(paths.state_home  .. "/Cozy/toggles/hypr",      nil)
