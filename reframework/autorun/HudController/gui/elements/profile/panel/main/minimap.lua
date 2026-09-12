local config = require("HudController.config.init")
local data = require("HudController.data.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")

local mod = data.mod
local set = state.set

---@param elem Minimap
---@param elem_config MinimapConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_map"))

    -- the map gui object has to actually exist to get names of options
    state.init_combo_map_icon_filter()

    local is_current_profile = operations.is_current_profile(elem)
    local item_config_key = config_key .. ".default_filter"
    local changed_value = generic.draw_combo(
        nil,
        item_config_key,
        util_gui.tr("hud_element.entry.combo_map_filter"),
        state.combo.map_filter
    )

    if changed_value then
        local value = mod.map.combo_map_filter[changed_value.key]
        config:set(item_config_key, value)
        if is_current_profile then
            elem:set_default_filter(value)
        end
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_classic_minimap"))
    item_config_key = config_key .. ".enabled_classic_minimap"
    if
        set:checkbox(util_gui.tr("hud_element.entry.box_enable", item_config_key), item_config_key)
        and is_current_profile
    then
        elem:set_enable_classic_minimap(elem_config.enabled_classic_minimap)
    end

    util_imgui.begin_disabled(not elem_config.enabled_classic_minimap)

    if
        generic.draw_slider_settings({
            config_key = config_key .. ".children.classic_minimap.enabled_fov",
        }, {
            {
                config_key = config_key .. ".children.classic_minimap.fov_map",
            },
        }, 0.01, 0, 180.0, 0.01, "%.2f", config.lang:tr(
            "hud_element.entry.box_enable_map_fov"
        )) and is_current_profile
    then
        elem:set_classic_minimap_fov(
            elem_config.children.classic_minimap.enabled_fov
                    and elem_config.children.classic_minimap.fov_map
                or nil
        )
    end

    if
        generic.draw_slider_settings({
            config_key = config_key .. ".children.classic_minimap.enabled_icon_scale",
        }, {
            {
                config_key = config_key .. ".children.classic_minimap.scale_icon",
            },
        }, 0.01, 0, 25, 0.01, "%.2f", config.lang:tr(
            "hud_element.entry.box_enable_icon_scale"
        )) and is_current_profile
    then
        elem:set_classic_minimap_icon_scale(
            elem_config.children.classic_minimap.enabled_icon_scale
                    and elem_config.children.classic_minimap.scale_icon
                or nil
        )
    end

    if
        generic.draw_slider_settings({
            config_key = config_key .. ".children.classic_minimap.enabled_rot_map",
        }, {
            {
                config_key = config_key .. ".children.classic_minimap.rot_map",
            },
        }, 0.01, 0, 360, 0.01, "%.1f", config.lang:tr(
            "hud_element.entry.box_enable_rotation"
        )) and is_current_profile
    then
        elem:set_classic_minimap_rot(
            elem_config.children.classic_minimap.enabled_rot_map
                    and elem_config.children.classic_minimap.rot_map
                or nil
        )
    end

    if
        generic.draw_slider_settings({
            config_key = config_key .. ".children.classic_minimap.enabled_angle_map",
        }, {
            {
                config_key = config_key .. ".children.classic_minimap.angle_map",
                label = "",
            },
        }, 0.01, 0, 90, 0.01, "%.1f", config.lang:tr("hud_element.entry.box_enable_angle"))
        and is_current_profile
    then
        elem:set_classic_minimap_angle(
            elem_config.children.classic_minimap.enabled_angle_map
                    and elem_config.children.classic_minimap.angle_map
                or nil
        )
    end

    item_config_key = config_key .. ".children.pl_icon_pulse.enabled_play_state"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_hide_pl_icon_pulse", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        if not elem_config.children.pl_icon_pulse.enabled_play_state then
            elem_config.children.pl_icon_pulse.play_state = nil
        else
            elem_config.children.pl_icon_pulse.play_state = "DISABLE"
        end

        elem.children.pl_icon_pulse:set_play_state(elem_config.children.pl_icon_pulse.play_state)
    end

    util_imgui.end_disabled()
end
