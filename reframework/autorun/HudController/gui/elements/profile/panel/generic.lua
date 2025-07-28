local config = require("HudController.config")
local data = require("HudController.data")
local gui_util = require("HudController.gui.util")
local set = require("HudController.gui.set")
local state = require("HudController.gui.state")

local ace_map = data.ace.map

local this = {}
this.separator = gui_util.separator:new({
    "hide",
    "enabled_scale",
    "enabled_offset",
    "enabled_rot",
    "enabled_opacity",
    "enabled_color",
    "enabled_size_x",
    "enabled_size_y",
    "enabled_segment",
})

---@param option_keys string[]
---@param config_key string
---@param callback (fun(option_key: string, option_config_key: string))?
function this.draw_options(option_keys, config_key, callback)
    for i = 1, #option_keys do
        local key = option_keys[i]
        local option_data = ace_map.option[key]
        local option_config_key = string.format("%s.%s", config_key, key)
        local config_value = config.get(option_config_key)

        if
            set.slider_int(
                option_data.name_local,
                option_config_key,
                -1,
                #option_data.items - 1,
                (config_value == -1 and config.lang.tr("hud.option_disable"))
                    or option_data.items[config_value + 1].name_local
            ) and callback
        then
            callback(key, option_config_key)
        end
    end
end

---@param config_key string
---@param min number
---@param max number
---@param step number
---@return boolean
function this.draw_step_buttons(config_key, min, max, step)
    ---@type boolean
    local changed

    if imgui.button("-##button_minus_" .. config_key, { 20, 20 }) then
        changed = true
        config.set(config_key, math.max(config.get(config_key) - step, min))
    end

    imgui.same_line()

    if imgui.button("+##button_plus_" .. config_key, { 20, 20 }) then
        changed = true
        config.set(config_key, math.min(config.get(config_key) + step, max))
    end

    return changed
end

---@param checkbox {config_key: string, label: string}?
---@param sliders {config_key: string, label: string}[]
---@param min number
---@param max number
---@param step number
---@param format string
---@return boolean
function this.draw_slider_settings(checkbox, sliders, min, max, step, format)
    local changed = false

    if checkbox then
        changed = set.checkbox(string.format("%s##%s", checkbox.label, checkbox.config_key), checkbox.config_key)
        imgui.begin_disabled(not config.get(checkbox.config_key))
    else
        imgui.begin_disabled(false)
    end

    for i = 1, #sliders do
        local slider = sliders[i]
        changed = set.slider_float(
            string.format("%s##%s", slider.label, slider.config_key),
            slider.config_key,
            min,
            max,
            format
        ) or changed

        imgui.same_line()

        changed = this.draw_step_buttons(slider.config_key, min, max, step) or changed
    end

    imgui.end_disabled()

    return changed
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
function this.draw(elem, elem_config, config_key)
    local changed = false
    this.separator:refresh(elem_config)

    if elem_config.hide ~= nil then
        if set.checkbox(gui_util.tr("hud_element.entry.box_hide", config_key .. ".hide"), config_key .. ".hide") then
            elem:set_hide(elem_config.hide)
        end

        this.separator:draw()
    end

    imgui.begin_disabled(elem_config.hide ~= nil and elem_config.hide)

    if elem_config.enabled_scale ~= nil then
        changed = this.draw_slider_settings({
            config_key = config_key .. ".enabled_scale",
            label = gui_util.tr("hud_element.entry.box_enable_scale"),
        }, {
            {
                config_key = config_key .. ".scale.x",
                label = gui_util.tr("hud_element.entry.slider_x"),
            },
            {
                config_key = config_key .. ".scale.y",
                label = gui_util.tr("hud_element.entry.slider_y"),
            },
        }, -10.0, 10.0, 0.01, "%.2f")

        if changed then
            elem:set_scale(elem_config.enabled_scale and elem_config.scale or nil)
            config.save()
        end

        this.separator:draw()
    end

    if elem_config.enabled_offset ~= nil then
        changed = this.draw_slider_settings({
            config_key = config_key .. ".enabled_offset",
            label = gui_util.tr("hud_element.entry.box_enable_offset"),
        }, {
            {
                config_key = config_key .. ".offset.x",
                label = gui_util.tr("hud_element.entry.slider_x"),
            },
            {
                config_key = config_key .. ".offset.y",
                label = gui_util.tr("hud_element.entry.slider_y"),
            },
        }, -4000, 4000, 1, "%.0f")

        if changed then
            elem:set_offset(elem_config.enabled_offset and elem_config.offset or nil)
            config.save()
        end

        this.separator:draw()
    end

    if elem_config.enabled_rot ~= nil then
        changed = this.draw_slider_settings({
            config_key = config_key .. ".enabled_rot",
            label = gui_util.tr("hud_element.entry.box_enable_rotation"),
        }, {
            {
                config_key = config_key .. ".rot.x",
                label = gui_util.tr("hud_element.entry.slider_x"),
            },
            {
                config_key = config_key .. ".rot.y",
                label = gui_util.tr("hud_element.entry.slider_y"),
            },
            {
                config_key = config_key .. ".rot.z",
                label = gui_util.tr("hud_element.entry.slider_z"),
            },
        }, 0, 360, 0.1, "%.1f")

        if changed then
            elem:set_rot(
                elem_config.enabled_rot and { x = elem_config.rot.x, y = elem_config.rot.y, z = elem_config.rot.z }
                    or nil
            )
            config.save()
        end

        this.separator:draw()
    end

    if elem_config.enabled_opacity ~= nil then
        changed = this.draw_slider_settings({
            config_key = config_key .. ".enabled_opacity",
            label = gui_util.tr("hud_element.entry.box_enable_opacity"),
        }, {
            {
                config_key = config_key .. ".opacity",
                label = "",
            },
        }, 0, 1, 0.01, "%.2f")

        if changed then
            elem:set_opacity(elem_config.enabled_opacity and elem_config.opacity or nil)
            config.save()
        end

        this.separator:draw()
    end

    if elem_config.enabled_segment ~= nil then
        local checkbox_key = config_key .. ".enabled_segment"
        changed = set.checkbox(
            string.format("%s##%s", gui_util.tr("hud_element.entry.box_enable_segment"), checkbox_key),
            checkbox_key
        )

        imgui.begin_disabled(not config.get(checkbox_key))

        local item_config_key = config_key .. ".segment"
        if not config.get(item_config_key .. "_combo") then
            config.set(item_config_key .. "_combo", state.combo.segment:get_index(nil, config.get(item_config_key)))
        end

        changed = set.combo(
            "##" .. item_config_key .. "_combo",
            item_config_key .. "_combo",
            state.combo.segment.values
        ) or changed

        if changed then
            config.set(item_config_key, state.combo.segment:get_value(config.get(item_config_key .. "_combo")))
            elem:set_segment(elem_config.enabled_segment and elem_config.segment or nil)
            config.save()
        end

        imgui.end_disabled()

        this.separator:draw()
    end

    imgui.end_disabled()
end

return this
