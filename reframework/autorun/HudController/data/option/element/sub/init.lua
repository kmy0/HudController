local mod = require("HudController.data.mod")

local this = {
    [mod.enum.hud_sub_type.MATERIAL] = require("HudController.data.option.element.sub.material"),
    [mod.enum.hud_sub_type.SCALE9] = require("HudController.data.option.element.sub.scale9"),
    [mod.enum.hud_sub_type.TEXT] = require("HudController.data.option.element.sub.text"),
    [mod.enum.hud_sub_type.DAMAGE_NUMBERS] = require(
        "HudController.data.option.element.sub.damage_numbers"
    ),
    [mod.enum.hud_sub_type.CTRL_CHILD] = require(
        "HudController.data.option.element.sub.control_child"
    ),
    [mod.enum.hud_sub_type.PROGRESS_TEXT] = require(
        "HudController.data.option.element.sub.progress_text"
    ),
    [mod.enum.hud_sub_type.PROGRESS_PART] = require(
        "HudController.data.option.element.sub.progress_part"
    ),
}

return this
