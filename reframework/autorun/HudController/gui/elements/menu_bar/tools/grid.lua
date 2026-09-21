local option = require("HudController.data.option.init")
local util_ace = require("HudController.util.ace.init")
local util_gui = require("HudController.gui.util")
local util_menubar = require("HudController.gui.elements.menu_bar.util")

local mod_def = option.mod

local this = {}

local function draw_grid_menu()
    imgui.spacing()
    imgui.indent(2)

    if option.draw(mod_def.opt.grid_draw) then
        util_ace.scene_fade.reset()
    end

    option.draw(mod_def.opt.grid_ratio)
    option.draw(mod_def.opt.grid_color_center)
    option.draw(mod_def.opt.grid_color_grid)
    option.draw(mod_def.opt.grid_color_fade)
    option.draw(mod_def.opt.grid_fade_alpha)

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    util_menubar.draw_menu(util_gui.tr("menu.grid.name"), draw_grid_menu)
end

return this
