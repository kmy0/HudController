local config = require("HudController.config.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")

local set = state.set

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
return function(elem, elem_config, config_key)
    ---@cast elem Subtitles
    ---@cast elem_config SubtitlesConfig

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
end
