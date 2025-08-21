local config = require("HudController.config")
local data = require("HudController.data")
local gui_util = require("HudController.gui.util")
local hud = require("HudController.hud")
local set = require("HudController.gui.set")
local state = require("HudController.gui.state")
local util_imgui = require("HudController.util.imgui")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

local this = {}

function this.draw_hud()
    local config_mod = config.current.mod

    imgui.push_item_width(200)

    if set.combo(gui_util.tr("hud.combo"), "mod.combo.hud", state.combo.hud.values) then
        state.input_action = nil
        hud.request_hud(config_mod.hud[config_mod.combo.hud])
        config.save_global()
    end

    imgui.pop_item_width()
    imgui.same_line()

    if imgui.button(gui_util.tr("hud.button_new")) then
        state.input_action = nil
        hud.operations.new()
        config_mod.combo.hud = #config_mod.hud
        hud.request_hud(config_mod.hud[config_mod.combo.hud])
        config.save_global()
    end

    imgui.same_line()
    imgui.begin_disabled(util_table.empty(config_mod.hud))

    if imgui.button(gui_util.tr("hud.button_rename")) then
        state.input_action = config_mod.hud[config_mod.combo.hud].name
    end

    imgui.same_line()

    if imgui.button(gui_util.tr("hud.button_remove")) then
        util_imgui.open_popup("hud_remove", 62, 30)
        state.input_action = nil
    end

    if
        util_imgui.popup_yesno(
            "hud_remove",
            config.lang:tr("misc.text_rusure"),
            config.lang:tr("misc.text_yes"),
            config.lang:tr("misc.text_no")
        )
    then
        hud.operations.remove(config_mod.hud[config_mod.combo.hud])
        if not util_table.empty(config_mod.hud) then
            hud.request_hud(config_mod.hud[config_mod.combo.hud])
        end

        config.save_global()
    end

    imgui.same_line()

    local button = imgui.button(gui_util.tr("hud.button_export"))
    util_imgui.tooltip(config.lang:tr("hud.button_export_tooltip"))
    if button then
        hud.operations.export(config_mod.hud[config_mod.combo.hud])
    end

    imgui.same_line()
    imgui.end_disabled()

    button = imgui.button(gui_util.tr("hud.button_import"))
    util_imgui.tooltip(config.lang:tr("hud.button_import_tooltip"))
    if button then
        hud.operations.import()
        config.save_global()
    end

    imgui.same_line()

    if imgui.button(gui_util.tr("hud.button_save")) then
        config:backup()
        config:save_no_timer()
    end
    util_imgui.tooltip(config.lang:tr("hud.tooltip_save"))

    if state.input_action and not mod.pause then
        local changed, _ = state.get_input()
        if changed then
            hud.operations.rename(config_mod.hud[config_mod.combo.hud], state.input_action)
            state.input_action = nil
            config.save_global()
        end
    end
end

function this.draw_element()
    local config_mod = config.current.mod

    imgui.push_item_width(200)

    set.combo(gui_util.tr("hud_element.combo"), "mod.combo.hud_elem", state.combo.hud_elem.values)

    imgui.pop_item_width()
    imgui.same_line()

    if imgui.button(gui_util.tr("hud_element.button_add")) then
        hud.operations.add_element(state.combo.hud_elem:get_key(config_mod.combo.hud_elem) --[[@as string]])
        config.save_global()
    end

    imgui.same_line()

    if imgui.button(gui_util.tr("hud_element.button_sort")) then
        local elements = config_mod.hud[config_mod.combo.hud].elements or {}
        hud.operations.sort_elements(util_table.values(elements))
        config.save_global()
    end
    util_imgui.tooltip(config.lang:tr("hud_element.button_sort_tooltip"))
end

return this
