---@class HealthChanged : ChangedCondition
---@field health ValueChecker

local ace_player = require("HudController.util.ace.player")
local changed_condition = require("HudController.hud.bind.condition.conditions.changed")
local value_checker = require("HudController.util.misc.value_checker")

---@class HealthChanged
local this = {}
this.__index = this
setmetatable(this, { __index = changed_condition })

---@return HealthChanged
function this:new()
    local o = changed_condition.new(
        self,
        "_HEALTH_CHANGED",
        "menu.bind.condition.condition_health_changed"
    )
    setmetatable(o, self)
    ---@cast o HealthChanged

    o.health = value_checker:new()
    return o
end

function this:update()
    local char = ace_player.get_master_char()
    if not char then
        return false
    end

    local health = char:get_HunterHealth()
    local health_manager = health:get_HealthMgr()
    if not health_manager then
        return false
    end

    return self:check(self.health:is_changed(health_manager:get_Health()))
end

function this:reset()
    changed_condition.reset(self)
    self.health:reset()
end

return this
