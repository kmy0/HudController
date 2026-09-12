local config = require("HudController.config.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")

local draw_control_child = require("HudController.gui.elements.profile.panel.sub.control_child")
local set = state.set

---@param elem Text
---@param elem_config TextConfig
---@param config_key string
return function(elem, elem_config, config_key)
    draw_control_child(elem, elem_config, config_key)

    ---@type string
    local item_config_key
    local changed = false
    local is_current_profile = operations.is_current_profile(elem)

    if elem_config.enabled_font_size ~= nil then
        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_font_size",
        }, {
            {
                config_key = config_key .. ".font_size",
            },
        }, 0.1, 0, 1000, 0.1, "%.1f", config.lang:tr(
            "hud_element.entry.box_enable_font_size"
        )) or changed

        if changed and is_current_profile then
            elem:set_font_size(elem_config.enabled_font_size and elem_config.font_size or nil)
        end

        util_imgui.end_disabled()
    end

    if elem_config.enabled_page_alignment ~= nil then
        item_config_key = config_key .. ".page_alignment"
        local changed_value = generic.draw_combo(
            {
                config_key = config_key .. ".enabled_page_alignment",
            },
            item_config_key,
            util_gui.tr("hud_element.entry.box_enable_page_alignment", item_config_key),
            state.combo.page_alignment,
            state.combo.page_alignment:get_index(nil, config:get(item_config_key))
        )

        if changed_value then
            if is_current_profile then
                elem:set_page_alignment(changed_value.value)
            end
            config:set(item_config_key, changed_value.value)
        end
    end

    if elem_config.hide_glow ~= nil then
        if
            set:checkbox(
                util_gui.tr("hud_element.entry.box_hide_glow", config_key .. ".hide_glow"),
                config_key .. ".hide_glow"
            ) and is_current_profile
        then
            elem:set_hide_glow(elem_config.hide_glow)
        end
    end

    util_imgui.begin_disabled(elem_config.hide_glow ~= nil and elem_config.hide_glow)

    if elem_config.enabled_glow_color ~= nil then
        item_config_key = config_key .. ".enabled_glow_color"
        changed = set:checkbox("##checkbox." .. item_config_key, item_config_key)

        util_imgui.begin_disabled(not elem_config.enabled_glow_color)
        imgui.same_line()
        item_config_key = config_key .. ".glow_color"
        changed = set:color_edit(util_gui.tr("hud_element.entry.color_glow"), item_config_key)
            or changed

        if changed and is_current_profile then
            elem:set_glow_color(elem_config.enabled_glow_color and elem_config.glow_color or nil)
        end

        util_imgui.end_disabled()
    end

    util_imgui.end_disabled()
end
