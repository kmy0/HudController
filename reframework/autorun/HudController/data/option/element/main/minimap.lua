---@class MinimapIntegerDef : ElementOptionDef<Minimap, MinimapConfig, integer>
---@class MinimapBooleanDef : ElementOptionDef<Minimap, MinimapConfig, boolean>
---@class MinimapEnabledNumberDef : ElementOptionDef<Minimap, MinimapConfig, EnabledNumber>
---@class ClassicMinimapBooleanDef : ElementOptionDef<ClassicMinimap, ClassicMinimapConfig, boolean>
---@class ClassicMinimapEnabledNumberDef : ElementOptionDef<ClassicMinimap, ClassicMinimapConfig, EnabledNumber>

local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local option_gui = require("HudController.gui.option")
local set = require("HudController.gui.set")
local util_opt = require("HudController.data.option.util")

local mod = data.mod

local this = {
    opt = {
        ---@type MinimapIntegerDef
        default_filter = {
            key = "default_filter",
            lang_key = "hud_element.entry.combo_map_filter",
            bindable = true,
            draw = function(_, label, config_key)
                cd.init_combo_map_icon_filter()
                local changed = option_gui.draw_combo(
                    nil,
                    config_key,
                    util_opt.get_label(label, config_key),
                    cd.combo.map_filter
                )
                if changed then
                    config:set(config_key, mod.map.combo_map_filter[changed.key])
                    return true
                end
                return false
            end,
            format = function(_, value)
                cd.init_combo_map_icon_filter()
                for key, mapped in pairs(mod.map.combo_map_filter) do
                    if mapped == value then
                        ---@diagnostic disable-next-line: param-type-mismatch
                        local index = cd.combo.map_filter:get_index(nil, key) --[[@as integer]]
                        return cd.combo.map_filter:get_value(index)
                    end
                end
                error(string.format("Unknown map filter value: %s", tostring(value)))
            end,
            apply = function(_, ctx, value)
                ctx.elem:set_default_filter(value)
            end,
        },
        ---@type ClassicMinimapBooleanDef
        classic_minimap = {
            key = "enabled_classic_minimap",
            lang_key = "hud_element.entry.box_enable",
            bindable = true,
            format = util_opt.format_checkbox,
            draw = function(_, label, config_key)
                return set:checkbox(util_opt.get_label(label, config_key), config_key)
            end,
            apply = function(_, ctx, value)
                ctx.elem:set_enabled(value)
            end,
        },
        ---@type ClassicMinimapEnabledNumberDef
        classic_minimap_fov = {
            key = "fov_map",
            lang_key = "hud_element.entry.box_enable_map_fov",
            bindable = true,
            format = util_opt.format_enabled_number("%.2f"),
            draw = util_opt.enabled_slider(0.5, 0, 180, 0.01, "%.2f"),
            apply = function(_, ctx, value)
                ctx.elem:set_fov(value)
            end,
        },
        ---@type ClassicMinimapEnabledNumberDef
        classic_minimap_icon_scale = {
            key = "scale_icon",
            lang_key = "hud_element.entry.box_enable_icon_scale",
            bindable = true,
            format = util_opt.format_enabled_number("%.2f"),
            draw = util_opt.enabled_slider(0.01, 0, 25, 0.01, "%.2f"),
            apply = function(_, ctx, value)
                ctx.elem:set_icon_scale(value)
            end,
        },
        ---@type ClassicMinimapEnabledNumberDef
        classic_minimap_rot = {
            key = "rot_map",
            lang_key = "hud_element.entry.box_enable_rotation",
            bindable = true,
            format = util_opt.format_enabled_number("%.1f"),
            draw = util_opt.enabled_slider(0.25, 0, 360, 0.01, "%.1f"),
            apply = function(_, ctx, value)
                ctx.elem:set_rot(value)
            end,
        },
        ---@type ClassicMinimapEnabledNumberDef
        classic_minimap_angle = {
            key = "angle_map",
            lang_key = "hud_element.entry.box_enable_angle",
            bindable = true,
            format = util_opt.format_enabled_number("%.1f"),
            draw = util_opt.enabled_slider(0.1, 0, 90, 0.01, "%.1f"),
            apply = function(_, ctx, value)
                ctx.elem:set_angle(value)
            end,
        },
        ---@type ClassicMinimapBooleanDef
        hide_pl_icon_pulse = {
            key = "hide_pl_pulse",
            lang_key = "hud_element.entry.box_hide_pl_icon_pulse",
            bindable = true,
            format = util_opt.format_checkbox,
            draw = util_opt.checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_hide_pl_pulse(value)
            end,
        },
    },
}

return this
