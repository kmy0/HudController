local config = require("HudController.config.init")
local data = require("HudController.data.init")
local drag_util = require("HudController.gui.drag")
local factory = require("HudController.hud.factory")
local generic = require("HudController.gui.elements.profile.panel.generic")
local gui_util = require("HudController.gui.util")
local hook = require("HudController.hud.hook.init")
local hud = require("HudController.hud.init")
local operations = require("HudController.hud.operations")
local panel = require("HudController.gui.elements.profile.panel.init")
local state = require("HudController.gui.state")
local util_imgui = require("HudController.util.imgui.init")
local util_table = require("HudController.util.misc.table")

local set = state.set
local ace_map = data.ace.map

local this = {}
local drag = drag_util:new()
local dummy_hud = factory.get_hud_profile_config(-1, "__dummy")

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
        imgui.text(string.format("(%s %s)", config.lang:tr("misc.text_overridden"), val))
    end
    return changed
end

---@param label string
---@param boxes string[]
---@return boolean
local function boxes_to_slider(label, boxes)
    local config_mod = config.current.mod
    local value = 0
    local display = config.lang:tr("hud.option_disable")
    for i = 1, #boxes do
        if config:get(string.format("mod.hud.int:%s.%s", config_mod.combo.hud, boxes[i])) then
            value = i
            display = config.lang:tr("hud.box_" .. boxes[i])
            break
        end
    end

    local changed, value = imgui.slider_int(label, value, 0, #boxes, display)
    if changed then
        for i = 1, #boxes do
            config:set(string.format("mod.hud.int:%s.%s", config_mod.combo.hud, boxes[i]), false)
            hud.clear_overridden(boxes[i])
        end

        if value ~= 0 then
            config:set(string.format("mod.hud.int:%s.%s", config_mod.combo.hud, boxes[value]), true)
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
                config.lang:tr("misc.text_overridden"),
                config.lang:tr("hud.box_" .. boxes[any_true])
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
            string.format(
                "(%s %s)",
                config.lang:tr("misc.text_overridden"),
                config.lang:tr("hud.option_disable")
            )
        )
    end

    return changed
end

