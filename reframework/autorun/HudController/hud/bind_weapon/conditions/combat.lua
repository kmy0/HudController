---@class CombatCondition : ConditionBase
---@field state CombatConditionState
---@field protected _state_frame CombatConditionState
---@field protected _timers {out_of_combat: Timer, in_combat: Timer}

local ace_player = require("HudController.util.ace.player")
local ace_porter = require("HudController.util.ace.porter")
local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local s = require("HudController.util.ref.singletons")
local timer = require("HudController.util.misc.timer")

---@class CombatCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@enum CombatConditionState
this.e_state = {
    IN_COMBAT = 1,
    OUT_OF_COMBAT = 2,
    VILLAGE = 3,
}

---@return CombatCondition
function this:new()
    local o = condition_base.new(self, "_COMBAT")
    setmetatable(o, self)
    ---@cast o CombatCondition
    o.state = this.e_state.OUT_OF_COMBAT
    o._state_frame = this.e_state.OUT_OF_COMBAT
    o._timers = {
        out_of_combat = timer:new(0),
        in_combat = timer:new(0),
    }

    return o
end

---@protected
function this:_abort_timers()
    self._timers.in_combat:abort()
    self._timers.out_of_combat:abort()
end

---@return boolean
function this:update()
    local bind_weapon = config.current.mod.bind.weapon

    if ace_player.is_in_village() then
        self.state = this.e_state.VILLAGE
        self:_abort_timers()
        self._state_frame = self.state
        return true
    end

    if
        bind_weapon.quest_in_combat
        and s.get("app.MissionManager"):get_QuestDirector():isPlayingQuest()
    then
        self.state = this.e_state.IN_COMBAT
        self:_abort_timers()
        self._state_frame = self.state
        return true
    end

    local is_combat = ace_player.is_combat()
    if is_combat == nil then
        return false
    end

    self._timers.out_of_combat:update_args(bind_weapon.out_of_combat_delay)
    self._timers.in_combat:update_args(bind_weapon.in_combat_delay)

    if is_combat then
        if
            self._state_frame == this.e_state.OUT_OF_COMBAT
            and self.state == this.e_state.OUT_OF_COMBAT
        then
            self._timers.in_combat:restart()
        end

        if self._timers.out_of_combat:active() then
            self._timers.out_of_combat:restart()
        end
    else
        if self._state_frame == this.e_state.IN_COMBAT and self.state == this.e_state.IN_COMBAT then
            self._timers.out_of_combat:restart()
        end

        if self._timers.in_combat:active() then
            self._timers.in_combat:restart()
        end
    end

    if not self._timers.in_combat:active() and not self._timers.out_of_combat:active() then
        if bind_weapon.ride_ignore_combat and ace_porter.is_master_riding() then
            self.state = this.e_state.OUT_OF_COMBAT
        else
            self.state = is_combat and this.e_state.IN_COMBAT or this.e_state.OUT_OF_COMBAT
        end
    end

    self._state_frame = is_combat and this.e_state.IN_COMBAT or this.e_state.OUT_OF_COMBAT
    return true
end

---@return boolean
function this:is_combat()
    return self.state == this.e_state.IN_COMBAT
end

---@return boolean
function this:is_out_of_combat()
    return self.state == this.e_state.OUT_OF_COMBAT
end

---@return boolean
function this:is_village()
    return self.state == this.e_state.VILLAGE
end

function this:reset()
    self:_abort_timers()
    self.state = this.e_state.OUT_OF_COMBAT
    self._state_frame = self.state
end

return this:new()
