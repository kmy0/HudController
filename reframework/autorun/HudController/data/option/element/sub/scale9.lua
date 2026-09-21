---@class Scale9EnabledStringDef : ElementOptionDef<Scale9, Scale9Config, EnabledString>
---@class Scale9BooleanDef : ElementOptionDef<Scale9, Scale9Config, boolean>

local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local option_gui = require("HudController.gui.option")
local util_opt = require("HudController.data.option.util")

local function draw_combo(label, config_key, combo)
    local value_key = config_key .. ".value"
    local changed = option_gui.draw_combo(
        { config_key = config_key .. ".enabled" },
        value_key,
        util_opt.get_label(label, value_key),
        combo,
        ---@diagnostic disable-next-line: param-type-mismatch
        combo:get_index(nil, config:get(value_key))
    )
    if changed then
        config:set(value_key, changed.value)
        return true
    end
    return false
end

local this = {
    opt = {
        ---@type Scale9EnabledStringDef
        control_point = {
            key = "control_point",
            lang_key = "hud_element.entry.box_enable_scale9_control_point",
            bindable = true,
            format = util_opt.format_enabled_value,
            draw = function(_, label, config_key)
                return draw_combo(label, config_key, cd.combo.control_point)
            end,
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
            draw = function(_, label, config_key)
                return draw_combo(label, config_key, cd.combo.blend)
            end,
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
            draw = function(_, label, config_key)
                return draw_combo(label, config_key, cd.combo.alpha_channel)
            end,
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