local function draw_options()
    local config_mod = config.current.mod

    util_imgui.separator_text(config.lang:tr("hud.category_general"))
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_mute_gui"),
            string.format("mod.hud.int:%s.mute_gui", config_mod.combo.hud)
        ),
        "mute_gui"
    )
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_hide_subtitles"),
            string.format("mod.hud.int:%s.hide_subtitles", config_mod.combo.hud)
        ),
        "hide_subtitles"
    )
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_mute_gossip"),
            string.format("mod.hud.int:%s.mute_gossip", config_mod.combo.hud)
        ),
        "mute_gossip"
    )
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_disable_area_intro"),
            string.format("mod.hud.int:%s.disable_area_intro", config_mod.combo.hud)
        ),
        "disable_area_intro"
    )

    util_imgui.separator_text(config.lang:tr("hud.category_player"))
    local box = set:checkbox(
        gui_util.tr("hud.box_hide_danger"),
        string.format("mod.hud.int:%s.hide_danger", config_mod.combo.hud)
    )
    util_imgui.tooltip(config.lang:tr("hud.tooltip_hide_danger"), true)
    check_overriden(box, "hide_danger")
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_hide_aggro"),
            string.format("mod.hud.int:%s.hide_aggro", config_mod.combo.hud)
        ),
        "hide_aggro"
    )
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_disable_scoutflies"),
            string.format("mod.hud.int:%s.disable_scoutflies", config_mod.combo.hud)
        ),
        "disable_scoutflies"
    )
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_hide_weapon"),
            string.format("mod.hud.int:%s.hide_weapon", config_mod.combo.hud)
        ),
        "hide_weapon"
    )
    util_imgui.tooltip(config.lang:tr("hud.tooltip_hide_weapon"), true)

    util_imgui.separator_text(config.lang:tr("hud.category_npc"))
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_hide_handler"),
            string.format("mod.hud.int:%s.hide_handler", config_mod.combo.hud)
        ),
        "hide_handler"
    )
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_hide_pet"),
            string.format("mod.hud.int:%s.hide_pet", config_mod.combo.hud)
        ),
        "hide_pet"
    )
    util_imgui.tooltip(config.lang:tr("hud.tooltip_hide_pet"), true)

    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_hide_no_facility_npc"),
            string.format("mod.hud.int:%s.hide_no_facility_npc", config_mod.combo.hud)
        ),
        "hide_no_facility_npc"
    )

    imgui.begin_disabled(hud.get_hud_option("hide_no_facility_npc"))
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_hide_no_talk_npc"),
            string.format("mod.hud.int:%s.hide_no_talk_npc", config_mod.combo.hud)
        ),
        "hide_no_talk_npc"
    )
    imgui.end_disabled()

    util_imgui.separator_text(config.lang:tr("hud.category_monster"))
    boxes_to_slider(
        gui_util.tr("hud.slider_wound_state"),
        { "hide_scar", "show_scar", "disable_scar" }
    )
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_hide_small_monsters"),
            string.format("mod.hud.int:%s.hide_small_monsters", config_mod.combo.hud)
        ),
        "hide_small_monsters"
    )
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_monster_ignore_camp"),
            string.format("mod.hud.int:%s.monster_ignore_camp", config_mod.combo.hud)
        ),
        "monster_ignore_camp"
    )
    util_imgui.tooltip(config.lang:tr("hud.tooltip_monster_ignore_camp"), true)
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_hide_monster_icon"),
            string.format("mod.hud.int:%s.hide_monster_icon", config_mod.combo.hud)
        ),
        "hide_monster_icon"
    )
    util_imgui.tooltip(config.lang:tr("hud.tooltip_hide_monster_icon"), true)

    imgui.begin_disabled(not hud.get_hud_option("hide_monster_icon"))

    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_hide_lock_target"),
            string.format("mod.hud.int:%s.hide_lock_target", config_mod.combo.hud)
        ),
        "hide_lock_target"
    )
    util_imgui.tooltip(config.lang:tr("hud.tooltip_hide_lock_target"), true)

    imgui.end_disabled()

    util_imgui.separator_text(config.lang:tr("hud.category_quest"))
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_disable_quest_intro"),
            string.format("mod.hud.int:%s.disable_quest_intro", config_mod.combo.hud)
        ),
        "disable_quest_intro"
    )
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_disable_quest_end_camera"),
            string.format("mod.hud.int:%s.disable_quest_end_camera", config_mod.combo.hud)
        ),
        "disable_quest_end_camera"
    )
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_disable_quest_end_outro"),
            string.format("mod.hud.int:%s.disable_quest_end_outro", config_mod.combo.hud)
        ),
        "disable_quest_end_outro"
    )
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_skip_quest_end_timer"),
            string.format("mod.hud.int:%s.skip_quest_end_timer", config_mod.combo.hud)
        ),
        "skip_quest_end_timer"
    )
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_hide_quest_end_timer"),
            string.format("mod.hud.int:%s.hide_quest_end_timer", config_mod.combo.hud)
        ),
        "hide_quest_end_timer"
    )
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_skip_quest_result"),
            string.format("mod.hud.int:%s.skip_quest_result", config_mod.combo.hud)
        ),
        "skip_quest_result"
    )
    util_imgui.tooltip(config.lang:tr("hud.tooltip_skip_quest_result"), true)

    util_imgui.separator_text(config.lang:tr("hud.category_porter"))
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_disable_porter_call"),
            string.format("mod.hud.int:%s.disable_porter_call", config_mod.combo.hud)
        ),
        "disable_porter_call"
    )
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_hide_porter"),
            string.format("mod.hud.int:%s.hide_porter", config_mod.combo.hud)
        ),
        "hide_porter"
    )
    check_overriden(
        set:checkbox(
            gui_util.tr("hud.box_disable_porter_tracking"),
            string.format("mod.hud.int:%s.disable_porter_tracking", config_mod.combo.hud)
        ),
        "disable_porter_tracking"
    )

    util_imgui.separator_text(config.lang:tr("hud.category_profile"))
    set:checkbox(
        gui_util.tr("hud.box_show_notification"),
        string.format("mod.hud.int:%s.show_notification", config_mod.combo.hud)
    )
    util_imgui.tooltip(config.lang:tr("hud.tooltip_show_notification"), true)

    util_imgui.separator_text(config.lang:tr("hud.category_fade"))
    set:checkbox(
        gui_util.tr("hud.box_fade_opacity"),
        string.format("mod.hud.int:%s.fade_opacity", config_mod.combo.hud)
    )

    imgui.same_line()
    imgui.begin_disabled(
        not config:get(string.format("mod.hud.int:%s.fade_opacity", config_mod.combo.hud))
    )

    set:checkbox(
        gui_util.tr("hud.box_fade_opacity_both"),
        string.format("mod.hud.int:%s.fade_opacity_both", config_mod.combo.hud)
    )

    imgui.end_disabled()
    util_imgui.tooltip(config.lang:tr("hud.tooltip_fade_opacity_both"), true)

    local item_config_key = string.format("mod.hud.int:%s.fade_in", config_mod.combo.hud)
    local item_value = config:get(item_config_key)
    set:slider_float(
        gui_util.tr("hud.slider_fade_in"),
        item_config_key,
        0,
        10,
        item_value == 0 and config.lang:tr("misc.text_disabled")
            or gui_util.seconds_to_minutes_string(item_value, "%.1f")
    )

    item_config_key = string.format("mod.hud.int:%s.fade_out", config_mod.combo.hud)
    item_value = config:get(item_config_key)
    set:slider_float(
        gui_util.tr("hud.slider_fade_out"),
        item_config_key,
        0,
        10,
        item_value == 0 and config.lang:tr("misc.text_disabled")
            or gui_util.seconds_to_minutes_string(item_value, "%.1f")
    )

    if not util_table.empty(config_mod.hud[config_mod.combo.hud].options) then
        util_imgui.separator_text(config.lang:tr("hud_element.entry.category_ingame_settings"))

        local sorted = util_table.sort(
            util_table.remove(
                util_table.keys(config_mod.hud[config_mod.combo.hud].options),
                function(t, i, _)
                    return dummy_hud.options[t[i]] ~= nil and ace_map.option[t[i]] ~= nil
                end
            )
        )
        ---@cast sorted string[]
        generic.draw_options(
            sorted,
            string.format("mod.hud.int:%s.options", config_mod.combo.hud),
            function(option_key, option_config_key)
                hud.apply_option(option_key, config:get(option_config_key))
            end
        )
    end

    hook.hook_options(config_mod.hud[config_mod.combo.hud])
