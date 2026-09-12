local config = require("HudController.config.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")

local set = state.set

---@param elem NameAccess
---@param elem_config NameAccessConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_npc_behavior"))
    local item_config_key = config_key .. ".npc_draw_distance"
    local config_value = config:get(item_config_key)
    local is_current_profile = operations.is_current_profile(elem)
    if
        set:slider_float(
            util_gui.tr("hud_element.entry.slider_draw_distance"),
            item_config_key,
            0,
            50,
            (config_value == 0 and config.lang:tr("hud.option_disable")) or "%.1f"
        ) and is_current_profile
    then
        elem:set_npc_draw_distance(elem_config.npc_draw_distance)
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_hide"))
    generic.combo_hide(
        elem,
        config_key .. ".object_category",
        config.lang:tr("hud_element.entry.combo_object_category"),
        "object_category",
        elem.set_object_category,
        is_current_profile
    )

    generic.combo_hide(
        elem,
        config_key .. ".npc_type",
        config.lang:tr("hud_element.entry.combo_npc_type"),
        "npc_type",
        elem.set_npc_type,
        is_current_profile
    )

    generic.combo_hide(
        elem,
        config_key .. ".enemy_type",
        config.lang:tr("hud_element.entry.combo_enemy_type"),
        "enemy_type",
        elem.set_enemy_type,
        is_current_profile
    )

    generic.combo_hide(
        elem,
        config_key .. ".panel_type",
        config.lang:tr("hud_element.entry.combo_panel_type"),
        "panel_type",
        elem.set_panel_type,
        is_current_profile
    )

    generic.combo_hide(
        elem,
        config_key .. ".gossip_type",
        config.lang:tr("hud_element.entry.combo_gossip_type"),
        "gossip_type",
        elem.set_gossip_type,

        is_current_profile
    )
end
