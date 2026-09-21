---@class CtrlChildEnabledNumberDef : ElementOptionDef<CtrlChild, CtrlChildConfig, EnabledNumber>
---@class CtrlChildEnabledIntegerDef : ElementOptionDef<CtrlChild, CtrlChildConfig, EnabledInteger>

local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type CtrlChildEnabledNumberDef
        size_x = {
            key = "size_x",
            lang_key = "hud_element.entry.box_enable_size_x",
            bindable = true,
            format = util_opt.format_enabled_number("%.1f"),
            draw = util_opt.enabled_slider(1, -1920, 1920, 1, "%.1f"),
            apply = function(_, ctx, value)
                ctx.elem:set_size_x(value)
            end,
        },
        ---@type CtrlChildEnabledNumberDef
        size_y = {
            key = "size_y",
            lang_key = "hud_element.entry.box_enable_size_y",
            bindable = true,
            format = util_opt.format_enabled_number("%.1f"),
            draw = util_opt.enabled_slider(1, -1920, 1920, 1, "%.1f"),
            apply = function(_, ctx, value)
                ctx.elem:set_size_y(value)
            end,
        },
        ---@type CtrlChildEnabledIntegerDef
        color = {
            key = "color",
            lang_key = "hud_element.entry.color_color",
            bindable = true,
            draw = util_opt.enabled_color,
            format = util_opt.format_enabled_color,
            apply = function(_, ctx, value)
                ctx.elem:set_color(value)
            end,
        },
    },
}

return this
