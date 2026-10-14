---@class ClockBooleanDef : ElementOptionDef<Clock, ClockConfig, boolean>

local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type ClockBooleanDef
        hide_map_visible = {
            key = "hide_map_visible",
            lang_key = "hud_element.entry.box_hide_map_visible",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_hide_map_visible(value)
            end,
        },
    },
}

return this
