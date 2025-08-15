---@class (exact) DebugSettings : SettingsBase
---@field debug {
--- show_disabled: boolean,
--- is_filter :boolean,
--- is_debug: boolean,
--- }

---@class DebugConfig : ConfigBase
---@field current DebugSettings
---@field default DebugSettings

local config_base = require("HudController.util.misc.config")

local this = {}
local default = {
    debug = {
        show_disabled = false,
        is_filter = false,
        is_debug = false,
    },
}

---@return DebugConfig
function this.new(path)
    return config_base:new(default, path) --[[@as DebugConfig]]
end

return this
