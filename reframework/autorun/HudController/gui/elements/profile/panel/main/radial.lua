local config = require("HudController.config.init")
local def = require("HudController.data.option.element.main.radial")
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")

---@param elem Radial
---@param elem_config RadialConfig
---@param config_key string
return function(elem, elem_config, config_key)
    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }
    local pallet_ctx = util_opt.resolve_elem_ctx(ctx, "children.pallet") --[[@as  ElementOptionContext<RadialPallet, RadialPalletConfig>]]

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_radial_behavior"))
    util_opt.draw_apply_elem(def.opt.expanded, ctx)

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_pallet_behavior"))
    util_opt.draw_apply_elem(def.opt.pallet_expanded, pallet_ctx)
end
