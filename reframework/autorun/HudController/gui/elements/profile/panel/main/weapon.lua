local config = require("HudController.config.init")
local def = require("HudController.data.option.element.main.weapon")
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")

---@param elem Weapon
---@param elem_config WeaponConfig
---@param config_key string
return function(elem, elem_config, config_key)
    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_weapon_behavior"))
    util_opt.draw_apply_elem(def.opt.no_focus, ctx)
end
