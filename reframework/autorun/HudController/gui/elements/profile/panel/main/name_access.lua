local config = require("HudController.config.init")
local def = require("HudController.data.option.element.main.name_access")
local generic = require("HudController.gui.elements.profile.panel.generic")
local op = require("HudController.hud.manager.op.init")
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")

---@param elem NameAccess
---@param elem_config NameAccessConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_npc_behavior"))
    local is_current_profile = op.hud_elem.is_current_profile(elem)
    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }

    util_opt.draw_apply_elem(def.opt.npc_draw_distance, ctx)

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
