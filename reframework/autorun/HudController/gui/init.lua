---@class Gui
---@field window GuiWindow

---@class (exact) GuiWindow
---@field flags integer
---@field condition integer

local config = require("HudController.config")
local data = require("HudController.data")
local fade_manager = require("HudController.hud.fade")
local gui_elements = require("HudController.gui.elements")
local state = require("HudController.gui.state")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

---@class Gui
local this = {
    window = {
        flags = 1024 | 1 << 3 | 1 << 4,
        condition = 2,
    },
    window_size = 49,
}

function this.draw()
    imgui.set_next_window_pos(
        Vector2f.new(config.current.gui.main.pos_x, config.current.gui.main.pos_y),
        this.window.condition
    )
    imgui.set_next_window_size(
        Vector2f.new(config.current.gui.main.size_x, config.current.gui.main.size_y),
        this.window.condition
    )

    if config.lang.font then
        imgui.push_font(config.lang.font)
    end

    config.current.gui.main.is_opened = imgui.begin_window(
        string.format("%s %s", config.name, config.commit),
        config.current.gui.main.is_opened,
        this.window.flags
    )

    if not config.current.gui.main.is_opened then
        if config.lang.font then
            imgui.pop_font()
        end

        imgui.end_window()

        local pos = imgui.get_window_pos()
        local size = imgui.get_window_size()
        config.current.gui.main.pos_x, config.current.gui.main.pos_y = pos.x, pos.y
        config.current.gui.main.size_x, config.current.gui.main.size_y = size.x, size.y
        config.save()
        return
    end

    if imgui.begin_menu_bar() then
        gui_elements.menu_bar.draw()
        imgui.end_menu_bar()
    end

    if not mod.is_ok() then
        imgui.indent(3)
        imgui.text_colored(config.lang.tr("misc.text_no_hud"), state.colors.bad)
        imgui.unindent(3)

        if config.lang.font then
            imgui.pop_font()
        end

        imgui.end_window()
        return
    end

    imgui.spacing()
    imgui.indent(3)

    imgui.begin_disabled(
        not config.current.mod.enabled or (config.current.mod.enable_fade and fade_manager.is_active())
    )

    imgui.begin_child_window("hud_child_window", { 0, this.window_size }, false, 1 << 3)
    local pos = imgui.get_cursor_pos()

    gui_elements.choice.draw_hud()

    imgui.begin_disabled(util_table.empty(config.current.mod.hud))

    gui_elements.choice.draw_element()
    local spacing = 3
    this.window_size = imgui.get_cursor_pos().y - pos.y - spacing

    imgui.end_disabled()
    imgui.end_child_window()

    imgui.separator()

    gui_elements.profile.draw()

    imgui.end_disabled()
    imgui.unindent(3)

    if config.lang.font then
        imgui.pop_font()
    end

    imgui.spacing()
    imgui.end_window()
end

---@return boolean
function this.init()
    state.init()
    return true
end

return this
