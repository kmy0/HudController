local config = require("HudController.config.init")
local data = require("HudController.data.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local m = require("HudController.util.ref.methods")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod
local set = state.set

local this = {
    ---@type table<HudType, fun(elem: HudBase, elem_config: HudBaseConfig, config_key: string)>
    funcs = {},
}

---@param elem Notice | NameOther | NameAccess
---@param item_config_key string
---@param label string
---@param entry_key string
---@param set_fn fun(self: any, key: string, value: boolean)
---@param combo_key string
---@param is_current_profile boolean
---@param is_key_disabled fun(item_config_key: string, key: any, value: string): boolean
local function notice_combo_hide(
    elem,
    item_config_key,
    label,
    entry_key,
    set_fn,
    combo_key,
    is_current_profile,
    is_key_disabled
)
    local combo = state.get_cached_combo(combo_key, item_config_key, is_key_disabled)
    local combo_index_key = item_config_key .. "_combo"

    imgui.set_next_item_width(
        util_imgui.get_something_with_button_width(config.lang:tr("hud_element.entry.button_hide"))
    )
    util_imgui.begin_disabled(combo:empty())
    generic.draw_combo(nil, item_config_key, "##" .. item_config_key, combo)

    imgui.same_line()
    if imgui.button(util_gui.tr("hud_element.entry.button_hide", item_config_key)) then
        local index = config:get(combo_index_key)
        local key = combo:get_key(index)

        if not elem[entry_key][key] then
            if is_current_profile then
                set_fn(elem, key, true)
            end

            config:set(string.format("%s.%s", item_config_key, key), true)
            config:set(combo_index_key, combo:disable_item(key))
        end
    end

    util_imgui.end_disabled()
    util_imgui.set_label(label, -1)

    local item_count = #combo.disabled
    if item_count > 0 then
        local item_height = imgui.calc_text_size("A").y + 10
        local height = math.min(item_height * item_count, 4 * (config.lang.font_size * (46 / 16)))

        if
            imgui.begin_child_window(
                "entries" .. item_config_key,
                { imgui.calc_item_width(), height },
                false
            )
        then
            for i, map in ipairs(combo.disabled) do
                if elem[entry_key][map.key] then
                    if
                        imgui.button(
                            util_gui.tr(
                                "hud_element.entry.button_remove",
                                item_config_key,
                                i,
                                map.key
                            )
                        )
                    then
                        if is_current_profile then
                            set_fn(elem, map.key, false)
                        end

                        config:set(string.format("%s.%s", item_config_key, map.key), false)
                        config:set(combo_index_key, combo:enable_item(map.key))
                    end

                    imgui.same_line()
                    imgui.text(map.value)
                end
            end
        end

        imgui.end_child_window()
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_weapon(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_weapon_behavior"))

    ---@cast elem Weapon
    ---@cast elem_config WeaponConfig

    local item_config_key = config_key .. ".no_focus"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_weapon_no_focus", item_config_key),
            item_config_key
        ) and operations.is_current_profile(elem)
    then
        elem:set_no_focus(elem_config.no_focus)
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_itembar(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_itembar_behavior"))
    local is_current_profile = operations.is_current_profile(elem)

    ---@cast elem Itembar
    ---@cast elem_config ItembarConfig

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

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_notice(elem, elem_config, config_key)
    ---@cast elem_config NoticeConfig
    ---@cast elem Notice

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_tools"))

    local is_current_profile = operations.is_current_profile(elem)
    local item_config_key = config_key .. ".tools_enemy_message_type"

    imgui.set_next_item_width(
        util_imgui.get_something_with_button_width(config.lang:tr("hud_element.entry.button_send"))
    )

    local changed_value = generic.draw_combo(
        nil,
        item_config_key,
        "##" .. item_config_key,
        state.combo.enemy_msg_type
    )

    if changed_value then
        config:set(item_config_key, changed_value.key)
    end

    imgui.same_line()

    if imgui.button(util_gui.tr("hud_element.entry.button_send", item_config_key)) then
        m.sendEnemyMessage(0, config:get(item_config_key))
    end

    util_imgui.set_label(config.lang:tr("hud_element.entry.combo_tool_enemy"), -1)

    item_config_key = config_key .. ".cache_msg"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_cache_messages", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem:set_cache_msg(elem_config.cache_msg)
    end

    imgui.same_line()
    if imgui.button(util_gui.tr("hud_element.entry.button_clear", item_config_key)) then
        elem.message_log_cache:clear()
    end

    if elem_config.cache_msg then
        if
            imgui.begin_table(
                "notice_cached_messages",
                7,
                1 << 8 | 1 << 7 | 1 << 10 | 1 << 13 | 1 << 25 --[[@as ImGuiTableFlags]],
                Vector2f.new(0, 4 * (config.lang.font_size * (46 / 16)))
            )
        then
            for _, header in ipairs({
                config.lang:tr("misc.text_row"),
                config.lang:tr("misc.text_type"),
                config.lang:tr("misc.text_sub_type"),
                config.lang:tr("misc.text_other_type"),
                config.lang:tr("misc.text_child_element"),
                config.lang:tr("misc.text_id"),
                config.lang:tr("misc.text_message"),
            }) do
                imgui.table_setup_column(header)
            end

            imgui.table_headers_row()
            for i = #elem.message_log_cache, 1, -1 do
                imgui.table_next_row()
                local entry = elem.message_log_cache[i]

                imgui.table_set_column_index(0)
                imgui.text(i)

                imgui.table_set_column_index(1)
                imgui.text(entry.type)

                imgui.table_set_column_index(2)
                imgui.text(entry.sub_type)

                imgui.table_set_column_index(3)
                imgui.text(entry.other_type)

                imgui.table_set_column_index(4)
                imgui.text(entry.cls)

                imgui.table_set_column_index(5)
                imgui.text(entry.log_id)

                imgui.table_set_column_index(6)
                imgui.text(util_misc.trunc_string(entry.msg))
                util_imgui.tooltip(entry.msg)
            end

            imgui.end_table()
        end
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_hide"))

    notice_combo_hide(
        elem,
        config_key .. ".system_log",
        config.lang:tr("hud_element.entry.combo_notice_system"),
        "system_log",
        elem.set_system_log,
        "system_log",
        is_current_profile,
        function(item_config_key, key, _)
            return config:get(item_config_key)[key]
        end
    )

    notice_combo_hide(
        elem,
        config_key .. ".enemy_log",
        config.lang:tr("hud_element.entry.combo_notice_enemy"),
        "enemy_log",
        elem.set_enemy_log,
        "enemy_log",
        is_current_profile,
        function(item_config_key, key, _)
            return config:get(item_config_key)[key]
        end
    )

    notice_combo_hide(
        elem,
        config_key .. ".camp_log",
        config.lang:tr("hud_element.entry.combo_notice_camp"),
        "camp_log",
        elem.set_camp_log,
        "camp_log",
        is_current_profile,
        function(item_config_key, key, _)
            return config:get(item_config_key)[key]
        end
    )

    notice_combo_hide(
        elem,
        config_key .. ".chat_log",
        config.lang:tr("hud_element.entry.combo_notice_lobby"),
        "chat_log",
        elem.set_chat_log,
        "chat_log",
        is_current_profile,
        function(item_config_key, key, _)
            return config:get(item_config_key)[key]
        end
    )

    notice_combo_hide(
        elem,
        config_key .. ".lobby_log",
        config.lang:tr("hud_element.entry.combo_notice_lobby_target"),
        "lobby_log",
        elem.set_lobby_log,
        "lobby_log",
        is_current_profile,
        function(item_config_key, key, _)
            return config:get(item_config_key)[key]
        end
    )

    notice_combo_hide(
        elem,
        config_key .. ".auto_id",
        config.lang:tr("hud_element.entry.combo_notice_auto_id"),
        "auto_id",
        elem.set_auto_id,
        "auto_id",
        is_current_profile,
        function(item_config_key, key, _)
            return config:get(item_config_key)[key]
        end
    )

    notice_combo_hide(
        elem,
        config_key .. ".log_id",
        config.lang:tr("hud_element.entry.combo_notice_system_id"),
        "log_id",
        elem.set_log_id,
        "log_id",
        is_current_profile,
        function(item_config_key, key, _)
            return config:get(item_config_key)[key]
        end
    )
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_name_access(elem, elem_config, config_key)
    ---@cast elem_config NameAccessConfig
    ---@cast elem NameAccess

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_npc_behavior"))
    local item_config_key = config_key .. ".npc_draw_distance"
    local config_value = config:get(item_config_key)
    local is_current_profile = operations.is_current_profile(elem)
    if
        set:slider_float(
            util_gui.tr("hud_element.entry.slider_draw_distance"),
            item_config_key,
            0,
            50,
            (config_value == 0 and config.lang:tr("hud.option_disable")) or "%.1f"
        ) and is_current_profile
    then
        elem:set_npc_draw_distance(elem_config.npc_draw_distance)
    end

    notice_combo_hide(
        elem,
        config_key .. ".object_category",
        config.lang:tr("hud_element.entry.combo_object_category"),
        "object_category",
        elem.set_object_category,
        "object_category",
        is_current_profile,
        function(item_config_key, key, _)
            return config:get(item_config_key)[key]
        end
    )

    notice_combo_hide(
        elem,
        config_key .. ".npc_type",
        config.lang:tr("hud_element.entry.combo_npc_type"),
        "npc_type",
        elem.set_npc_type,
        "npc_type",
        is_current_profile,
        function(item_config_key, key, _)
            return config:get(item_config_key)[key]
        end
    )

    notice_combo_hide(
        elem,
        config_key .. ".enemy_type",
        config.lang:tr("hud_element.entry.combo_enemy_type"),
        "enemy_type",
        elem.set_enemy_type,
        "enemy_type",
        is_current_profile,
        function(item_config_key, key, _)
            return config:get(item_config_key)[key]
        end
    )

    notice_combo_hide(
        elem,
        config_key .. ".panel_type",
        config.lang:tr("hud_element.entry.combo_panel_type"),
        "panel_type",
        elem.set_panel_type,
        "panel_type",
        is_current_profile,
        function(item_config_key, key, _)
            return config:get(item_config_key)[key]
        end
    )

    notice_combo_hide(
        elem,
        config_key .. ".gossip_type",
        config.lang:tr("hud_element.entry.combo_gossip_type"),
        "gossip_type",
        elem.set_gossip_type,
        "gossip_type",
        is_current_profile,
        function(item_config_key, key, _)
            return config:get(item_config_key)[key]
        end
    )
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_name_other(elem, elem_config, config_key)
    ---@cast elem_config NameOtherConfig
    ---@cast elem NameOther

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_pl_behavior"))
    local item_config_key = config_key .. ".pl_draw_distance"
    local config_value = config:get(item_config_key)
    local is_current_profile = operations.is_current_profile(elem)
    if
        set:slider_float(
            util_gui.tr("hud_element.entry.slider_draw_distance", item_config_key),
            item_config_key,
            0,
            50,
            (config_value == 0 and config.lang:tr("hud.option_disable")) or "%.1f"
        ) and is_current_profile
    then
        elem:set_pl_draw_distance(elem_config.pl_draw_distance)
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_pet_behavior"))
    item_config_key = config_key .. ".pet_draw_distance"
    config_value = config:get(item_config_key)
    if
        set:slider_float(
            util_gui.tr("hud_element.entry.slider_draw_distance", item_config_key),
            item_config_key,
            0,
            50,
            (config_value == 0 and config.lang:tr("hud.option_disable")) or "%.1f"
        ) and is_current_profile
    then
        elem:set_pet_draw_distance(elem_config.pet_draw_distance)
    end

    notice_combo_hide(
        elem,
        config_key .. ".nameplate_type",
        config.lang:tr("hud_element.entry.combo_nameplate_type"),
        "nameplate_type",
        elem.set_nameplate_type,
        "nameplate_type",
        is_current_profile,
        function(item_config_key, key, _)
            return config:get(item_config_key)[key]
        end
    )
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_ammo(elem, elem_config, config_key)
    ---@cast elem_config AmmoConfig
    ---@cast elem Ammo

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_parts_behavior"))
    local item_config_key = config_key .. ".no_hide_parts"
    if
        set:checkbox(util_gui.tr("hud_element.entry.box_no_hide", item_config_key), item_config_key)
        and operations.is_current_profile(elem)
    then
        elem:set_no_hide_parts(elem_config.no_hide_parts)
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_radial(elem, elem_config, config_key)
    ---@cast elem_config RadialConfig
    ---@cast elem Radial

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_radial_behavior"))
    local item_config_key = config_key .. ".expanded"
    local is_current_profile = operations.is_current_profile(elem)
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_always_expanded", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem:set_expanded(elem_config.expanded)
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_pallet_behavior"))
    item_config_key = config_key .. ".children.pallet.expanded"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_always_expanded", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem.children.pallet:set_expanded(elem_config.children.pallet.expanded)
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_slinger_reticle(elem, elem_config, config_key)
    ---@cast elem_config SlingerReticleConfig
    ---@cast elem SlingerReticle

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_slinger_behavior"))
    local item_config_key = config_key .. ".children.slinger.hide_slinger_empty"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_hide_slinger_empty", item_config_key),
            item_config_key
        ) and operations.is_current_profile(elem)
    then
        elem.children.slinger:set_hide_slinger_empty(
            elem_config.children.slinger.hide_slinger_empty
        )
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_sharpness(elem, elem_config, config_key)
    ---@cast elem_config SharpnessConfig
    ---@cast elem Sharpness

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_state_behavior"))
    local item_config_key = config_key .. ".state"
    local values = util_table.extend(
        { config.lang:tr("hud.option_disable") },
        util_table.values(mod.map.slider_sharpness_state, function(o)
            return config.lang:tr("hud_element.entry." .. o)
        end)
    )

    if
        set:slider_list(
            util_gui.tr("hud_element.entry.state"),
            item_config_key,
            -1,
            #mod.map.slider_sharpness_state - 1,
            values
        ) and operations.is_current_profile(elem)
    then
        elem:set_state(elem_config.state)
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_clock(elem, elem_config, config_key)
    ---@cast elem_config ClockConfig
    ---@cast elem Clock

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_clock_behavior"))
    local item_config_key = config_key .. ".hide_map_visible"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_hide_map_visible", item_config_key),
            item_config_key
        ) and operations.is_current_profile(elem)
    then
        elem:set_hide_map_visible(elem_config.hide_map_visible)
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_shortcut_keyboard(elem, elem_config, config_key)
    ---@cast elem_config ShortcutKeyboardConfig
    ---@cast elem ShortcutKeyboard

    util_imgui.separator_text(
        config.lang:tr("hud_element.entry.category_shortcut_keyboard_behavior")
    )
    local item_config_key = config_key .. ".no_hide_elements"
    local is_current_profile = operations.is_current_profile(elem)
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_no_hide_elements", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem:set_no_hide_elements(elem_config.no_hide_elements)
    end
    util_imgui.tooltip(
        config.lang:tr("hud_element.entry.tooltip_keyboard_shortcut_only_one_row"),
        true
    )

    item_config_key = config_key .. ".always_visible"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_always_visible", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem:set_always_visible(elem_config.always_visible)
    end
    util_imgui.tooltip(
        config.lang:tr("hud_element.entry.tooltip_keyboard_shortcut_only_one_row"),
        true
    )
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_minimap(elem, elem_config, config_key)
    ---@cast elem_config MinimapConfig
    ---@cast elem Minimap

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

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_stamina(elem, elem_config, config_key)
    ---@cast elem_config StaminaConfig
    ---@cast elem Stamina

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_extra_bar_behavior"))
    local item_config_key = config_key .. ".children.ex.hide_pulse"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_hide_pulse", item_config_key),
            item_config_key
        ) and operations.is_current_profile(elem)
    then
        elem.children.ex:set_hide_pulse(elem_config.children.ex.hide_pulse)
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
function this.draw(elem, elem_config, config_key)
    local f = this.funcs[
        elem_config.hud_type --[[@as HudType]]
    ]
    if f then
        f(elem, elem_config, config_key)
    end
end

this.funcs[mod.enum.hud_type.WEAPON] = draw_weapon
this.funcs[mod.enum.hud_type.ITEMBAR] = draw_itembar
this.funcs[mod.enum.hud_type.NOTICE] = draw_notice
this.funcs[mod.enum.hud_type.NAME_ACCESS] = draw_name_access
this.funcs[mod.enum.hud_type.NAME_OTHER] = draw_name_other
this.funcs[mod.enum.hud_type.AMMO] = draw_ammo
this.funcs[mod.enum.hud_type.RADIAL] = draw_radial
this.funcs[mod.enum.hud_type.SLINGER_RETICLE] = draw_slinger_reticle
this.funcs[mod.enum.hud_type.SHARPNESS] = draw_sharpness
this.funcs[mod.enum.hud_type.CLOCK] = draw_clock
this.funcs[mod.enum.hud_type.SHORTCUT_KEYBOARD] = draw_shortcut_keyboard
this.funcs[mod.enum.hud_type.MINIMAP] = draw_minimap
this.funcs[mod.enum.hud_type.STAMINA] = draw_stamina

return this
