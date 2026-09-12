local config = require("HudController.config.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")

local draw_control_child = require("HudController.gui.elements.profile.panel.sub.control_child")
local set = state.set

---@param elem Scale9
---@param elem_config Scale9Config
---@param config_key string
return function(elem, elem_config, config_key)
    draw_control_child(elem, elem_config, config_key)

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_texture"))

    ---@type string
    local item_config_key
    local is_current_profile = operations.is_current_profile(elem)
    if elem_config.enabled_control_point ~= nil then
        item_config_key = config_key .. ".blend"
        local changed_value = generic.draw_combo(
            {
                config_key = config_key .. ".enabled_control_point",
                label = util_gui.tr(
                    "hud_element.entry.box_enable_scale9_control_point",
                    item_config_key
                ),
            },
            item_config_key,
            "##" .. item_config_key,
            state.combo.control_point,
            state.combo.control_point:get_index(nil, config:get(item_config_key))
        )

        if changed_value then
            if is_current_profile then
                elem:set_control_point(
                    elem_config.enabled_control_point and changed_value.value or nil
                )
            end

            config:set(item_config_key, changed_value.value)
        end
    end

    if elem_config.enabled_blend ~= nil then
        item_config_key = config_key .. ".blend"
        local changed_value = generic.draw_combo(
            {
                config_key = config_key .. ".enabled_blend",
                label = util_gui.tr(
                    "hud_element.entry.box_enable_scale9_blend_type",
                    item_config_key
                ),
            },
            item_config_key,
            "##" .. item_config_key,
            state.combo.blend,
            state.combo.blend:get_index(nil, config:get(item_config_key))
        )

        if changed_value then
            if is_current_profile then
                elem:set_blend(elem_config.enabled_blend and changed_value.value or nil)
            end
            config:set(item_config_key, changed_value.value)
        end
    end

    if elem_config.enabled_alpha_channel ~= nil then
        item_config_key = config_key .. ".alpha_channel"
        local changed_value = generic.draw_combo(
            {
                config_key = config_key .. ".enabled_alpha_channel",
                label = util_gui.tr(
                    "hud_element.entry.box_enable_scale9_alpha_channel",
                    item_config_key
                ),
            },
            item_config_key,
            "##" .. item_config_key,
            state.combo.alpha_channel,
            state.combo.alpha_channel:get_index(nil, config:get(item_config_key))
        )

        if changed_value then
            if is_current_profile then
                elem:set_alpha_channel(
                    elem_config.enabled_alpha_channel and changed_value.value or nil
                )
            end
            config:set(item_config_key, changed_value.value)
        end
    end

    if elem_config.enabled_ignore_alpha ~= nil then
        item_config_key = config_key .. ".enabled_ignore_alpha"
        local changed = set:checkbox(
            util_gui.tr("hud_element.entry.box_enable_scale9_ignore_alpha", item_config_key),
            item_config_key
        )

        util_imgui.begin_disabled(not elem_config.enabled_ignore_alpha)

        item_config_key = config_key .. ".ignore_alpha"
        changed = set:checkbox(
            util_gui.tr("hud_element.entry.box_scale9_ignore_alpha", item_config_key),
            item_config_key
        ) or changed

        if changed and is_current_profile then
            elem:set_ignore_alpha(
                elem_config.enabled_ignore_alpha and elem_config.ignore_alpha or nil
            )
        end

        util_imgui.end_disabled()
    end
end
