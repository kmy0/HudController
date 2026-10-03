local data = require("HudController.data.init")
local mod_enum = data.mod.enum

local this = {
    [mod_enum.bind_cond_type.HUD] = require(
        "HudController.gui.elements.menu_bar.bind.condition.managers.hud"
    ),
    [mod_enum.bind_cond_type.OPTION_GAME] = require(
        "HudController.gui.elements.menu_bar.bind.condition.managers.option_game"
    ),
    [mod_enum.bind_cond_type.OPTION_USER] = require(
        "HudController.gui.elements.menu_bar.bind.condition.managers.option_user"
    ),
    [mod_enum.bind_cond_type.OPTION_MOD] = require(
        "HudController.gui.elements.menu_bar.bind.condition.managers.option_mod"
    ),
}

return this
