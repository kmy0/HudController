---@class QuestTargetCondition : MultiSelectCondition

local e = require("HudController.util.game.enum")
local game_lang = require("HudController.util.game.lang")
local multi_select = require("HudController.hud.bind.condition.conditions.multi_select")
---@class MethodUtil
local m = require("HudController.util.ref.methods")
local s = require("HudController.util.ref.singletons")

m.isBossID = m.wrap(m.get("app.EnemyDef.isBossID(app.EnemyDef.ID)")) --[[@as fun(em_id: app.EnemyDef.ID): System.Boolean]]
m.isEmValid = m.wrap(m.get("app.EnemyDef.isValid(app.EnemyDef.ID)")) --[[@as fun(em_id: app.EnemyDef.ID): System.Boolean]]
m.getEnemyNameGuid = m.wrap(m.get("app.EnemyDef.EnemyName(app.EnemyDef.ID)")) --[[@as fun(em_id: app.EnemyDef.ID): System.Guid]]

---@class QuestTargetCondition
local this = {}
this.__index = this
setmetatable(this, { __index = multi_select })

---@return QuestTargetCondition
function this:new()
    ---@type table<app.EnemyDef.ID, string>
    local values = {}
    for _, em_id in e.iter("app.EnemyDef.ID") do
        if not m.isEmValid(em_id) or not m.isBossID(em_id) then
            goto continue
        end

        local name_guid = m.getEnemyNameGuid(em_id)
        values[em_id] = game_lang.get_message_local2(name_guid)

        ::continue::
    end

    local o = multi_select.new(
        self,
        "_QUEST_TARGET",
        "menu.bind.condition.condition_quest_target",
        values,
        function(a, b)
            return a.value < b.value
        end
    )
    setmetatable(o, self)
    ---@cast o QuestTargetCondition

    return o
end

---@return boolean
function this:update()
    local quest_data = s.get("app.MissionManager"):get_ActiveQuestData()
    if not quest_data then
        return false
    end

    local quest_ems = quest_data:getTargetEmId()
    local options = self:get_additional_options_table()

    for _, em in pairs(options.selected) do
        if quest_ems:Contains(em) then
            return true
        end
    end

    return false
end

return this