end

local function draw_elements()
    local config_mod = config.current.mod
    local elements = config_mod.hud[config_mod.combo.hud].elements or {}
    local sorted = util_table.sort(util_table.values(elements), function(a, b)
        return a.key > b.key
    end)

    util_imgui.spacer(0, 1)

    ---@type string[]
    local remove = {}
    drag:clear()
    for i = 1, #sorted do
        local elem_config = sorted[i]
        local elem = hud.get_element(elem_config.hud_id)
        local config_key =
            string.format("mod.hud.int:%s.elements.%s", config_mod.combo.hud, elem_config.name_key)

        drag:draw_drag_button(config_key, elem_config)
        imgui.same_line()

        if imgui.button(gui_util.tr("hud_element.button_remove", elem_config.name_key)) then
            table.insert(remove, elem_config.name_key)
        end

        imgui.same_line()

        local name = operations.tr_element(elem_config)

        if not elem then
            imgui.set_next_item_open(false)
        end

        local header =
            imgui.collapsing_header(string.format("%s##%s_header", name, elem_config.name_key))

        drag:check_drag_pos(elem_config)

        if header and elem then
            panel.draw(elem, elem_config, config_key)
        end
    end

    imgui.spacing()

    if drag:is_released() then
        config.save_global()
    elseif drag:is_drag() then
        for i, elem in
            pairs(util_table.sort(util_table.values(elements), function(a, b)
                return drag.item_pos[a] > drag.item_pos[b]
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
        config.save_global()
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
