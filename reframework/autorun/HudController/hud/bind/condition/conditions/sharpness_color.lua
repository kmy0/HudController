local ace_player = require("HudController.util.ace.player")
local condition_base = require("HudController.hud.def.condition_base")
local e = require("HudController.util.game.enum")
local util_table = require("HudController.util.misc.table")

---@type string[]
local sharpness_color

---@class SharpnessColorCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@return SharpnessColorCondition
function this:new()
    local enum = e.get("app.WeaponDef.KIREAJI_TYPE")
    sharpness_color = util_table.sort(util_table.keys(enum.field_to_enum), function(a, b)
        return enum[a] < enum[b]
    end)

    local o = condition_base.new(
        self,
        "_SHARPNESS_COLOR",
        "menu.bind.condition.condition_sharpness_color",
        util_table.collect(util_table.iterator(function(index)
            if sharpness_color[index] then
                return string.format(
                    "menu.bind.condition.condition_sharpness_color_values.%s",
                    sharpness_color[index]
                )
            end
        end))
    )
    setmetatable(o, self)
    ---@cast o SharpnessColorCondition

    return o
end

---@param option_key integer
---@return boolean
function this:update(option_key)
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
    return sharpness_color[option_key] == e.get("app.WeaponDef.KIREAJI_TYPE")[sharpness]
end

return this
