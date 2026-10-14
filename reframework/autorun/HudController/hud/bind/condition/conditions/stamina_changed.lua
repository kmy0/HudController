---@class StaminaChanged : ChangedCondition
---@field stamina ValueChecker

local ace_player = require("HudController.util.ace.player")
local changed_condition = require("HudController.hud.bind.condition.conditions.changed")
local config = require("HudController.config.init")
local value_checker = require("HudController.util.misc.value_checker")

---@class StaminaChanged
local this = {}
this.__index = this
setmetatable(this, { __index = changed_condition })

---@return StaminaChanged
function this:new()
    local o = changed_condition.new(
        self,
        "_STAMINA_CHANGED",
        config.lang.make_placeholder("menu.bind.condition.condition_stamina_changed")
    )
    setmetatable(o, self)
    ---@cast o StaminaChanged

    o.stamina = value_checker:new()
    return o
end

function this:update()
    local char = ace_player.get_master_char()
    if not char then
        return false
    end

    local stamina = char:get_HunterStamina()
    if not stamina then
        return false
    end

    return self:check(self.stamina:is_changed(stamina:get_Stamina()))
end

function this:reset()
    changed_condition.reset(self)
    self.stamina:reset()
end

return this
