local config = require("HudController.config")
local generic = require("HudController.gui.elements.profile.panel.generic")
local gui_util = require("HudController.gui.util")
local hud = require("HudController.hud")
local operations = require("HudController.hud.operations")
local panel = require("HudController.gui.elements.profile.panel")
local set = require("HudController.gui.set")
local state = require("HudController.gui.state")
local util_imgui = require("HudController.util.imgui")
local util_table = require("HudController.util.misc.table")

local this = {}
---@type HudBaseConfig?
local drag

---@param changed boolean
---@param key string
---@return boolean
local function check_overriden(changed, key)
    if changed then
        hud.clear_overridden(key)
    end

    local val = hud.get_overridden(key)
    if val ~= nil then
        imgui.same_line()
        imgui.text(string.format("(%s %s)", config.lang.tr("misc.text_overridden"), val))
    end
    return changed
end

---@param label string
---@param boxes string[]
---@return boolean
local function boxes_to_slider(label, boxes)
    local value = 0
    local display = config.lang.tr("hud.option_disable")
    for i = 1, #boxes do
        if config.get(string.format("mod.hud.int:%s.%s", config.current.mod.combo_hud, boxes[i])) then
            value = i
            display = config.lang.tr("hud.box_" .. boxes[i])
            break
        end
    end

    local changed, value = imgui.slider_int(label, value, 0, #boxes, display)
    if changed then
        for i = 1, #boxes do
            config.set(string.format("mod.hud.int:%s.%s", config.current.mod.combo_hud, boxes[i]), false)
            hud.clear_overridden(boxes[i])
        end

        if value ~= 0 then
            config.set(string.format("mod.hud.int:%s.%s", config.current.mod.combo_hud, boxes[value]), true)
        end
    end

    ---@type boolean[]
    local ov_bools = {}
    for i = 1, #boxes do
        local val = hud.get_overridden(boxes[i])
        if val == nil then
            break
        end

        table.insert(ov_bools, val)
    end

    local any_true = util_table.index(ov_bools, function(o)
        return o == true
    end)

    if any_true then
        imgui.same_line()
        imgui.text(
            string.format(
                "(%s %s)",
                config.lang.tr("misc.text_overridden"),
                config.lang.tr("hud.box_" .. boxes[any_true])
            )
        )
    elseif
        not util_table.empty(ov_bools)
        and util_table.all(ov_bools, function(o)
            return o == false
        end)
    then
        imgui.same_line()
        imgui.text(
            string.format("(%s %s)", config.lang.tr("misc.text_overridden"), config.lang.tr("hud.option_disable"))
        )
    end

    return changed
end

local function draw_options()
    util_imgui.separator_text(config.lang.tr("hud.category_general"))
    local changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_mute_gui"),
            string.format("mod.hud.int:%s.mute_gui", config.current.mod.combo_hud)
        ),
        "mute_gui"
    )
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_hide_subtitles"),
            string.format("mod.hud.int:%s.hide_subtitles", config.current.mod.combo_hud)
        ),
        "hide_subtitles"
    ) or changed

    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_disable_area_intro"),
            string.format("mod.hud.int:%s.disable_area_intro", config.current.mod.combo_hud)
        ),
        "disable_area_intro"
    ) or changed

    util_imgui.separator_text(config.lang.tr("hud.category_player"))
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_disable_focus_turn"),
            string.format("mod.hud.int:%s.disable_focus_turn", config.current.mod.combo_hud)
        ),
        "disable_focus_turn"
    ) or changed
    local box = set.checkbox(
        gui_util.tr("hud.box_hide_danger"),
        string.format("mod.hud.int:%s.hide_danger", config.current.mod.combo_hud)
    )
    util_imgui.tooltip(config.lang.tr("hud.tooltip_hide_danger"), true)
    changed = check_overriden(box, "hide_danger") or changed
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_disable_scoutflies"),
            string.format("mod.hud.int:%s.disable_scoutflies", config.current.mod.combo_hud)
        ),
        "disable_scoutflies"
    ) or changed
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_hide_weapon"),
            string.format("mod.hud.int:%s.hide_weapon", config.current.mod.combo_hud)
        ),
        "hide_weapon"
    ) or changed
    util_imgui.tooltip(config.lang.tr("hud.tooltip_hide_weapon"), true)

    util_imgui.separator_text(config.lang.tr("hud.category_npc"))
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_hide_handler"),
            string.format("mod.hud.int:%s.hide_handler", config.current.mod.combo_hud)
        ),
        "hide_handler"
    ) or changed
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_hide_pet"),
            string.format("mod.hud.int:%s.hide_pet", config.current.mod.combo_hud)
        ),
        "hide_pet"
    ) or changed
    util_imgui.tooltip(config.lang.tr("hud.tooltip_hide_pet"), true)

    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_hide_no_facility_npc"),
            string.format("mod.hud.int:%s.hide_no_facility_npc", config.current.mod.combo_hud)
        ),
        "hide_no_facility_npc"
    ) or changed

    imgui.begin_disabled(hud.get_hud_option("hide_no_facility_npc"))
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_hide_no_talk_npc"),
            string.format("mod.hud.int:%s.hide_no_talk_npc", config.current.mod.combo_hud)
        ),
        "hide_no_talk_npc"
    ) or changed
    imgui.end_disabled()

    util_imgui.separator_text(config.lang.tr("hud.category_monster"))
    changed = boxes_to_slider(gui_util.tr("hud.slider_wound_state"), { "hide_scar", "show_scar", "disable_scar" })
        or changed
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_hide_small_monsters"),
            string.format("mod.hud.int:%s.hide_small_monsters", config.current.mod.combo_hud)
        ),
        "hide_small_monsters"
    ) or changed
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_monster_ignore_camp"),
            string.format("mod.hud.int:%s.monster_ignore_camp", config.current.mod.combo_hud)
        ),
        "monster_ignore_camp"
    ) or changed
    util_imgui.tooltip(config.lang.tr("hud.tooltip_monster_ignore_camp"), true)
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_hide_monster_icon"),
            string.format("mod.hud.int:%s.hide_monster_icon", config.current.mod.combo_hud)
        ),
        "hide_monster_icon"
    ) or changed
    util_imgui.tooltip(config.lang.tr("hud.tooltip_hide_monster_icon"), true)

    imgui.begin_disabled(not hud.get_hud_option("hide_monster_icon"))

    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_hide_lock_target"),
            string.format("mod.hud.int:%s.hide_lock_target", config.current.mod.combo_hud)
        ),
        "hide_lock_target"
    ) or changed
    util_imgui.tooltip(config.lang.tr("hud.tooltip_hide_lock_target"), true)

    imgui.end_disabled()

    util_imgui.separator_text(config.lang.tr("hud.category_quest"))
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_disable_quest_intro"),
            string.format("mod.hud.int:%s.disable_quest_intro", config.current.mod.combo_hud)
        ),
        "disable_quest_intro"
    ) or changed
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_disable_quest_end_camera"),
            string.format("mod.hud.int:%s.disable_quest_end_camera", config.current.mod.combo_hud)
        ),
        "disable_quest_end_camera"
    ) or changed
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_disable_quest_end_outro"),
            string.format("mod.hud.int:%s.disable_quest_end_outro", config.current.mod.combo_hud)
        ),
        "disable_quest_end_outro"
    ) or changed
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_skip_quest_end_timer"),
            string.format("mod.hud.int:%s.skip_quest_end_timer", config.current.mod.combo_hud)
        ),
        "skip_quest_end_timer"
    ) or changed
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_hide_quest_end_timer"),
            string.format("mod.hud.int:%s.hide_quest_end_timer", config.current.mod.combo_hud)
        ),
        "hide_quest_end_timer"
    ) or changed
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_skip_quest_result"),
            string.format("mod.hud.int:%s.skip_quest_result", config.current.mod.combo_hud)
        ),
        "skip_quest_result"
    ) or changed
    util_imgui.tooltip(config.lang.tr("hud.tooltip_skip_quest_result"), true)

    util_imgui.separator_text(config.lang.tr("hud.category_porter"))
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_disable_porter_call"),
            string.format("mod.hud.int:%s.disable_porter_call", config.current.mod.combo_hud)
        ),
        "disable_porter_call"
    ) or changed
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_hide_porter"),
            string.format("mod.hud.int:%s.hide_porter", config.current.mod.combo_hud)
        ),
        "hide_porter"
    ) or changed
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_disable_porter_tracking"),
            string.format("mod.hud.int:%s.disable_porter_tracking", config.current.mod.combo_hud)
        ),
        "disable_porter_tracking"
    ) or changed

    util_imgui.separator_text(config.lang.tr("hud.category_profile"))
    changed = set.checkbox(
        gui_util.tr("hud.box_show_notification"),
        string.format("mod.hud.int:%s.show_notification", config.current.mod.combo_hud)
    ) or changed
    util_imgui.tooltip(config.lang.tr("hud.tooltip_show_notification"), true)

    util_imgui.separator_text(config.lang.tr("hud.category_fade"))
    changed = set.checkbox(
        gui_util.tr("hud.box_fade_opacity"),
        string.format("mod.hud.int:%s.fade_opacity", config.current.mod.combo_hud)
    ) or changed

    imgui.same_line()
    imgui.begin_disabled(not config.get(string.format("mod.hud.int:%s.fade_opacity", config.current.mod.combo_hud)))

    changed = set.checkbox(
        gui_util.tr("hud.box_fade_opacity_both"),
        string.format("mod.hud.int:%s.fade_opacity_both", config.current.mod.combo_hud)
    ) or changed

    imgui.end_disabled()
    util_imgui.tooltip(config.lang.tr("hud.tooltip_fade_opacity_both"), true)

    local item_config_key = string.format("mod.hud.int:%s.fade_in", config.current.mod.combo_hud)
    local item_value = config.get(item_config_key)
    changed = set.slider_float(
        gui_util.tr("hud.slider_fade_in"),
        item_config_key,
        0,
        10,
        item_value == 0 and config.lang.tr("misc.text_disabled")
            or gui_util.seconds_to_minutes_string(item_value, "%.1f")
    ) or changed

    item_config_key = string.format("mod.hud.int:%s.fade_out", config.current.mod.combo_hud)
    item_value = config.get(item_config_key)
    changed = set.slider_float(
        gui_util.tr("hud.slider_fade_out"),
        item_config_key,
        0,
        10,
        item_value == 0 and config.lang.tr("misc.text_disabled")
            or gui_util.seconds_to_minutes_string(item_value, "%.1f")
    ) or changed

    if changed then
        config.save()
    end

    if not util_table.empty(config.current.mod.hud[config.current.mod.combo_hud].options) then
        util_imgui.separator_text(config.lang.tr("hud_element.entry.category_ingame_settings"))

        local sorted = util_table.sort(util_table.keys(config.current.mod.hud[config.current.mod.combo_hud].options))
        ---@cast sorted string[]
        generic.draw_options(
            sorted,
            string.format("mod.hud.int:%s.options", config.current.mod.combo_hud),
            function(option_key, option_config_key)
                hud.apply_option(option_key, config.get(option_config_key))
                config.save()
            end
        )
    end
