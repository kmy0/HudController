---@class (exact) GuiSettings : SettingsBase
---@field gui WindowSettings

---@class (exact) WindowSettings
---@field main WindowState
---@field debug WindowState

---@class (exact) WindowState
---@field pos_x integer
---@field pos_y integer
---@field size_x integer
---@field size_y integer
---@field is_opened boolean

---@class GuiConfig : ConfigBase
---@field current GuiSettings
---@field default GuiSettings

local config_base = require("HudController.util.misc.config")

local this = {}
---@type GuiSettings
local default = {
    gui = {
        main = {
            pos_x = 50,
            pos_y = 50,
            size_x = 800,
            size_y = 700,
            is_opened = false,
        },
        debug = {
            pos_x = 50,
            pos_y = 50,
            size_x = 800,
            size_y = 700,
            is_opened = false,
        },
    },
}

---@return GuiConfig
function this.new(path)
    return config_base:new(default, path) --[[@as GuiConfig]]
end

return this
