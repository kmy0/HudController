local config = require("HudController.config.init")
local option_gui = require("HudController.gui.option")

local this = {}

---@param config_key string
---@param draw_fn fun(): boolean
function this.draw_option(config_key, draw_fn)
    if type(config:get(config_key)) == "boolean" then
        return option_gui.draw_bool_slider(nil, config_key)
    end

    return draw_fn()
end

return this
