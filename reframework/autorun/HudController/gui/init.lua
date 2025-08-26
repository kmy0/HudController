---@class Gui
---@field window GuiWindow
---@field state GuiState

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
    window_size = 48,
    state = state,
}

function this.draw()
    local gui_main = config.gui.current.gui.main
    local config_mod = config.current.mod
    state.update_state()

    imgui.set_next_window_pos(
        Vector2f.new(gui_main.pos_x, gui_main.pos_y),
        not state.redo_win_pos.main and this.window.condition or nil
    )
    imgui.set_next_window_size(
        Vector2f.new(gui_main.size_x, gui_main.size_y),
        not state.redo_win_pos.main and this.window.condition or nil
    )
    state.redo_win_pos.main = false

    if config.lang.font then
        imgui.push_font(config.lang.font)
    end

    gui_main.is_opened = imgui.begin_window(
        string.format(
            "%s %s - %s",
            config.name,
            config.commit,
            state.combo.config:get_value(config.selector.current.combo_file)
        ),
        gui_main.is_opened,
        this.window.flags
    )

    local pos = imgui.get_window_pos()
    local size = imgui.get_window_size()

    gui_main.pos_x, gui_main.pos_y = pos.x, pos.y
    gui_main.size_x, gui_main.size_y = size.x, size.y

    if not gui_main.is_opened then
        if config.lang.font then
            imgui.pop_font()
        end

        gui_elements.sorter.close()
        gui_elements.selector.close()
        state.input_action = nil
        config.save_global()
        imgui.end_window()
        return
    end

    imgui.begin_disabled(gui_elements.selector.is_opened or gui_elements.sorter.is_opened)

    if imgui.begin_menu_bar() then
        gui_elements.menu_bar.draw()
        imgui.end_menu_bar()
    end

    imgui.end_disabled()

    if gui_elements.selector.is_opened then
        gui_elements.selector.draw()
        imgui.separator()
    end

    if not mod.is_ok() then
        imgui.indent(3)
        imgui.text_colored(config.lang:tr("misc.text_no_hud"), state.colors.bad)
        imgui.unindent(3)

        if config.lang.font then
            imgui.pop_font()
        end

        imgui.end_window()
        return
    end

    if not gui_elements.selector.is_opened then
        imgui.spacing()
    end

    imgui.indent(3)
    imgui.begin_disabled(
        not config_mod.enabled
            or gui_elements.selector.is_opened
            or gui_elements.sorter.is_opened
            or (config_mod.enable_fade and fade_manager.is_active())
    )

    imgui.begin_child_window("hud_child_window", { 0, this.window_size }, false, 1 << 3)
    local pos = imgui.get_cursor_pos()

    gui_elements.choice.draw_hud()

    imgui.begin_disabled(util_table.empty(config_mod.hud))

    gui_elements.choice.draw_element()
    local spacing = 4
    local size = imgui.get_cursor_pos().y - pos.y - spacing
    this.window_size = size > 0 and size or this.window_size

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
