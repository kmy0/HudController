local ace_player = require("HudController.util.ace.player")
local condition_base = require("HudController.hud.def.condition_base")
local m = require("HudController.util.ref.methods")

---@class WeaponTypeCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@enum WeaponTypeConditionState
local state = {
    MELEE = 1,
    RANGED = 2,
}

---@return WeaponTypeCondition
function this:new()
    local o = condition_base.new(
        self,
        "_WEAPON_TYPE",
        "menu.bind.condition.condition_weapon_type",
        { "menu.bind.condition.condition_opt_melee", "menu.bind.condition.condition_opt_ranged" }
    )
    setmetatable(o, self)
    ---@cast o WeaponTypeCondition

    return o
end

---@param option_key integer
---@return boolean
function this:update(option_key)
    local weapon_type = ace_player.get_weapon_type()
    local is_ranged = m.isGunnerWeapon(weapon_type)

    if is_ranged then
        return option_key == state.RANGED
    end

    return option_key == state.MELEE
end

return this
