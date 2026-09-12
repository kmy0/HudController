local config = require("HudController.config.init")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")

local set = state.set

---@param elem Radial
---@param elem_config RadialConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_radial_behavior"))
    local item_config_key = config_key .. ".expanded"
    local is_current_profile = operations.is_current_profile(elem)
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_always_expanded", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem:set_expanded(elem_config.expanded)
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_pallet_behavior"))
    item_config_key = config_key .. ".children.pallet.expanded"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_always_expanded", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem.children.pallet:set_expanded(elem_config.children.pallet.expanded)
    end
end
