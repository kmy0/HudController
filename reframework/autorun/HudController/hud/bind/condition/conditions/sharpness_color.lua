local ace_player = require("HudController.util.ace.player")
local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local multi_select = require("HudController.hud.bind.condition.conditions.multi_select")

---@class SharpnessColorCondition : MultiSelectCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = multi_select })

---@return SharpnessColorCondition
function this:new()
    ---@type table<string, string>
    local values = {}
    for name, _ in e.iter("app.WeaponDef.KIREAJI_TYPE") do
        values[name] = string.format(
            config.lang.make_placeholder("menu.bind.condition.condition_sharpness_color_values.%s"),
            name
        )
    end

    local o = multi_select.new(
        self,
        "_SHARPNESS_COLOR",
        config.lang.make_placeholder("menu.bind.condition.condition_sharpness_color"),
        values
    )

    setmetatable(o, self)
    ---@cast o SharpnessColorCondition

    return o
end

---@param selected table<string, boolean>
---@return boolean
function this:update(selected)
    local char = ace_player.get_master_char()
    if not char then
        return false
    end

    local handling = char:get_WeaponHandling()
    if not handling then
        return false
    end

    local kireaji = handling:get_Kireaji()
    if not kireaji then
        return false
    end

    local sharpness = kireaji:get_CurrentType()
    return selected[e.get("app.WeaponDef.KIREAJI_TYPE")[sharpness]]
end

return this
