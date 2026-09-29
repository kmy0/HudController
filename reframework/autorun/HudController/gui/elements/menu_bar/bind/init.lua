local bind_condition = require("HudController.hud.bind.condition.init")
local bind_manager = require("HudController.hud.bind.key.init")
local condition = require("HudController.gui.elements.menu_bar.bind.condition.init")
local condition_options = require("HudController.gui.elements.menu_bar.bind.condition_options")
local data = require("HudController.data.init")
local key = require("HudController.gui.elements.menu_bar.bind.key.init")
local key_options = require("HudController.gui.elements.menu_bar.bind.key_options")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_menubar = require("HudController.gui.elements.menu_bar.util")

local mod_enum = data.mod.enum

local this = {}

local function draw_bind_menu()
    imgui.spacing()
    imgui.indent(2)

    key.draw()
    key_options.draw()
    condition.draw()
    condition_options.draw()

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    if
        not util_menubar.draw_menu(
            util_gui.tr("menu.bind.name"),
            draw_bind_menu,
            nil,
            (bind_condition.check_invalid() or bind_manager.any_invalid) and mod_enum.colors.bad
                or nil
        )
    then
        state.clear_listener()
    end
end

return this
