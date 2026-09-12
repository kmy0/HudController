local config = require("HudController.config.init")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")

local set = state.set

---@param elem Stamina
---@param elem_config StaminaConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_extra_bar_behavior"))
    local item_config_key = config_key .. ".children.ex.hide_pulse"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_hide_pulse", item_config_key),
            item_config_key
        ) and operations.is_current_profile(elem)
    then
        elem.children.ex:set_hide_pulse(elem_config.children.ex.hide_pulse)
    end
end
