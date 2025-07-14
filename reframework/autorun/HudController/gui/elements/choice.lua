local config = require("HudController.config")
local gui_util = require("HudController.gui.util")
local hud = require("HudController.hud")
local set = require("HudController.gui.set")
local state = require("HudController.gui.state")
local util_imgui = require("HudController.util.imgui")
local util_table = require("HudController.util.misc.table")

local this = {}

function this.draw_hud()
    imgui.push_item_width(200)

    if set.combo(gui_util.tr("hud.combo"), "mod.combo_hud", state.combo.hud.values) then
        state.input_action = nil
        hud.request_hud(config.current.mod.hud[config.current.mod.combo_hud])
        config.save()
    end

    imgui.pop_item_width()
    imgui.same_line()

    if imgui.button(gui_util.tr("hud.button_new")) then
        state.input_action = nil
        hud.operations.new()
        config.current.mod.combo_hud = #config.current.mod.hud
        hud.request_hud(config.current.mod.hud[config.current.mod.combo_hud])
        config.save()
    end

    imgui.same_line()
    imgui.begin_disabled(util_table.empty(config.current.mod.hud))

    if imgui.button(gui_util.tr("hud.button_rename")) then
        state.input_action = config.current.mod.hud[config.current.mod.combo_hud].name
    end

    imgui.same_line()

    if imgui.button(gui_util.tr("hud.button_remove")) then
        state.input_action = nil
        hud.operations.remove(config.current.mod.hud[config.current.mod.combo_hud])
        if not util_table.empty(config.current.mod.hud) then
            hud.request_hud(config.current.mod.hud[config.current.mod.combo_hud])
        end

        config.save()
    end

    imgui.same_line()

    local button = imgui.button(gui_util.tr("hud.button_export"))
    util_imgui.tooltip(config.lang.tr("hud.button_export_tooltip"))
    if button then
        hud.operations.export(config.current.mod.hud[config.current.mod.combo_hud])
    end

    imgui.same_line()
    imgui.end_disabled()

    button = imgui.button(gui_util.tr("hud.button_import"))
    util_imgui.tooltip(config.lang.tr("hud.button_import_tooltip"))
    if button then
        hud.operations.import()
        config.save()
    end

    imgui.same_line()

    if imgui.button(gui_util.tr("hud.button_save")) then
        config.save(true)
    end

    if state.input_action then
        local changed = false
        changed, state.input_action = imgui.input_text(gui_util.tr("hud.input"), state.input_action, 1 << 6)

        if changed then
            hud.operations.rename(config.current.mod.hud[config.current.mod.combo_hud], state.input_action)
            state.input_action = nil
            config.save()
        end
    end
end

function this.draw_element()
    imgui.push_item_width(200)

    set.combo(gui_util.tr("hud_element.combo"), "mod.combo_hud_elem", state.combo.hud_elem.values)

    imgui.pop_item_width()
    imgui.same_line()

    if imgui.button(gui_util.tr("hud_element.button_add")) then
        hud.operations.add_element(state.combo.hud_elem:get_key(config.current.mod.combo_hud_elem) --[[@as string]])
        config.save()
    end

    imgui.same_line()

    if imgui.button(gui_util.tr("hud_element.button_sort")) then
        local elements = config.current.mod.hud[config.current.mod.combo_hud].elements or {}
        hud.operations.sort_elements(util_table.values(elements))
        config.save()
    end
    util_imgui.tooltip(config.lang.tr("hud_element.button_sort_tooltip"))
end

return this
