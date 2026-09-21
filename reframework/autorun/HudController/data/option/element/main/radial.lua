---@class RadialBooleanDef : ElementOptionDef<Radial, RadialConfig, boolean>
---@class RadialPalletBooleanDef : ElementOptionDef<RadialPallet, RadialPalletConfig, boolean>

local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type RadialBooleanDef
        expanded = {
            key = "expanded",
            lang_key = "hud_element.entry.box_radial_always_expanded",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_expanded(value)
            end,
        },
        ---@type RadialPalletBooleanDef
        pallet_expanded = {
            key = "expanded",
            lang_key = "hud_element.entry.box_pallet_always_expanded",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_expanded(value)
            end,
        },
    },
}

return this
