local config = require("HudController.config")
local data = require("HudController.data")
local drag_util = require("HudController.gui.drag")
local gui_util = require("HudController.gui.util")
local hud = require("HudController.hud")
local util_imgui = require("HudController.util.imgui")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

local this = {
    window = {
        flags = 0,
        condition = 2,
    },
    is_opened = false,
    window_size = 22,
}
---@type string[]
local hud_names = {}
local reverse_sort = false
local drag = drag_util:new()

function this.close()
    hud_names = {}
    this.is_opened = false
    mod.pause = false
end

function this.draw()
    if config.lang.font then
        imgui.push_font(config.lang.font)
    end

    this.is_opened = imgui.begin_window(
        string.format("%s %s", config.name, config.lang:tr("sorter.name")),
        this.is_opened,
        this.window.flags
    )

    if not this.is_opened then
        if config.lang.font then
            imgui.pop_font()
        end

        this.close()
        imgui.end_window()
        return
    end

    if util_table.empty(hud_names) then
        for i = 1, #config.current.mod.hud do
            table.insert(hud_names, config.current.mod.hud[i].name)
        end
    end

    imgui.spacing()
    imgui.indent(2)

    imgui.begin_child_window("hud_profile_sort_child_window", { 0, this.window_size }, false, 1 << 3)
    local pos = imgui.get_cursor_pos()

    if imgui.button(gui_util.tr("sorter.button_sort")) then
        if reverse_sort then
            table.sort(hud_names, function(a, b)
                return a > b
            end)
        else
            table.sort(hud_names)
        end

        reverse_sort = not reverse_sort
    end
    util_imgui.tooltip(config.lang:tr("sorter.button_sort_tooltip"))

    imgui.same_line()

    if imgui.button(gui_util.tr("sorter.button_apply")) then
        hud.operations.sort(hud_names)
        this.close()
        config:save()
    end

    local spacing = 4
    local size = imgui.get_cursor_pos().y - pos.y - spacing
    this.window_size = size > 0 and size or this.window_size

    imgui.unindent(2)
    imgui.end_child_window()
    imgui.separator()

    imgui.begin_child_window("hud_profile_sort_elements_child_window", { -1, -1 }, false)

    drag:clear()
    for i = 1, #hud_names do
        local hud_name = hud_names[i]

        drag:draw_drag_button(hud_name, hud_name)
        imgui.same_line()
        util_imgui.dummy_button(hud_name, { -1, 0 })

        drag:check_drag_pos(hud_name)
    end

    if not drag:is_released() and drag:is_drag() then
        table.sort(hud_names, function(a, b)
            return drag.item_pos[a] < drag.item_pos[b]
        end)
    end

    imgui.spacing()
    imgui.end_child_window()

    if config.lang.font then
        imgui.pop_font()
    end

    imgui.end_window()
end

return this
