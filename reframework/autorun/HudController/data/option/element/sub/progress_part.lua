---@class ProgressPartBaseEnabledNumberDef : ElementOptionDef<ProgressPartBase, ProgressPartBaseConfig, EnabledNumber>

local util_opt = require("HudController.data.option.util")

local draw_value = util_opt.enabled_slider(1, -1920, 1920, 1, "%.0f")

local this = {
    opt = {
        ---@type ProgressPartBaseEnabledNumberDef
        offset_x = {
            key = "offset_x",
            lang_key = "hud_element.entry.box_enable_offset_x",
            bindable = false,
            format = util_opt.format_enabled_number("%.0f"),
            draw = draw_value,
            apply = function(_, ctx, value)
                ctx.elem:set_offset_x(value)
            end,
        },
        ---@type ProgressPartBaseEnabledNumberDef
        clock_offset_x = {
            key = "clock_offset_x",
            lang_key = "hud_element.entry.box_enable_clock_offset_x",
            bindable = false,
            format = util_opt.format_enabled_number("%.0f"),
            draw = draw_value,
            apply = function(_, ctx, value)
                ctx.elem:set_clock_offset_x(value)
            end,
        },
        ---@type ProgressPartBaseEnabledNumberDef
        num_offset_x = {
            key = "num_offset_x",
            lang_key = "hud_element.entry.box_enable_num_offset_x",
            bindable = false,
            format = util_opt.format_enabled_number("%.0f"),
            draw = draw_value,
            apply = function(_, ctx, value)
                ctx.elem:set_num_offset_x(value)
            end,
        },
    },
}

return this
