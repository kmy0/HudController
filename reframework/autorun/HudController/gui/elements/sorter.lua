local config = require("HudController.config")
local data = require("HudController.data")
local gui_util = require("HudController.gui.util")
local hud = require("HudController.hud")
local state = require("HudController.gui.state")
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
---@type table<string, number>
local name_pos = {}
---@type string?
local drag
local reverse_sort = false

function this.close()
    hud_names = {}
    name_pos = {}
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

    for i = 1, #hud_names do
        local hud_name = hud_names[i]
        local start_pos = imgui.get_cursor_screen_pos().y

        util_imgui.dummy_button(gui_util.tr("misc.text_drag", hud_name))
        if not drag and imgui.is_item_hovered() and imgui.is_mouse_down(0) then
            drag = hud_name
        end

        imgui.same_line()
        util_imgui.dummy_button(hud_name, { -1, 0 })

        local end_pos = imgui.get_cursor_screen_pos().y

        if drag == hud_name then
            util_imgui.highlight(state.colors.info, 0, -(end_pos - start_pos))
        end

        if drag == hud_name then
            name_pos[hud_name] = imgui.get_mouse().y
        else
            name_pos[hud_name] = start_pos
        end
    end

    if drag and imgui.is_mouse_released(0) then
        drag = nil
    elseif drag then
        table.sort(hud_names, function(a, b)
            return name_pos[a] < name_pos[b]
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
