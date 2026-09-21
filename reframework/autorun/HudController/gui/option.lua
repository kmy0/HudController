local config = require("HudController.config.init")
local mod = require("HudController.data.mod")
local set = require("HudController.gui.set")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")

local this = {}

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
    local count = #sliders
    local total_width = imgui.calc_item_width()
    local control_start = imgui.get_cursor_pos()
    local slider_area_width = total_width

    if checkbox then
        changed = set:checkbox(
            string.format("%s##%s", checkbox.label or "", checkbox.config_key),
            checkbox.config_key
        )

        disabled = not config:get(checkbox.config_key)

        imgui.same_line()

        local slider_start = imgui.get_cursor_pos()
        slider_area_width = total_width - (slider_start.x - control_start.x)

        util_imgui.begin_disabled(disabled)
    else
        util_imgui.begin_disabled(false)
    end

    local button_size = config.lang.font_size + 6
    local group_spacing = 8
    local min_drag_width = 20
    local min_group_width = button_size * 2 + min_drag_width
    local min_slider_area_width = min_group_width * count + group_spacing * (count - 1)
    slider_area_width = math.max(slider_area_width, min_slider_area_width)
    local usable_width = slider_area_width - group_spacing * (count - 1)
    local base_group_width = math.floor(usable_width / count)
    local decimals = tonumber(format:match("%.(%d+)f")) --[[@as number]]
    local border_color = 0xff4f4e4d
    border_color = not disabled and border_color or util_misc.mul_alpha(border_color, 0.6)
    local row_start = imgui.get_cursor_pos()

    row_start.x = math.floor(row_start.x + 0.5)
    row_start.y = math.floor(row_start.y + 0.5)

    local used_width = 0

    for i = 1, count do
        local slider = sliders[i]
        local group_width = 0

        if i == count then
            group_width = usable_width - base_group_width * (count - 1)
        else
            group_width = base_group_width
        end

        local group_x = row_start.x + used_width + group_spacing * (i - 1)

        imgui.set_cursor_pos({
            group_x,
            row_start.y,
        })

        local drag_width = math.max(min_drag_width, group_width - button_size * 2)

        imgui.push_style_var(14, Vector2f.new(0, 4))

        util_imgui.with_border(function()
            if
                imgui.button("-##button_minus_" .. slider.config_key, {
                    button_size,
                    button_size,
                })
            then
                changed = true

                local val = math.max(config:get(slider.config_key) - step, min)

                config:set(slider.config_key, util_misc.round(val, decimals))
            end
        end, button_size, button_size, border_color)

        imgui.same_line()

        imgui.set_next_item_width(drag_width)

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
                imgui.button("+##button_plus_" .. slider.config_key, {
                    button_size,
                    button_size,
                })
            then
                changed = true

                local val = math.min(config:get(slider.config_key) + step, max)

                config:set(slider.config_key, util_misc.round(val, decimals))
            end
        end, button_size, button_size, border_color)

        imgui.pop_style_var(1)

        used_width = used_width + group_width
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

    util_imgui.end_disabled()

    return changed
end

---@param checkbox {config_key: string, label: string?}?
---@param config_key string
---@param label string
---@param combo Combo
---@param default_index integer?
---@return {key: any, value: string, index: integer}?
function this.draw_combo(checkbox, config_key, label, combo, default_index)
    local changed = false
    local total_width = imgui.calc_item_width()
    local control_start = imgui.get_cursor_pos()
    local combo_width = total_width

    if checkbox then
        changed =
            set:checkbox(string.format("%s##%s", "", checkbox.config_key), checkbox.config_key)

        imgui.same_line()

        local combo_start = imgui.get_cursor_pos()
        combo_width = total_width - (combo_start.x - control_start.x)

        util_imgui.begin_disabled(not config:get(checkbox.config_key))
    else
        util_imgui.begin_disabled(false)
    end

    local item_config_key = string.format("__temp.%s_combo", config_key)

    if not config:get(item_config_key) then
        config:set(item_config_key, default_index or 1)
    end

    imgui.set_next_item_width(combo_width)
    if set:combo_filter(label, item_config_key, combo) or changed then
        util_imgui.end_disabled()

        local index = config:get(item_config_key)
        return {
            key = combo:get_key(index),
            value = combo:get_value(index),
            index = index,
        }
    end

    util_imgui.end_disabled()
end

---@param checkbox {config_key: string, label: string?}
---@param config_key string
---@param label string
---@return boolean
function this.draw_enabled_color(checkbox, config_key, label)
    local changed = false
    local total_width = imgui.calc_item_width()
    local control_start = imgui.get_cursor_pos()
    local width = total_width

    changed = set:checkbox(string.format("%s##%s", "", checkbox.config_key), checkbox.config_key)
    imgui.same_line()
    local combo_start = imgui.get_cursor_pos()
    width = total_width - (combo_start.x - control_start.x)

    util_imgui.begin_disabled(not config:get(checkbox.config_key))

    imgui.set_next_item_width(width)
    changed = set:color_edit(label, config_key) or changed
    util_imgui.end_disabled()
    return changed
end

---@param label string?
---@param config_key string
---@return boolean
function this.draw_bool_slider(label, config_key)
    local value = config:get(config_key)
    local slider_value = value and 1 or 0
    local temp_key = string.format("__temp.%s.__value", config_key)
    config:set(temp_key, slider_value)

    local changed = set:slider_list(
        label or ("##" .. config_key),
        temp_key,
        1,
        2,
        { config.lang:tr("misc.text_off"), config.lang:tr("misc.text_on") }
    )

    if changed then
        config:set(config_key, config:get(temp_key) == 2)
    end

    return changed
end

return this
