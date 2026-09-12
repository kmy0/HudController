local config = require("HudController.config.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local m = require("HudController.util.ref.methods")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")

local set = state.set

---@param elem Notice
---@param elem_config NoticeConfig
---@param config_key string
return function(elem, elem_config, config_key)
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

    generic.combo_hide(
        elem,
        config_key .. ".system_log",
        config.lang:tr("hud_element.entry.combo_notice_system"),
        "system_log",
        elem.set_system_log,
        is_current_profile
    )

    generic.combo_hide(
        elem,
        config_key .. ".enemy_log",
        config.lang:tr("hud_element.entry.combo_notice_enemy"),
        "enemy_log",
        elem.set_enemy_log,
        is_current_profile
    )

    generic.combo_hide(
        elem,
        config_key .. ".camp_log",
        config.lang:tr("hud_element.entry.combo_notice_camp"),
        "camp_log",
        elem.set_camp_log,
        is_current_profile
    )

    generic.combo_hide(
        elem,
        config_key .. ".chat_log",
        config.lang:tr("hud_element.entry.combo_notice_lobby"),
        "chat_log",
        elem.set_chat_log,
        is_current_profile
    )

    generic.combo_hide(
        elem,
        config_key .. ".lobby_log",
        config.lang:tr("hud_element.entry.combo_notice_lobby_target"),
        "lobby_log",
        elem.set_lobby_log,
        is_current_profile
    )

    generic.combo_hide(
        elem,
        config_key .. ".auto_id",
        config.lang:tr("hud_element.entry.combo_notice_auto_id"),
        "auto_id",
        elem.set_auto_id,
        is_current_profile
    )

    generic.combo_hide(
        elem,
        config_key .. ".log_id",
        config.lang:tr("hud_element.entry.combo_notice_system_id"),
        "log_id",
        elem.set_log_id,

        is_current_profile
    )
end
