---@class NameAccessNumberDef : ElementOptionDef<NameAccess, NameAccessConfig, number>
---@class NameAccessBooleanDef : ElementOptionDef<NameAccess, NameAccessConfig, boolean>

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
        ---@type NameAccessBooleanDef
        hide_edge_icon = {
            key = "hide_edge_icon",
            lang_key = "hud_element.entry.box_hide_edge_icon",
            bindable = true,
            format = util_opt.format_checkbox,
            draw = util_opt.checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_hide_edge_icon(value)
            end,
        },
    },
}

return this
