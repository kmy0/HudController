local config = require("HudController.config")
local data = require("HudController.data")
local gui_util = require("HudController.gui.util")
local hud = require("HudController.hud")
local state = require("HudController.gui.state")
local util_imgui = require("HudController.util.imgui")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

local this = {
    is_opened = false,
    window_size = 22,
}

local function reinit()
    local config_mod = config.current.mod

    config.lang:change()
    data.get_weapon_bind_map(config.current)
    state.tr_combo()
    hud.manager.reinit()
    hud.operations.reload()
    state.reapply_win_pos()

    local new_hud = config_mod.hud[config_mod.combo_hud]
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
    local changed = false
    local config_sel = config.selector.current

    imgui.spacing()
    imgui.indent(3)

    imgui.begin_child_window("selector_window", { 0, this.window_size }, false, 1 << 3)
    local pos = imgui.get_cursor_pos()

    imgui.push_item_width(200)
    changed, config_sel.combo_file =
        imgui.combo(gui_util.tr("selector.combo_config"), config_sel.combo_file, state.combo.config.values)
    imgui.pop_item_width()

    if changed then
        config.selector:swap()
        reinit()
    end

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
        changed, _ = state.get_input()
        if changed then
            config.selector:rename_current_file(state.input_action)
            state.combo.config:swap(config.selector.sorted)
            state.input_action = nil
            state.reapply_win_pos()
        end
    end

    local spacing = 4
    local size = imgui.get_cursor_pos().y - pos.y - spacing
    this.window_size = size > 0 and size or this.window_size

    imgui.end_child_window()
    imgui.unindent(3)
end

return this
