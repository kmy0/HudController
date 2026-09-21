local mod = require("HudController.data.mod")

local this = {
    [mod.enum.hud_type.WEAPON] = require("HudController.data.option.element.main.weapon"),
    [mod.enum.hud_type.ITEMBAR] = require("HudController.data.option.element.main.itembar"),
    [mod.enum.hud_type.NOTICE] = require("HudController.data.option.element.main.notice"),
    [mod.enum.hud_type.NAME_ACCESS] = require("HudController.data.option.element.main.name_access"),
    [mod.enum.hud_type.NAME_OTHER] = require("HudController.data.option.element.main.name_other"),
    [mod.enum.hud_type.AMMO] = require("HudController.data.option.element.main.ammo"),
    [mod.enum.hud_type.RADIAL] = require("HudController.data.option.element.main.radial"),
    [mod.enum.hud_type.SLINGER_RETICLE] = require(
        "HudController.data.option.element.main.slinger_reticle"
    ),
    [mod.enum.hud_type.SHARPNESS] = require("HudController.data.option.element.main.sharpness"),
    [mod.enum.hud_type.CLOCK] = require("HudController.data.option.element.main.clock"),
    [mod.enum.hud_type.SHORTCUT_KEYBOARD] = require(
        "HudController.data.option.element.main.shortcut_keyboard"
    ),
    [mod.enum.hud_type.MINIMAP] = require("HudController.data.option.element.main.minimap"),
    [mod.enum.hud_type.STAMINA] = require("HudController.data.option.element.main.stamina"),
    [mod.enum.hud_type.SUBTITLES] = require("HudController.data.option.element.main.subtitles"),
    [mod.enum.hud_type.QUEST_END_TIMER] = require(
        "HudController.data.option.element.main.quest_end_timer"
    ),
}

return this
