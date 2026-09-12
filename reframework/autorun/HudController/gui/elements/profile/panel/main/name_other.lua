local config = require("HudController.config.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")

local set = state.set

---@param elem NameOther
---@param elem_config NameOtherConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_pl_behavior"))
    local item_config_key = config_key .. ".pl_draw_distance"
    local config_value = config:get(item_config_key)
    local is_current_profile = operations.is_current_profile(elem)
    if
        set:slider_float(
            util_gui.tr("hud_element.entry.slider_draw_distance", item_config_key),
            item_config_key,
            0,
            50,
            (config_value == 0 and config.lang:tr("hud.option_disable")) or "%.1f"
        ) and is_current_profile
    then
        elem:set_pl_draw_distance(elem_config.pl_draw_distance)
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_pet_behavior"))
    item_config_key = config_key .. ".pet_draw_distance"
    config_value = config:get(item_config_key)
    if
        set:slider_float(
            util_gui.tr("hud_element.entry.slider_draw_distance", item_config_key),
            item_config_key,
            0,
            50,
            (config_value == 0 and config.lang:tr("hud.option_disable")) or "%.1f"
        ) and is_current_profile
    then
        elem:set_pet_draw_distance(elem_config.pet_draw_distance)
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_hide"))
    generic.combo_hide(
        elem,
        config_key .. ".nameplate_type",
        config.lang:tr("hud_element.entry.combo_nameplate_type"),
        "nameplate_type",
        elem.set_nameplate_type,

        is_current_profile
    )
end
