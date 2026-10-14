local ace_player = require("HudController.util.ace.player")
local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")

---@class InfiniteStaminaAreaCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@return InfiniteStaminaAreaCondition
function this:new()
    local o = condition_base.new(
        self,
        "_INFINITE_STAMINA_AREA",
        config.lang.make_placeholder("menu.bind.condition.condition_infinite_stamina_area")
    )
    setmetatable(o, self)
    ---@cast o InfiniteStaminaAreaCondition

    return o
end

---@return boolean
function this:update()
    return ace_player.check_continue_flag(e.get("app.HunterDef.CONTINUE_FLAG").IN_SP_SAFE_AREA)
end

return this
