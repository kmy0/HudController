---@class NameOtherNumberDef : ElementOptionDef<NameOther, NameOtherConfig, number>

local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type NameOtherNumberDef
        pl_draw_distance = {
            key = "pl_draw_distance",
            lang_key = "hud_element.entry.slider_pl_draw_distance",
            bindable = true,
            format = util_opt.format_disabled_number,
            draw = util_opt.slider_float(0, 50),
            apply = function(_, ctx, value)
                ctx.elem:set_pl_draw_distance(value)
            end,
        },
        ---@type NameOtherNumberDef
        pet_draw_distance = {
            key = "pet_draw_distance",
            lang_key = "hud_element.entry.slider_pet_draw_distance",
            bindable = true,
            format = util_opt.format_disabled_number,
            draw = util_opt.slider_float(0, 50),
            apply = function(_, ctx, value)
                ctx.elem:set_pet_draw_distance(value)
            end,
        },
    },
}

return this
