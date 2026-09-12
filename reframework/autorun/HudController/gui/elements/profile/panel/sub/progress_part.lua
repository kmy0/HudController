local config = require("HudController.config.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local operations = require("HudController.hud.manager.operations")
local util_imgui = require("HudController.util.imgui.init")

---@param elem ProgressPartBase
---@param elem_config ProgressPartBaseConfig
---@param config_key string
return function(elem, elem_config, config_key)
    local changed = false
    local is_current_profile = operations.is_current_profile(elem)

    util_imgui.begin_disabled(elem_config.enabled_offset == true)

    if elem_config.enabled_offset_x ~= nil then
        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_offset_x",
        }, {
            {
                config_key = config_key .. ".offset_x",
            },
        }, 1, -1920, 1920, 1, "%.0f", config.lang:tr(
            "hud_element.entry.box_enable_offset_x"
        ))

        if changed and is_current_profile then
            elem:set_offset_x(elem_config.enabled_offset_x and elem_config.offset_x or nil)
        end
    end

    if elem_config.enabled_clock_offset_x ~= nil then
        util_imgui.begin_disabled(elem_config.enabled_offset_x == false)

        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_clock_offset_x",
        }, {
            {
                config_key = config_key .. ".clock_offset_x",
            },
        }, 1, -1920, 1920, 1, "%.0f", config.lang:tr(
            "hud_element.entry.box_enable_clock_offset_x"
        ))

        if changed and is_current_profile then
            elem:set_clock_offset_x(
                elem_config.enabled_clock_offset_x and elem_config.clock_offset_x or nil
            )
        end

        util_imgui.end_disabled()
    end

    if elem_config.enabled_num_offset_x ~= nil then
        util_imgui.begin_disabled(elem_config.enabled_offset_x == false)

        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_num_offset_x",
        }, {
            {
                config_key = config_key .. ".num_offset_x",
            },
        }, 1, -1929, 1920, 1, "%.0f", config.lang:tr(
            "hud_element.entry.box_enable_num_offset_x"
        ))

        if changed and is_current_profile then
            elem:set_num_offset_x(
                elem_config.enabled_num_offset_x and elem_config.num_offset_x or nil
            )
        end

        util_imgui.end_disabled()
    end

    util_imgui.end_disabled()
end
