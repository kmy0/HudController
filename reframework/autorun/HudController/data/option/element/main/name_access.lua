---@class NameAccessNumberDef : ElementOptionDef<NameAccess, NameAccessConfig, number>

local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type NameAccessNumberDef
        npc_draw_distance = {
            key = "npc_draw_distance",
            lang_key = "hud_element.entry.slider_npc_draw_distance",
            bindable = true,
            format = util_opt.format_disabled_number,
            draw = util_opt.slider_float(0, 50),
            apply = function(_, ctx, value)
                ctx.elem:set_npc_draw_distance(value)
            end,
        },
    },
}

return this
