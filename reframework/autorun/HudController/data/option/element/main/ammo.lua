---@class AmmoBooleanDef : ElementOptionDef<Ammo, AmmoConfig, boolean>

local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type AmmoBooleanDef
        no_hide_parts = {
            key = "no_hide_parts",
            lang_key = "hud_element.entry.box_no_hide",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_no_hide_parts(value)
            end,
        },
    },
}

return this
