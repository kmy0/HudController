local config = require("HudController.config.init")
local option_gui = require("HudController.gui.option")

local this = {}

---@param bind ModBind
---@return string
function this.get_action_name(bind)
    local action = bind.action_type
    if action == "NONE" then
        action = "SET"
    end

    return string.format("[%s]", config.lang:tr("menu.bind.key.action_type." .. action))
end

---@param bind ModBind
---@return string
function this.get_trigger_name(bind)
    return string.format(
        "[%s]",
        config.lang:tr(
            "menu.bind.key.trigger_type." .. (bind.trigger_repeat and "REPEAT" or "ONCE")
        )
    )
end

---@param bind ModBind
---@return string
function this.get_key_bind_name(bind)
    return string.format("[%s]", bind.name_display)
end

---@param draw_fn fun(): boolean
function this.draw_option(draw_fn)
    if type(config:get("__temp.option_value")) == "boolean" then
        return option_gui.draw_bool_slider(nil, "__temp.option_value")
    end

    return draw_fn()
end

return this
