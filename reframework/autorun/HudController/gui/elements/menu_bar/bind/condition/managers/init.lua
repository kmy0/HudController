local data = require("HudController.data.init")
local mod_enum = data.mod.enum

local this = {
    [mod_enum.bind_cond_type.HUD] = require(
        "HudController.gui.elements.menu_bar.bind.condition.managers.hud"
    ),
}

return this
