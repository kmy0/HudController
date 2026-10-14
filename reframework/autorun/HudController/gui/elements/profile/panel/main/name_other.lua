local config = require("HudController.config.init")
local def = require("HudController.data.option.element.main.name_other")
local generic = require("HudController.gui.elements.profile.panel.generic")
local op = require("HudController.hud.manager.op.init")
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")

---@param elem NameOther
---@param elem_config NameOtherConfig
---@param config_key string
return function(elem, elem_config, config_key)
    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_pl_behavior"))
    util_opt.draw_apply_elem(def.opt.pl_draw_distance, ctx)

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_pet_behavior"))
    util_opt.draw_apply_elem(def.opt.pet_draw_distance, ctx)

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_hide"))
    generic.combo_hide(
        elem,
        config_key .. ".nameplate_type",
        config.lang:tr("hud_element.entry.combo_nameplate_type"),
        "nameplate_type",
        elem.set_nameplate_type,
        op.hud_elem.is_current_profile(elem)
    )
end
