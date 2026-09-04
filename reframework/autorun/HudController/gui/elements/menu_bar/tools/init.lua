local canvas = require("HudController.gui.elements.menu_bar.tools.canvas")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local grid = require("HudController.gui.elements.menu_bar.tools.grid")
local gui_debug = require("HudController.gui.debug")
local gui_selector = require("HudController.gui.elements.selector")
local gui_util = require("HudController.gui.util")
local state = require("HudController.gui.state")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_mod = require("HudController.util.mod.init")

local mod = data.mod
local set = state.set

local this = {}

local function draw_tools_menu()
    set:menu_item(gui_util.tr("menu.tools.box_block_input"), "mod.block_input")

    imgui.separator()

    imgui.begin_disabled(util_mod.is_draw_canvas())
    if util_imgui.menu_item(gui_util.tr("selector.name"), nil, nil, true) then
        mod.pause = true
        gui_selector.is_opened = true
        gui_debug.close()
        config.save_global()
        config.selector:reload()
        state.combo.config:swap(config.selector.sorted)
        state.combo.config_backup:swap(config.selector.sorted_backup)
    end
    imgui.end_disabled()

    if util_imgui.menu_item(gui_util.tr("debug.name"), nil, nil, true) then
        local config_debug = config.gui.current.gui.debug
        config_debug.is_opened = not config_debug.is_opened
        config.save_global()
    end

    imgui.separator()

    imgui.indent(2)
    grid.draw()
    canvas.draw()
    imgui.unindent(2)
end

function this.draw()
    util_menubar.draw_menu(gui_util.tr("menu.tools.name"), draw_tools_menu)
end

return this
