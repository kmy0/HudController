local config = require("HudController.config")
local data = require("HudController.data")
local generic = require("HudController.gui.elements.profile.panel.generic")
local gui_util = require("HudController.gui.util")
local hud = require("HudController.hud")
local panel = require("HudController.gui.elements.profile.panel")
local set = require("HudController.gui.set")
local util_imgui = require("HudController.util.imgui")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map

local this = {}

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
            gui_util.tr("hud.box_disable_scoutflies"),
            string.format("mod.hud.int:%s.disable_scoutflies", config.current.mod.combo_hud)
        ),
        "disable_scoutflies"
    ) or changed
    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_hide_handler"),
            string.format("mod.hud.int:%s.hide_handler", config.current.mod.combo_hud)
        ),
        "hide_handler"
    ) or changed

    local box = set.checkbox(
        gui_util.tr("hud.box_hide_danger"),
        string.format("mod.hud.int:%s.hide_danger", config.current.mod.combo_hud)
    )
    util_imgui.tooltip(config.lang.tr("hud.tooltip_hide_danger"), true)
    changed = check_overriden(box, "hide_danger") or changed

    changed = check_overriden(
        set.checkbox(
            gui_util.tr("hud.box_disable_area_intro"),
            string.format("mod.hud.int:%s.disable_area_intro", config.current.mod.combo_hud)
        ),
        "disable_area_intro"
    ) or changed

    util_imgui.separator_text(config.lang.tr("hud.category_monster"))
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

    changed = set.slider_float(
        gui_util.tr("hud.slider_fade_in"),
        string.format("mod.hud.int:%s.fade_in", config.current.mod.combo_hud),
        0,
        10,
        "%.1f"
    ) or changed
    changed = set.slider_float(
        gui_util.tr("hud.slider_fade_out"),
        string.format("mod.hud.int:%s.fade_out", config.current.mod.combo_hud),
        0,
        10,
        "%.1f"
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
    ---@type string[]
    local remove = {}

    for i = 1, #sorted do
        local elem_config = sorted[i]
        local elem = hud.get_element(elem_config.hud_id)

        if not elem then
            goto continue
        end

        local config_key =
            string.format("mod.hud.int:%s.elements.%s", config.current.mod.combo_hud, elem_config.name_key)

        if imgui.button(gui_util.tr("hud_element.button_remove", elem.name_key)) then
            table.insert(remove, elem.name_key)
        end

        imgui.same_line()

        local name = ace_map.hudid_name_to_local_name[elem.name_key]
        if name == ace_map.hud_tr_flag then
            name = config.lang.tr("hud_element.name." .. elem.name_key)
        end

        if imgui.collapsing_header(string.format("%s##%s_header", name, elem.name_key)) then
            panel.draw(elem, elem_config, config_key)
        end

        ::continue::
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
        if imgui.collapsing_header(gui_util.tr("hud.header_hud_options")) then
            draw_options()
        end

        draw_elements()
    end
end

return this
