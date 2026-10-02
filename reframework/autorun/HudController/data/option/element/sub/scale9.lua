---@class Scale9EnabledStringDef : ElementOptionDef<Scale9, Scale9Config, EnabledString>
---@class Scale9BooleanDef : ElementOptionDef<Scale9, Scale9Config, boolean>

local cd = require("HudController.data.combo")
local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type Scale9EnabledStringDef
        control_point = {
            key = "control_point",
            lang_key = "hud_element.entry.box_enable_scale9_control_point",
            bindable = true,
            format = util_opt.format_enabled_value,
            draw = util_opt.enabled_combo(function()
                return cd.combo.control_point
            end),
            apply = function(_, ctx, value)
                ctx.elem:set_control_point(value)
            end,
        },
        ---@type Scale9EnabledStringDef
        blend = {
            key = "blend",
            lang_key = "hud_element.entry.box_enable_scale9_blend_type",
            bindable = true,
            format = util_opt.format_enabled_value,
            draw = util_opt.enabled_combo(function()
                return cd.combo.blend
            end),
            apply = function(_, ctx, value)
                ctx.elem:set_blend(value)
            end,
        },
        ---@type Scale9EnabledStringDef
        alpha_channel = {
            key = "alpha_channel",
            lang_key = "hud_element.entry.box_enable_scale9_alpha_channel",
            bindable = true,
            format = util_opt.format_enabled_value,
            draw = util_opt.enabled_combo(function()
                return cd.combo.alpha_channel
            end),
            apply = function(_, ctx, value)
                ctx.elem:set_alpha_channel(value)
            end,
        },
        ---@type Scale9BooleanDef
        ignore_alpha = {
            key = "ignore_alpha",
            lang_key = "hud_element.entry.box_enable_scale9_ignore_alpha",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_ignore_alpha(value)
            end,
        },
    },
}

return this
