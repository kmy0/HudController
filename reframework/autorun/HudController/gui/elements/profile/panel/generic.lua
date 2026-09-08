local ace_misc = require("HudController.util.ace.misc")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local hud = require("HudController.hud.init")
local mod = require("HudController.data.mod")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")

local ace_map = data.ace.map
local set = state.set

local this = {}

---@param option_keys string[]
---@param config_key string
---@param callback (fun(option_key: string, option_config_key: string))?
function this.draw_options(option_keys, config_key, callback)
    for i = 1, #option_keys do
        local key = option_keys[i]
        local option_data = ace_map.option[key]
        local option_config_key = string.format("%s.%s", config_key, key)
        local config_value = config:get(option_config_key)

        if
            set:slider_int(
                option_data.name_local,
                option_config_key,
                -1,
                #option_data.items - 1,
                (config_value == -1 and config.lang:tr("hud.option_disable"))
                    or option_data.items[config_value + 1].name_local
            ) and callback
        then
            callback(key, option_config_key)
        end
    end
end

---@param checkbox {config_key: string, label: string?}?
---@param sliders {config_key: string, label: string?}[]
---@param speed number
---@param min number
---@param max number
---@param step number
---@param format string
---@param label string?
---@param additional_text string?
---@return boolean
function this.draw_slider_settings(
    checkbox,
    sliders,
    speed,
    min,
    max,
    step,
    format,
    label,
    additional_text
)
    local changed = false
    local disabled = false
    if checkbox then
        changed = set:checkbox(
            string.format("%s##%s", checkbox.label or "", checkbox.config_key),
            checkbox.config_key
        )
        disabled = not config:get(checkbox.config_key)
        imgui.same_line()
        imgui.begin_disabled(disabled)
    else
        imgui.begin_disabled(false)
    end

    local button_size = config.lang.font_size + 6
    local drag_with = imgui.calc_item_width() / #sliders - button_size * 2 - (#sliders - 1) * 4
    local decimals = tonumber(format:match("%.(%d+)f")) --[[@as number]]
    local border_color = 0xff4f4e4d
    border_color = not disabled and border_color or util_misc.mul_alpha(border_color, 0.6)
    for i = 1, #sliders do
        local slider = sliders[i]
        imgui.push_style_var(14, Vector2f.new(0, 4))
        util_imgui.with_border(function()
            if
                imgui.button("-##button_minus_" .. slider.config_key, { button_size, button_size })
            then
                changed = true
                local val = math.max(config:get(slider.config_key) - step, min)
                config:set(slider.config_key, util_misc.round(val, decimals))
            end
        end, button_size, button_size, border_color)

        imgui.same_line()
        imgui.set_next_item_width(drag_with)
        changed = set:drag_float(
            string.format("%s##%s", slider.label or "", slider.config_key),
            slider.config_key,
            speed,
            min,
            max,
            format
        ) or changed

        imgui.same_line()

        util_imgui.with_border(function()
            if
                imgui.button("+##button_plus_" .. slider.config_key, { button_size, button_size })
            then
                changed = true
                local val = math.min(config:get(slider.config_key) + step, max)
                config:set(slider.config_key, util_misc.round(val, decimals))
            end
        end, button_size, button_size, border_color)
        imgui.pop_style_var(1)
        if i < #sliders then
            imgui.same_line()
        end
    end

    if label then
        util_imgui.set_label(label, -1)
    end

    if additional_text and (checkbox and config:get(checkbox.config_key) or not checkbox) then
        imgui.same_line()
        imgui.spacing()
        imgui.same_line()
        imgui.text_colored(additional_text, mod.enum.colors.info)
    end

    imgui.end_disabled()

    return changed
end

