---@class HealthThresholdCondition : ThresholdCondition

local ace_player = require("HudController.util.ace.player")
local base = require("HudController.hud.bind.condition.conditions.threshold")
local config = require("HudController.config.init")

---@class HealthThresholdCondition
local this = {}
this.__index = this
setmetatable(this, { __index = base })

---@return HealthThresholdCondition
function this:new()
    local o = base.new(
        self,
        "_HEALTH_THRESHOLD",
        config.lang.make_placeholder("menu.bind.condition.condition_health_threshold")
    )
    setmetatable(o, self)
    ---@cast o HealthThresholdCondition
    return o
end

---@param v_lo number
---@param v_hi number
---@return boolean
function this:update(v_lo, v_hi)
    local char = ace_player.get_master_char()
    if not char then
        return false
    end

    local health = char:get_HunterHealth()
    local health_manager = health:get_HealthMgr()
    if not health_manager then
        return false
    end

    local percent = health_manager:get_Health()
    return percent >= v_lo and v_hi >= percent
end

return this
