local config = require("HudController.config.init")
local data = require("HudController.data.init")
local gui_util = require("HudController.gui.util")
local state = require("HudController.gui.state")
local util_ace = require("HudController.util.ace.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")

local mod = data.mod
local set = state.set

local this = {}

local function draw_grid_menu()
    imgui.spacing()
    imgui.indent(2)

    if set:checkbox(gui_util.tr("menu.grid.box_draw"), "mod.grid.draw") then
        util_ace.scene_fade.reset()
    end

    set:slider_int(
        gui_util.tr("menu.grid.combo_ratio"),
        "mod.grid.combo_grid_ratio",
        1,
        #mod.map.slider_grid_ratio,
        mod.map.slider_grid_ratio[config:get("mod.grid.combo_grid_ratio")]
    )
    set:color_edit(gui_util.tr("menu.grid.color_center"), "mod.grid.color_center")

    set:color_edit(gui_util.tr("menu.grid.color_grid"), "mod.grid.color_grid")
    set:color_edit(gui_util.tr("menu.grid.color_fade"), "mod.grid.color_fade")
    set:slider_float(gui_util.tr("menu.grid.fade_alpha"), "mod.grid.fade_alpha", 0, 1, "%.2f")

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    util_menubar.draw_menu(gui_util.tr("menu.grid.name"), draw_grid_menu)
end

return this
