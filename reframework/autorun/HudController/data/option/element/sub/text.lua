---@class TextEnabledNumberDef : ElementOptionDef<Text, TextConfig, EnabledNumber>
---@class TextEnabledStringDef : ElementOptionDef<Text, TextConfig, EnabledString>
---@class TextBooleanDef : ElementOptionDef<Text, TextConfig, boolean>
---@class TextEnabledIntegerDef : ElementOptionDef<Text, TextConfig, EnabledInteger>

local cd = require("HudController.data.combo")
local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type TextEnabledIntegerDef
        font_size = {
            key = "font_size",
            lang_key = "hud_element.entry.box_enable_font_size",
            bindable = true,
            format = util_opt.format_enabled_number("%.1f"),
            draw = util_opt.enabled_slider(0.1, 0, 1000, 0.1, "%.1f"),
            apply = function(_, ctx, value)
                ctx.elem:set_font_size(value)
            end,
        },
        ---@type TextEnabledStringDef
        page_alignment = {
            key = "page_alignment",
            lang_key = "hud_element.entry.box_enable_page_alignment",
            bindable = true,
            format = util_opt.format_enabled_value,
            draw = util_opt.enabled_combo(function()
                return cd.combo.page_alignment
            end),
            apply = function(_, ctx, value)
                ctx.elem:set_page_alignment(value)
            end,
        },
        ---@type TextBooleanDef
        hide_glow = {
            key = "hide_glow",
            lang_key = "hud_element.entry.box_hide_glow",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_hide_glow(value)
            end,
        },
        ---@type TextEnabledIntegerDef
        glow_color = {
            key = "glow_color",
            lang_key = "hud_element.entry.color_glow",
            bindable = true,
            draw = util_opt.enabled_color,
            format = util_opt.format_enabled_color,
            apply = function(_, ctx, value)
                ctx.elem:set_glow_color(value)
            end,
        },
    },
}

return this
