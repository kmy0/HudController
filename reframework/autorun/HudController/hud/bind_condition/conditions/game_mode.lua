local ace_misc = require("HudController.util.ace.misc")
local condition_base = require("HudController.hud.def.condition_base")

---@class GameModeCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@enum GameModeConditionState
local state = {
    SINGLEPLAYER = 1,
    MULTIPLAYER = 2,
}

---@return GameModeCondition
function this:new()
    local o = condition_base.new(self, "_GAME_MODE", "menu.bind.condition.condition_game_mode", {
        "menu.bind.condition.condition_opt_singleplayer",
        "menu.bind.condition.condition_opt_multiplayer",
    })
    setmetatable(o, self)
    ---@cast o GameModeCondition

    return o
end

---@param option_key integer
---@return boolean
function this:update(option_key)
    local is_multiplayer = ace_misc.is_multiplayer()

    if is_multiplayer then
        return option_key == state.MULTIPLAYER
    end

    return option_key == state.SINGLEPLAYER
end

return this
