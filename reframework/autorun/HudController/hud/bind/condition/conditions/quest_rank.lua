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
    ---@type table<app.QuestDef.EM_REWARD_RANK, string>
    local values = {}
    for _, rank in e.iter("app.QuestDef.EM_REWARD_RANK") do
        values[rank] = rank .. config.lang:tr("misc.text_star")
    end

    local o = multi_select.new(
        self,
        "_QUEST_RANK",
        config.lang.make_placeholder("menu.bind.condition.condition_quest_rank"),
        values,
        function(a, b)
            return a.key < b.key
        end
    )
    setmetatable(o, self)
    ---@cast o QuestRankCondition

    return o
end

---@return boolean
function this:update()
    local quest_data = s.get("app.MissionManager"):get_ActiveQuestData()
    if not quest_data then
        return false
    end

    local quest_rank = quest_data:getTargetEmDifficulityRank()
    local options = self:get_additional_options_table()

    for _, rank in pairs(options.selected) do
        if quest_rank:Contains(rank) then
            return true
        end
    end

    return false
end

return this
