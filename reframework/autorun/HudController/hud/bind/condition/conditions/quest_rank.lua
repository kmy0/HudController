---@class QuestRankCondition : MultiSelectCondition

local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local multi_select = require("HudController.hud.bind.condition.conditions.multi_select")
local s = require("HudController.util.ref.singletons")

---@class QuestRankCondition
local this = {}
this.__index = this
setmetatable(this, { __index = multi_select })

---@return QuestRankCondition
function this:new()
    ---@type table<string, string>
    local values = {}
    for name, rank in e.iter("app.QuestDef.EM_REWARD_RANK") do
        values[name] = rank .. config.lang:tr("misc.text_star")
    end

    local o = multi_select.new(
        self,
        "_QUEST_RANK",
        config.lang.make_placeholder("menu.bind.condition.condition_quest_rank"),
        values,
        function(a, b)
            local enum = e.get("app.QuestDef.EM_REWARD_RANK")
            return enum[a.key] < enum[b.key]
        end
    )
    setmetatable(o, self)
    ---@cast o QuestRankCondition

    return o
end

---@param selected table<string, boolean>
---@return boolean
function this:update(selected)
    local quest_data = s.get("app.MissionManager"):get_ActiveQuestData()
    if not quest_data then
        return false
    end

    local quest_rank = quest_data:getTargetEmDifficulityRank()
    for rank_name, _ in pairs(selected) do
        local rank_id = e.get("app.QuestDef.EM_REWARD_RANK")[rank_name]
        if quest_rank:Contains(rank_id) then
            return true
        end
    end

    return false
end

return this
