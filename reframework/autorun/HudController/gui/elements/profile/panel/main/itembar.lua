local config = require("HudController.config.init")
local data = require("HudController.data.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod
local set = state.set

---@param elem Itembar
---@param elem_config ItembarConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_itembar_behavior"))
    local is_current_profile = operations.is_current_profile(elem)

    local item_config_key = config_key .. ".children.slider.appear_open"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_appear_open", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem.children.slider:set_appear_open(elem_config.children.slider.appear_open)
    end

    item_config_key = config_key .. ".children.slider.move_next"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_move_next", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem.children.slider:set_move_next(elem_config.children.slider.move_next)
    end
    util_imgui.tooltip(config.lang:tr("hud_element.entry.tooltip_itembar_move_next"), true)

    item_config_key = config_key .. ".start_expanded"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_start_expanded", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem:set_start_expanded(elem_config.start_expanded)
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_mantle_behavior"))

    item_config_key = config_key .. ".children.mantle.always_visible"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_always_visible", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem.children.mantle:set_always_visible(elem_config.children.mantle.always_visible)
    end

    item_config_key = config_key .. ".children.mantle.timer_visible"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_timer_visible", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem.children.mantle:set_timer_visible(elem_config.children.mantle.timer_visible)
    end

    util_imgui.separator_text(
        config.lang:tr("hud_element.entry.category_expanded_itembar_behavior")
    )

    item_config_key = config_key .. ".children.all_slider.appear_open"
    if
        set:checkbox(
            util_gui.tr(
                "hud_element.entry.box_appear_open",
                item_config_key,
                "expanded_appear_open"
            ),
            item_config_key
        ) and is_current_profile
    then
        elem.children.all_slider:set_appear_open(elem_config.children.all_slider.appear_open)
    end

    item_config_key = config_key .. ".children.all_slider.ammo_visible"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_itembar_ammo_visible", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem.children.all_slider:set_ammo_visible(elem_config.children.all_slider.ammo_visible)
    end

    item_config_key = config_key .. ".children.all_slider.slinger_visible"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_itembar_slinger_visible", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem.children.all_slider:set_slinger_visible(
            elem_config.children.all_slider.slinger_visible
        )
    end

    item_config_key = config_key .. ".children.all_slider.disable_right_stick"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_itembar_disable_right_stick", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem.children.all_slider:set_disable_right_stick(
            elem_config.children.all_slider.disable_right_stick
        )
    end

    item_config_key = config_key .. ".children.all_slider.enable_mouse_control"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_itembar_enable_mouse_control", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem.children.all_slider:set_enable_mouse_control(
            elem_config.children.all_slider.enable_mouse_control
        )
    end

    item_config_key = config_key .. ".children.all_slider.control"
    local values = util_table.extend(
        { config.lang:tr("hud.option_disable") },
        util_table.values(mod.map.slider_expanded_itembar_control, function(o)
            return config.lang:tr("hud_element.entry." .. o)
        end)
    )

    if
        set:slider_list(
            util_gui.tr("hud_element.entry.slider_expanded_itembar_control"),
            item_config_key,
            -1,
            #mod.map.slider_expanded_itembar_control - 1,
            values
        ) and is_current_profile
    then
        elem.children.all_slider:set_control(elem_config.children.all_slider.control)
    end

    item_config_key = config_key .. ".children.all_slider.decide_key"
    local changed_value = generic.draw_combo(
        nil,
        item_config_key,
        util_gui.tr("hud_element.entry.combo_expanded_itembar_decide_key"),
        state.combo.item_decide
    )

    if changed_value then
        if is_current_profile then
            elem.children.all_slider:set_decide_key(changed_value.key)
        end

        config:set(item_config_key, changed_value.key)
    end
end
