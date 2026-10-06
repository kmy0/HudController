local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local s = require("HudController.util.ref.singletons")

---@class QuestCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@return QuestCondition
function this:new()
    local o = condition_base.new(
        self,
        "_QUEST",
        config.lang.make_placeholder("menu.bind.condition.condition_quest")
    )
    setmetatable(o, self)
    ---@cast o QuestCondition

    return o
end

---@return boolean
function this:update()
    return s.get("app.MissionManager"):get_QuestDirector():isPlayingQuest()
end

return this
