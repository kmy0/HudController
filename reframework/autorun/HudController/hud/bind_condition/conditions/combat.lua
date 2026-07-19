---@class CombatCondition : ConditionBase
---@field protected _state_frame CombatConditionState
---@field protected _timers {out_of_combat: Timer, in_combat: Timer}
---@field get_additional_options_table fun(self: ConditionBase): CombatConditionOptions

---@class (exact) CombatConditionOptions : ConditionBindOptionsBase
---@field out_of_combat_delay integer
---@field in_combat_delay integer
---@field quest_in_combat boolean
---@field ride_ignore_combat boolean

local ace_player = require("HudController.util.ace.player")
local ace_porter = require("HudController.util.ace.porter")
local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local s = require("HudController.util.ref.singletons")
local timer = require("HudController.util.misc.timer")
local set = require("HudController.gui.state").set
local gui_util = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")

---@class CombatCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@enum CombatConditionState
local state = {
    IN_COMBAT = 1,
    OUT_OF_COMBAT = 2,
}

---@return CombatCondition
function this:new()
    local o = condition_base.new(self, "_COMBAT", "menu.bind.condition.condition_combat_state", {
        "menu.bind.condition.condition_opt_in_combat",
        "menu.bind.condition.condition_opt_out_of_combat",
    })
    setmetatable(o, self)
    ---@cast o CombatCondition
    o.state = state.OUT_OF_COMBAT
    o._state_frame = state.OUT_OF_COMBAT
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

---@param option_key integer
---@return boolean
function this:update(option_key)
    local options = self:get_additional_options_table()

    if
        options.quest_in_combat
        and s.get("app.MissionManager"):get_QuestDirector():isPlayingQuest()
    then
        self.state = state.IN_COMBAT
        self:_abort_timers()
        self._state_frame = self.state
        return self.state == option_key
    end

    local is_combat = ace_player.is_combat()

    self._timers.out_of_combat:update_args(options.out_of_combat_delay)
    self._timers.in_combat:update_args(options.in_combat_delay)

    if is_combat then
        if self._state_frame == state.OUT_OF_COMBAT and self.state == state.OUT_OF_COMBAT then
            self._timers.in_combat:restart()
        end

        if self._timers.out_of_combat:active() then
            self._timers.out_of_combat:restart()
        end
    else
        if self._state_frame == state.IN_COMBAT and self.state == state.IN_COMBAT then
            self._timers.out_of_combat:restart()
        end

        if self._timers.in_combat:active() then
            self._timers.in_combat:restart()
        end
    end

    if not self._timers.in_combat:active() and not self._timers.out_of_combat:active() then
        if options.ride_ignore_combat and ace_porter.is_master_riding() then
            self.state = state.OUT_OF_COMBAT
        else
            self.state = is_combat and state.IN_COMBAT or state.OUT_OF_COMBAT
        end
    end

    self._state_frame = is_combat and state.IN_COMBAT or state.OUT_OF_COMBAT
    return self.state == option_key
end

function this:reset()
    self:_abort_timers()
    self.state = state.OUT_OF_COMBAT
    self._state_frame = self.state
end

function this:draw_additional_options()
    local options = self:get_additional_options_table()

    set:checkbox(
        gui_util.tr("menu.bind.condition.quest_in_combat"),
        self:get_config_key_option("quest_in_combat")
    )
    set:checkbox(
        gui_util.tr("menu.bind.condition.ride_ignore_combat"),
        self:get_config_key_option("ride_ignore_combat")
    )
    util_imgui.tooltip(config.lang:tr("menu.bind.condition.ride_ignore_combat_tooltip"), true)
    set:slider_int(
        gui_util.tr("menu.bind.condition.out_of_combat_delay"),
        self:get_config_key_option("out_of_combat_delay"),
        0,
        600,
        options.out_of_combat_delay == 0 and config.lang:tr("misc.text_disabled")
            or gui_util.seconds_to_minutes_string(options.out_of_combat_delay, nil, true)
    )
    set:slider_int(
        gui_util.tr("menu.bind.condition.in_combat_delay"),
        self:get_config_key_option("in_combat_delay"),
        0,
        600,
        options.in_combat_delay == 0 and config.lang:tr("misc.text_disabled")
            or gui_util.seconds_to_minutes_string(options.in_combat_delay, nil, true)
    )
end

---@return CombatConditionOptions
function this:new_additional_options()
    return {
        quest_in_combat = false,
        out_of_combat_delay = 0,
        in_combat_delay = 0,
        ride_ignore_combat = false,
    }
end

return this
