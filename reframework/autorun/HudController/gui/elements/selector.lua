local config = require("HudController.config.init")
local config_set_base = require("HudController.util.imgui.config_set")
local data = require("HudController.data.init")
local gui_util = require("HudController.gui.util")
local hud = require("HudController.hud.init")
local state = require("HudController.gui.state")
local user = require("HudController.hud.user")
local util_imgui = require("HudController.util.imgui.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod
local set = config_set_base:new(config.selector)

local this = {
    is_opened = false,
    window_size = 48,
}

local function reinit()
    local config_mod = config.current.mod

    config.lang:change()
    data.get_weapon_bind_map(config.current)
    state.translate_combo()
    hud.manager.reinit()
    hud.operations.reload()
    state.reapply_win_pos()
    user.reinit()

    local new_hud = config_mod.hud[config_mod.combo.hud]
    if new_hud then
        hud.request_hud(new_hud, true)
    else
        hud.manager.clear()
    end
end

function this.close()
    this.is_opened = false
    mod.pause = false
    state.input_action = nil
end

function this.draw()
    local config_sel = config.selector.current

    imgui.spacing()
    imgui.indent(3)

    imgui.begin_child_window("selector_window", { 0, this.window_size }, false, 1 << 3)
    local pos = imgui.get_cursor_pos()

    imgui.push_item_width(200)
    if set:combo(gui_util.tr("selector.combo_config"), "combo_file", state.combo.config.values) then
        config.selector:swap()
        reinit()
    end
    imgui.pop_item_width()

    imgui.same_line()
    if imgui.button(gui_util.tr("selector.button_new")) then
        state.input_action = nil
        config.selector:new_file()
        state.combo.config:swap(config.selector.sorted)
    end

    imgui.same_line()
    if imgui.button(gui_util.tr("selector.button_rename")) then
        local name = state.combo.config:get_value(config_sel.combo_file)
        state.input_action = name ~= config.selector.default_name and name or ""
    end

    imgui.begin_disabled(util_table.size(config.selector.files) == 1)
    imgui.same_line()

    if imgui.button(gui_util.tr("selector.button_remove")) then
        state.input_action = nil
        util_imgui.open_popup("config_remove", 62, 30)
    end

    imgui.end_disabled()

    if
        util_imgui.popup_yesno(
            "config_remove",
            config.lang:tr("misc.text_rusure"),
            config.lang:tr("misc.text_yes"),
            config.lang:tr("misc.text_no")
        )
    then
        if config.selector:delete_current_file() then
            state.combo.config:swap(config.selector.sorted)
            reinit()
        end
    else
        -- popup position breakes if there is a tooltip before it
        util_imgui.tooltip(config.lang:tr("selector.tooltip_remove"))
    end

    imgui.same_line()
    if imgui.button(gui_util.tr("selector.button_duplicate")) then
        state.input_action = nil
        config.selector:duplicate_current_file()
        state.combo.config:swap(config.selector.sorted)
    end

    imgui.same_line()
    if imgui.button(gui_util.tr("selector.button_close")) then
        state.input_action = nil
        this.close()
    end

    if state.input_action then
        local changed, _ = state.get_input()
        if changed then
            if state.input_action ~= config.selector.sorted[config_sel.combo_file] then
                config.selector:rename_current_file(state.input_action)
                state.combo.config:swap(config.selector.sorted)
                state.reapply_win_pos()
            end

            state.input_action = nil
        end
    end

    imgui.push_item_width(200)
    set:combo(
        gui_util.tr("selector.combo_backup"),
        "combo_file_backup",
        state.combo.config_backup.values
    )
    imgui.pop_item_width()
    imgui.same_line()

    imgui.begin_disabled(state.combo.config_backup:empty())

    if imgui.button(gui_util.tr("selector.button_restore")) then
        state.input_action = nil
        if config.selector:restore_backup() then
            state.combo.config:swap(config.selector.sorted)
            state.combo.config_backup:swap(config.selector.sorted_backup)
        end
    end
    util_imgui.tooltip(config.lang:tr("selector.tooltip_restore"))

    imgui.same_line()

    if imgui.button(gui_util.tr("selector.button_remove_backup")) then
        state.input_action = nil
        util_imgui.open_popup("config_remove_backup", 62, 30)
    end

    imgui.end_disabled()

    if
        util_imgui.popup_yesno(
            "config_remove_backup",
            config.lang:tr("misc.text_rusure"),
            config.lang:tr("misc.text_yes"),
            config.lang:tr("misc.text_no")
        )
    then
        if config.selector:delete_current_backup() then
            state.combo.config_backup:swap(config.selector.sorted_backup)
        end
    else
        -- popup position breakes if there is a tooltip before it
        util_imgui.tooltip(config.lang:tr("selector.tooltip_remove_backup"))
    end

    local spacing = 4
    local size = imgui.get_cursor_pos().y - pos.y - spacing
    this.window_size = size > 0 and size or this.window_size

    imgui.end_child_window()
    imgui.unindent(3)
end

return this
