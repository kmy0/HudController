local condition = require("HudController.gui.elements.menu_bar.bind.condition")
local condition_options = require("HudController.gui.elements.menu_bar.bind.condition_options")
local gui_util = require("HudController.gui.util")
local key = require("HudController.gui.elements.menu_bar.bind.key")
local util_menubar = require("HudController.gui.elements.menu_bar.util")

local this = {}

local function draw_bind_menu()
    imgui.spacing()
    imgui.indent(2)

    key.draw()
    condition.draw()
    condition_options.draw()

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    util_menubar.draw_menu(gui_util.tr("menu.bind.name"), draw_bind_menu)
end

return this
