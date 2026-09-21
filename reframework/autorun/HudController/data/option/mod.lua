local config = require("HudController.config.init")
local mod = require("HudController.data.mod")
local set = require("HudController.gui.set")
local util_gui = require("HudController.gui.util")
local util_opt = require("HudController.data.option.util")
local util_table = require("HudController.util.misc.table")

---@class ModOptionDefinitions
local this = {
    opt = {
        ---@type OptionDef<boolean>
        enabled = {
            config_key = "mod.enabled",
            lang_key = "menu.config.enabled",
            bindable = false,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<boolean>
        enable_fade = {
            config_key = "mod.enable_fade",
            lang_key = "menu.config.enable_fade",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<boolean>
        enable_notification = {
            config_key = "mod.enable_notification",
            lang_key = "menu.config.enable_notification",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<boolean>
        enable_key_binds = {
            config_key = "mod.enable_key_binds",
            lang_key = "menu.config.enable_key_binds",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<boolean>
        enable_condition_binds = {
            config_key = "mod.enable_condition_binds",
            lang_key = "menu.config.enable_condition_binds",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<boolean>
        disable_condition_binds_held = {
            config_key = "mod.disable_condition_binds_held",
            lang_key = "menu.config.disable_condition_binds_held",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<boolean>
        disable_condition_binds_timed = {
            config_key = "mod.disable_condition_binds_timed",
            lang_key = "menu.config.disable_condition_binds_timed",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<integer>
        disable_condition_binds_time = {
            config_key = "mod.disable_condition_binds_time",
            lang_key = "menu.config.disable_condition_binds_time",
            bindable = true,
            draw = util_opt.slider_int(1, 300),
            format = function(_, value)
                return util_gui.seconds_to_minutes_string(value, "%.0f")
            end,
        },
        ---@type OptionDef<boolean>
        block_input = {
            config_key = "mod.block_input",
            lang_key = "menu.tools.box_block_input",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },

        ---@type OptionDef<string>
        lang_file = {
            config_key = "mod.lang.file",
            lang_key = "menu.language.name",
            bindable = false,
            draw = function(_, _)
                return false
            end,
            format = util_opt.format_value,
        },
        ---@type OptionDef<boolean>
        lang_fallback = {
            config_key = "mod.lang.fallback",
            lang_key = "menu.language.fallback",
            bindable = false,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<integer>
        lang_font_size = {
            config_key = "mod.lang.font_size",
            lang_key = "menu.language.font_size.name",
            bindable = false,
            draw = function(_, label, config_key)
                return set:slider_int(util_opt.get_label(label, config_key), config_key, 8, 48)
            end,
            format = util_opt.format_value,
        },

        ---@type OptionDef<boolean>
        grid_draw = {
            config_key = "mod.grid.draw",
            lang_key = "menu.grid.box_draw",
            bindable = false,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<integer>
        grid_ratio = {
            config_key = "mod.grid.combo_grid_ratio",
            lang_key = "menu.grid.combo_ratio",
            bindable = false,
            ---@diagnostic disable-next-line: missing-fields
            combo = { values = mod.map.slider_grid_ratio } --[[@as Combo]],
            draw = util_opt.slider_list,
            format = util_opt.format_combo,
        },
        ---@type OptionDef<integer>
        grid_color_center = {
            config_key = "mod.grid.color_center",
            lang_key = "menu.grid.color_center",
            bindable = false,
            draw = util_opt.color,
            format = util_opt.format_color,
        },
        ---@type OptionDef<integer>
        grid_color_grid = {
            config_key = "mod.grid.color_grid",
            lang_key = "menu.grid.color_grid",
            bindable = false,
            draw = util_opt.color,
            format = util_opt.format_color,
        },
        ---@type OptionDef<integer>
        grid_color_fade = {
            config_key = "mod.grid.color_fade",
            lang_key = "menu.grid.color_fade",
            bindable = false,
            draw = util_opt.color,
            format = util_opt.format_color,
        },
        ---@type OptionDef<number>
        grid_fade_alpha = {
            config_key = "mod.grid.fade_alpha",
            lang_key = "menu.grid.fade_alpha",
            bindable = false,
            draw = util_opt.slider_float(0, 1),
            format = util_opt.format_number("%.2f"),
        },

        ---@type OptionDef<boolean>
        canvas_draw = {
            config_key = "mod.canvas.draw",
            lang_key = "canvas.box_draw",
            bindable = false,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        canvas_display_name = {
            config_key = "mod.canvas.display_name",
            lang_key = "canvas.box_display_name",
            bindable = false,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<boolean>
        canvas_display_value = {
            config_key = "mod.canvas.display_value",
            lang_key = "canvas.box_display_value",
            bindable = false,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<boolean>
        canvas_display_keybinds = {
            config_key = "mod.canvas.keybinds.draw",
            lang_key = "canvas.box_display_keybinds",
            bindable = false,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<boolean>
        canvas_hide_elem_disabled = {
            config_key = "mod.canvas.hide_elem_disabled",
            lang_key = "canvas.box_hide_elem_disabled",
            bindable = false,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<boolean>
        canvas_hide_elem_not_present = {
            config_key = "mod.canvas.hide_elem_not_present",
            lang_key = "canvas.box_hide_elem_not_present",
            bindable = false,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<integer>
        canvas_color_default = {
            config_key = "mod.canvas.color_default",
            lang_key = "canvas.color_default",
            bindable = false,
            draw = util_opt.color,
            format = util_opt.format_color,
        },
        ---@type OptionDef<integer>
        canvas_color_hover = {
            config_key = "mod.canvas.color_hover",
            lang_key = "canvas.color_hover",
            bindable = false,
            draw = util_opt.color,
            format = util_opt.format_color,
        },
        ---@type OptionDef<integer>
        canvas_color_select = {
            config_key = "mod.canvas.color_select",
            lang_key = "canvas.color_select",
            bindable = false,
            draw = util_opt.color,
            format = util_opt.format_color,
        },
        ---@type OptionDef<integer>
        canvas_color_outline = {
            config_key = "mod.canvas.color_outline",
            lang_key = "canvas.color_outline",
            bindable = false,
            draw = util_opt.color,
            format = util_opt.format_color,
        },
        ---@type OptionDef<integer>
        canvas_anchor_radius = {
            config_key = "mod.canvas.anchor.radius",
            lang_key = "canvas.slider_anchor_radius",
            bindable = false,
            draw = function(_, label, config_key)
                return set:slider_int(util_opt.get_label(label, config_key), config_key, 1, 40)
            end,
            format = util_opt.format_value,
        },
        ---@type OptionDef<number>
        canvas_anchor_offset_x = {
            config_key = "mod.canvas.anchor.offset_x",
            lang_key = "canvas.slider_anchor_offset_x",
            bindable = false,
            draw = function(_, label, config_key)
                return set:drag_float(
                    util_opt.get_label(label, config_key),
                    config_key,
                    0.5,
                    -1920,
                    1920
                )
            end,
            format = util_opt.format_value,
        },
        ---@type OptionDef<number>
        canvas_anchor_offset_y = {
            config_key = "mod.canvas.anchor.offset_y",
            lang_key = "canvas.slider_anchor_offset_y",
            bindable = false,
            draw = function(_, label, config_key)
                return set:drag_float(
                    util_opt.get_label(label, config_key),
                    config_key,
                    0.5,
                    -1920,
                    1920
                )
            end,
            format = util_opt.format_value,
        },
        ---@type OptionDef<integer>
        key_buffer = {
            config_key = "mod.bind.key.buffer",
            lang_key = "menu.bind.key.slider_buffer",
            bindable = false,
            draw = util_opt.slider_int(1, 11),
            format = function(_, value)
                local buffer = value - 1 --[[@as integer]]
                if buffer == 0 then
                    return config.lang:tr("misc.text_disabled")
                elseif buffer == 1 then
                    return string.format("%s %s", buffer, config.lang:tr("misc.text_frame"))
                end
                return string.format("%s %s", buffer, config.lang:tr("misc.text_frame_plural"))
            end,
        },
        ---@type OptionDef<boolean>
        condition_highlight_pass = {
            config_key = "mod.bind.condition.highlight_pass",
            lang_key = "menu.bind.condition_option.box_highlight_pass",
            bindable = false,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<boolean>
        game_options_display_full_path = {
            config_key = "mod.game_options.display_full_path",
            lang_key = "menu.user.options.box_display_full_path",
            bindable = false,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<boolean>
        hide_disabled_element_profiles = {
            config_key = "mod.hide_disabled_element_profiles",
            lang_key = "menu.config.hide_disabled_element_profiles",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        display_active_element_profile_name = {
            config_key = "mod.display_active_element_profile_name",
            lang_key = "menu.config.display_active_element_profile_name",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
    },
}

---@generic T
---@param opt OptionDef<T>
---@return T
function this.get_default(opt)
    return util_table.deep_copy(
        util_table.get_by_path(config.default, opt.config_key --[[@as string]])
    )
end

for key, opt in pairs(this.opt) do
    opt.key = key
end

return this