---@param checkbox {config_key: string, label: string}?
---@param config_key string
---@param combo Combo
---@param label string
---@param default_index integer?
---@return {key: any, value: string, index: integer}?
function this.draw_combo(checkbox, config_key, label, combo, default_index)
    local changed = false

    if checkbox then
        changed =
            set:checkbox(string.format("%s##%s", "", checkbox.config_key), checkbox.config_key)
        imgui.same_line()
        imgui.begin_disabled(not config:get(checkbox.config_key))
    else
        imgui.begin_disabled(false)
    end

    local item_config_key = config_key .. "_combo"
    if not config:get(item_config_key) then
        config:set(item_config_key, default_index or 1)
    end

    if set:combo(label, item_config_key, combo.values) or changed then
        imgui.end_disabled()
        local index = config:get(item_config_key)
        return {
            key = combo:get_key(index),
            value = combo:get_value(index),
            index = index,
        }
    end

    imgui.end_disabled()
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
function this.draw(elem, elem_config, config_key)
    local is_current_profile = operations.is_current_profile(elem)

    imgui.begin_disabled(ace_misc.is_item_slider_open())
    if elem_config.hide ~= nil then
        if
            set:checkbox(
                util_gui.tr("hud_element.entry.box_hide", config_key .. ".hide"),
                config_key .. ".hide"
            ) and is_current_profile
        then
            elem:set_hide(elem_config.hide)
        end
    end
    imgui.end_disabled()

    imgui.begin_disabled(elem_config.hide ~= nil and elem_config.hide and not elem.hide_write)

    if elem_config.enabled_scale ~= nil then
        if

            this.draw_slider_settings(
                {
                    config_key = config_key .. ".enabled_scale",
                },
                {
                    {
                        config_key = config_key .. ".scale.x",
                    },
                    {
                        config_key = config_key .. ".scale.y",
                    },
                },
                0.01,
                -10.0,
                10.0,
                0.01,
                "%.2f",
                config.lang:tr("hud_element.entry.box_enable_scale")
            ) and is_current_profile
        then
            elem:set_scale(elem_config.enabled_scale and elem_config.scale or nil)
        end
    end

    if elem_config.enabled_offset ~= nil then
        local global_pos = elem:get_global_pos()

        if
            this.draw_slider_settings(
                {
                    config_key = config_key .. ".enabled_offset",
                },
                {
                    {
                        config_key = config_key .. ".offset.x",
                    },
                    {
                        config_key = config_key .. ".offset.y",
                    },
                },
                1,
                -1920,
                1920,
                1,
                "%.0f",
                config.lang:tr("hud_element.entry.box_enable_offset"),
                elem_config.enabled
                        and string.format(
                            "%s: x=%d, y=%d",
                            config.lang:tr("misc.text_screen_pos"),
                            global_pos and math.ceil(global_pos.x) or 0,
                            global_pos and math.ceil(global_pos.y) or 0
                        )
                    or nil
            ) and is_current_profile
        then
            elem:set_offset(elem_config.enabled_offset and elem_config.offset or nil)
        end
    end

    if elem_config.enabled_rot ~= nil then
        if
            this.draw_slider_settings({
                config_key = config_key .. ".enabled_rot",
            }, {
                {
                    config_key = config_key .. ".rot",
                },
            }, 0.1, 0, 360, 0.1, "%.1f", config.lang:tr(
                "hud_element.entry.box_enable_rotation"
            )) and is_current_profile
        then
            elem:set_rot(elem_config.enabled_rot and elem_config.rot or nil)
        end
    end

    if elem_config.enabled_opacity ~= nil then
        if
            this.draw_slider_settings({
                config_key = config_key .. ".enabled_opacity",
            }, {
                {
                    config_key = config_key .. ".opacity",
                },
            }, 0.01, 0, 1, 0.01, "%.2f", config.lang:tr(
                "hud_element.entry.box_enable_opacity"
            )) and is_current_profile
        then
            elem:set_opacity(elem_config.enabled_opacity and elem_config.opacity or nil)
        end
    end

    if elem_config.enabled_segment ~= nil then
        local item_config_key = config_key .. ".segment"
        local changed_value = this.draw_combo(
            {
                config_key = config_key .. ".enabled_segment",
            },
            item_config_key,
            util_gui.tr("hud_element.entry.box_enable_segment"),
            state.combo.segment,
            state.combo.segment:get_index(nil, config:get(item_config_key))
        )

        if changed_value then
            config:set(item_config_key, changed_value.value)
            if is_current_profile then
                elem:set_segment(elem_config.enabled_segment and elem_config.segment or nil)
            end
        end
    end

    if elem.hud_id then
        util_imgui.separator_text(config.lang:tr("hud_element.entry.category_profile_fade"))

        local current_hud = hud.get_current()
        ---@cast current_hud ModProfileConfig

        imgui.begin_disabled(
            not config.current.mod.enable_fade
                or current_hud.fade_in == 0 and current_hud.fade_out == 0
        )
        if
            set:checkbox(
                util_gui.tr("hud_element.entry.box_disable_fade", config_key .. ".disable_fade"),
                config_key .. ".disable_fade"
            ) and is_current_profile
        then
            elem:set_disable_fade(elem_config.disable_fade)
        end
        util_imgui.tooltip(config.lang:tr("hud_element.entry.tooltip_disable_fade"), true)

        imgui.begin_disabled(elem_config.disable_fade or not current_hud.fade_opacity)
        if
            set:checkbox(
                util_gui.tr(
                    "hud_element.entry.box_disable_fade_opacity",
                    config_key .. ".disable_fade_opacity"
                ),
                config_key .. ".disable_fade_opacity"
            ) and is_current_profile
        then
            elem:set_disable_fade_opacity(elem_config.disable_fade_opacity)
        end
        util_imgui.tooltip(config.lang:tr("hud_element.entry.tooltip_disable_fade_opacity"), true)
        imgui.end_disabled()
        imgui.end_disabled()
    end

    imgui.end_disabled()
end

return this