end

local function draw_elements()
    local elements = config.current.mod.hud[config.current.mod.combo_hud].elements or {}
    local sorted = util_table.sort(util_table.values(elements), function(a, b)
        return a.key > b.key
    end)

    util_imgui.spacer(0, 1)

    ---@type string[]
    local remove = {}
    ---@type table<HudBaseConfig, number>
    local elem_pos = {}
    for i = 1, #sorted do
        local elem_config = sorted[i]
        local elem = hud.get_element(elem_config.hud_id)

        if not elem then
            goto continue
        end

        local config_key =
            string.format("mod.hud.int:%s.elements.%s", config.current.mod.combo_hud, elem_config.name_key)
        local start_pos = imgui.get_cursor_screen_pos().y

        util_imgui.dummy_button(gui_util.tr("misc.text_drag", config_key))
        if not drag and imgui.is_item_hovered() and imgui.is_mouse_down(0) then
            drag = elem_config
        end

        imgui.same_line()

        if imgui.button(gui_util.tr("hud_element.button_remove", elem.name_key)) then
            table.insert(remove, elem.name_key)
        end

        imgui.same_line()

        local name = operations.tr_element(elem_config)
        local header = imgui.collapsing_header(string.format("%s##%s_header", name, elem.name_key))
        local end_pos = imgui.get_cursor_screen_pos().y

        if drag == elem_config then
            util_imgui.highlight(state.colors.info, 0, -(end_pos - start_pos))
        end

        if header then
            panel.draw(elem, elem_config, config_key)
        end

        if drag == elem_config then
            elem_pos[elem_config] = imgui.get_mouse().y
        else
            elem_pos[elem_config] = start_pos
        end

        ::continue::
    end

    imgui.spacing()

    if drag and imgui.is_mouse_released(0) then
        drag = nil
        config.save()
    elseif drag then
        for i, elem in
            pairs(util_table.sort(util_table.values(elements), function(a, b)
                return elem_pos[a] > elem_pos[b]
            end))
        do
            elem.key = i
        end
    end

    if not util_table.empty(remove) then
        for _, name_key in pairs(remove) do
            elements[name_key] = nil
        end

        hud.update_elements(elements)
        config.save()
    end
end

function this.draw()
    if not util_table.empty(config.current.mod.hud) then
        local header = imgui.collapsing_header(gui_util.tr("hud.header_hud_options"))
        if header then
            imgui.begin_child_window("hud_elements_child_window", { -1, -1 }, false)
            draw_options()
            imgui.spacing()
            imgui.end_child_window()
        else
            imgui.separator()
            imgui.begin_child_window("hud_elements_child_window1", { -1, -1 }, false)
            draw_elements()
            imgui.end_child_window()
        end
    end
end

return this
