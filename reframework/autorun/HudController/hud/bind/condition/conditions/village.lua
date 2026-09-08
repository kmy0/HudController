local ace_player = require("HudController.util.ace.player")
local condition_base = require("HudController.hud.def.condition_base")

---@class VillageCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@return VillageCondition
function this:new()
    local o = condition_base.new(self, "_VILLAGE", "menu.bind.condition.condition_village")
    setmetatable(o, self)
    ---@cast o VillageCondition

    return o
end

---@return boolean
function this:update()
    return ace_player.is_in_village()
end

return this
