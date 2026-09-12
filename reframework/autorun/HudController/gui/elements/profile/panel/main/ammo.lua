local config = require("HudController.config.init")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")

local set = state.set

---@param elem Ammo
---@param elem_config AmmoConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_parts_behavior"))
    local item_config_key = config_key .. ".no_hide_parts"
    if
        set:checkbox(util_gui.tr("hud_element.entry.box_no_hide", item_config_key), item_config_key)
        and operations.is_current_profile(elem)
    then
        elem:set_no_hide_parts(elem_config.no_hide_parts)
    end
end
