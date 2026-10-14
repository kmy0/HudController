---@class StaminaThresholdCondition : ThresholdCondition

local ace_player = require("HudController.util.ace.player")
local base = require("HudController.hud.bind.condition.conditions.threshold")
local config = require("HudController.config.init")

---@class StaminaThresholdCondition
local this = {}
this.__index = this
setmetatable(this, { __index = base })

---@return StaminaThresholdCondition
function this:new()
    local o = base.new(
        self,
        "_STAMINA_THRESHOLD",
        config.lang.make_placeholder("menu.bind.condition.condition_stamina_threshold")
    )
    setmetatable(o, self)
    ---@cast o StaminaThresholdCondition
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

    local stamina = char:get_HunterStamina()
    if not stamina then
        return false
    end

    local percent = stamina:get_Stamina()
    return percent >= v_lo and v_hi >= percent
end

return this
