local config = require("HudController.config.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")

local set = state.set

---@param elem CtrlChild
---@param elem_config CtrlChildConfig
---@param config_key string
return function(elem, elem_config, config_key)
    local changed = false
    local is_current_profile = operations.is_current_profile(elem)
    if elem_config.enabled_size_x ~= nil then
        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_size_x",
        }, {
            {
                config_key = config_key .. ".size_x",
            },
        }, 1, -1920, 1920, 1, "%.1f", config.lang:tr("hud_element.entry.box_enable_size_x"))

        if changed and is_current_profile then
            elem:set_size_x(elem_config.enabled_size_x and elem_config.size_x or nil)
        end
    end

    if elem_config.enabled_size_y ~= nil then
        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_size_y",
        }, {
            {
                config_key = config_key .. ".size_y",
            },
        }, 1, -1920, 1920, 1, "%.1f", config.lang:tr("hud_element.entry.box_enable_size_y"))

        if changed and is_current_profile then
            elem:set_size_y(elem_config.enabled_size_y and elem_config.size_y or nil)
        end
    end

    if elem_config.enabled_color ~= nil then
        local item_config_key = config_key .. ".enabled_color"
        changed = set:checkbox("##checkbox." .. item_config_key, item_config_key)

        util_imgui.begin_disabled(not elem_config.enabled_color)
        imgui.same_line()
        item_config_key = config_key .. ".color"
        changed = set:color_edit(
            util_gui.tr("hud_element.entry.color_color", item_config_key),
            item_config_key
        ) or changed

        if changed and is_current_profile then
            elem:set_color(elem_config.enabled_color and elem_config.color or nil)
        end

        util_imgui.end_disabled()
    end
end
