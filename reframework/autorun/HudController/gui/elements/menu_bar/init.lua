local bind = require("HudController.gui.elements.menu_bar.bind.init")
local lang = require("HudController.gui.elements.menu_bar.lang")
local mod = require("HudController.gui.elements.menu_bar.mod")
local tools = require("HudController.gui.elements.menu_bar.tools")
local user = require("HudController.gui.elements.menu_bar.user")

local this = {}

function this.draw()
    mod.draw()
    lang.draw()
    bind.draw()
    user.draw()
    tools.draw()
end

return this
