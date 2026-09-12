local config = require("HudController.config.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local set = state.set

---
---@param elem Subtitles
---@param key string
---@param item_config_key string
---@param is_current_profile boolean
local function mute_sfx(elem, key, item_config_key, is_current_profile)
    local order = 0

    for _, o in
        pairs(config:get(item_config_key) --[[@as table<string, integer>]])
    do
        order = math.max(order, o + 1)
    end

    if is_current_profile and not elem.mute_sfx[key] then
        elem:set_mute_sfx(key, order)
    end

    if not config:get(item_config_key)[key] then
        config:set(string.format("%s.%s", item_config_key, key), order)
    end
end

---@param elem Subtitles
---@param elem_config SubtitlesConfig
---@param config_key string
return function(elem, elem_config, config_key)
    local is_current_profile = operations.is_current_profile(elem)

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_tools"))

    local item_config_key = config_key .. ".cache_subtitles"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_cache_subtitles", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem:set_cache_subtitles(elem_config.cache_subtitles)
    end

    imgui.same_line()
    if imgui.button(util_gui.tr("hud_element.entry.button_clear", item_config_key)) then
        elem.subtitles_cache:clear()
    end

    if elem_config.cache_subtitles then
        if
            imgui.begin_table(
                "subtitles_cached_subtitles",
                7,
                1 << 8 | 1 << 7 | 1 << 10 | 1 << 13 | 1 << 25 --[[@as ImGuiTableFlags]],
                Vector2f.new(0, 4 * (config.lang.font_size * (46 / 16)))
            )
        then
            for _, header in ipairs({
                config.lang:tr("misc.text_row"),
                config.lang:tr("misc.text_talker"),
                config.lang:tr("misc.text_talker_type"),
                config.lang:tr("misc.text_type"),
                config.lang:tr("misc.text_child_element"),
                config.lang:tr("misc.text_message"),
            }) do
                imgui.table_setup_column(header)
            end

            imgui.table_headers_row()
            for i = #elem.subtitles_cache, 1, -1 do
                imgui.table_next_row()
                local entry = elem.subtitles_cache[i]

                imgui.table_set_column_index(0)
                imgui.text(i)

                imgui.table_set_column_index(1)
                imgui.text(entry.npc)

                imgui.table_set_column_index(2)
                imgui.text(entry.talker_type)

                imgui.table_set_column_index(3)
                imgui.text(entry.type)

                imgui.table_set_column_index(4)
                imgui.text(entry.cls)

                imgui.table_set_column_index(5)
                imgui.text(util_misc.trunc_string(entry.text))
                util_imgui.tooltip(entry.text)
            end

            imgui.end_table()
        end
    end

    item_config_key = config_key .. ".cache_sfx"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_cache_sfx", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem:set_cache_sfx(elem_config.cache_sfx)
    end

    imgui.same_line()
    if imgui.button(util_gui.tr("hud_element.entry.button_clear", item_config_key)) then
        elem.sfx_cache:clear()
    end

    imgui.same_line()
    if
        imgui.button(
            elem.cache_sfx_pause and util_gui.tr("hud_element.entry.button_resume", item_config_key)
                or util_gui.tr("hud_element.entry.button_pause", item_config_key)
        )
    then
        elem.cache_sfx_pause = not elem.cache_sfx_pause
    end

    imgui.same_line()
    imgui.set_next_item_width(util_imgui.get_drag_with())
    item_config_key = config_key .. ".cache_sfx_cooldown"
    set:drag_int(
        util_gui.tr("hud_element.entry.drag_sfx_cooldown", item_config_key),
        item_config_key,
        0.2,
        0,
        30
    )

    if elem_config.cache_sfx then
        if
            imgui.begin_table(
                "subtitles_cached_sfx",
                5,
                1 << 8 | 1 << 7 | 1 << 10 | 1 << 13 | 1 << 25 --[[@as ImGuiTableFlags]],
                Vector2f.new(0, 4 * (config.lang.font_size * (46 / 16)))
            )
        then
            for _, header in ipairs({
                config.lang:tr("misc.text_row"),
                "##mute_game_object",
                config.lang:tr("misc.text_game_object"),
                "##mute_id",
                config.lang:tr("misc.text_id"),
            }) do
                imgui.table_setup_column(header)
            end

            imgui.table_headers_row()
            for i = #elem.sfx_cache, 1, -1 do
                imgui.table_next_row()
                local entry = elem.sfx_cache[i]

                imgui.table_set_column_index(0)
                imgui.text(i)

                imgui.table_set_column_index(1)
                if
                    imgui.button(
                        util_gui.tr("hud_element.entry.button_mute_game_object", config_key, i)
                    )
                then
                    mute_sfx(elem, entry.game_object, config_key .. ".mute_sfx", is_current_profile)
                end

                imgui.table_set_column_index(2)
                imgui.text(entry.game_object)

                imgui.table_set_column_index(3)
                if imgui.button(util_gui.tr("hud_element.entry.button_mute_id", config_key, i)) then
                    mute_sfx(elem, entry.event_id, config_key .. ".mute_sfx", is_current_profile)
                end

                imgui.table_set_column_index(4)
                imgui.text(entry.event_id)
            end

            imgui.end_table()
        end
    end

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_hide"))
    generic.combo_hide(
        elem,
        config_key .. ".hide_subtitles",
        config.lang:tr("hud_element.entry.combo_subtitles"),
        "hide_subtitles",
        elem.set_hide_subtitles,
        is_current_profile,
        "subtitles"
    )

    generic.combo_hide(
        elem,
        config_key .. ".hide_npc_id",
        config.lang:tr("hud_element.entry.combo_npc"),
        "hide_npc_id",
        elem.set_hide_npc_id,
        is_current_profile,
        "npc"
    )

    generic.combo_hide(
        elem,
        config_key .. ".hide_dialogue_type",
        config.lang:tr("hud_element.entry.combo_dialogue_type"),
        "hide_dialogue_type",
        elem.set_hide_dialogue_type,
        is_current_profile,
        "dialogue_type"
    )

    generic.combo_hide(
        elem,
        config_key .. ".hide_dialogue_actor_type",
        config.lang:tr("hud_element.entry.combo_dialogue_actor_type"),
        "hide_dialogue_actor_type",
        elem.set_hide_dialogue_actor_type,
        is_current_profile,
        "dialogue_actor_type"
    )

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_subtitles_mute"))
    generic.combo_hide(
        elem,
        config_key .. ".mute_subtitles",
        config.lang:tr("hud_element.entry.combo_subtitles"),
        "mute_subtitles",
        elem.set_mute_subtitles,
        is_current_profile,
        "subtitles",
        "hud_element.entry.button_mute"
    )

    generic.combo_hide(
        elem,
        config_key .. ".mute_npc_id",
        config.lang:tr("hud_element.entry.combo_npc"),
        "mute_npc_id",
        elem.set_mute_npc_id,
        is_current_profile,
        "npc",
        "hud_element.entry.button_mute"
    )

    generic.combo_hide(
        elem,
        config_key .. ".mute_dialogue_type",
        config.lang:tr("hud_element.entry.combo_dialogue_type"),
        "mute_dialogue_type",
        elem.set_mute_dialogue_type,
        is_current_profile,
        "dialogue_type",
        "hud_element.entry.button_mute"
    )

    generic.combo_hide(
        elem,
        config_key .. ".mute_dialogue_actor_type",
        config.lang:tr("hud_element.entry.combo_dialogue_actor_type"),
        "mute_dialogue_actor_type",
        elem.set_mute_dialogue_actor_type,
        is_current_profile,
        "dialogue_actor_type",
        "hud_element.entry.button_mute"
    )

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_mute_sfx"))
    imgui.set_next_item_width(
        util_imgui.get_something_with_button_width(config.lang:tr("hud_element.entry.button_mute"))
    )
    set:input_text("##mute_sfx_input", config_key .. ".mute_sfx_input")
    imgui.same_line()
    if
        imgui.button(util_gui.tr("hud_element.entry.button_mute", config_key .. ".mute_sfx_input"))
    then
        local txt = config:get(config_key .. ".mute_sfx_input")
        if txt then
            mute_sfx(elem, txt, config_key .. ".mute_sfx", is_current_profile)
        end
    end

    item_config_key = config_key .. ".mute_sfx"
    generic.child_window_thing_remove(
        "entries_subtitles_mute_sfx",
        util_table.size(elem.mute_sfx),
        function()
            if
                imgui.button(
                    util_gui.tr("hud_element.entry.button_remove_all", config_key, "mute_sfx")
                )
            then
                if is_current_profile then
                    elem.mute_sfx = {}
                end

                config:set(item_config_key, {})
            end

            local keys = util_table.sort(
                util_table.entries(config:get(item_config_key) --[[@as table<string, integer>]]),
                function(a, b)
                    return a.value < b.value
                end
            )

            for i, map in ipairs(keys) do
                if
                    imgui.button(
                        util_gui.tr("hud_element.entry.button_remove", item_config_key, i, map.key)
                    )
                then
                    if is_current_profile then
                        elem:set_mute_sfx(map.key, nil)
                    end

                    config:set(string.format("%s.%s", item_config_key, map.key), nil)
                end

                imgui.same_line()
                imgui.text(map.key)
            end
        end
    )
end
