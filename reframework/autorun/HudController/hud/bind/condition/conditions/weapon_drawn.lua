local ace_player = require("HudController.util.ace.player")
local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")

---@class WeaponDrawnCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@return WeaponDrawnCondition
function this:new()
    local o = condition_base.new(
        self,
        "_WeaponDrawn",
        config.lang.make_placeholder("menu.bind.condition.condition_weapon_drawn")
    )
    setmetatable(o, self)
    ---@cast o WeaponDrawnCondition

    return o
end

---@return boolean
function this:update()
    local char = ace_player.get_master_char()
    if not char then
        return false
    end

    return char:get_IsWeaponOn()
end

return this
