---@class QuestTargetCondition : MultiSelectCondition

local config = require("HudController.config.init")
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
    ---@type table<string, string>
    local values = {}
    for name, em_id in e.iter("app.EnemyDef.ID") do
        if not m.isEmValid(em_id) or not m.isBossID(em_id) then
            goto continue
        end

        local name_guid = m.getEnemyNameGuid(em_id)
        values[name] = game_lang.get_message_local2(name_guid)

        ::continue::
    end

    local o = multi_select.new(
        self,
        "_QUEST_TARGET",
        config.lang.make_placeholder("menu.bind.condition.condition_quest_target"),
        values
    )
    setmetatable(o, self)
    ---@cast o QuestTargetCondition

    return o
end

---@param selected table<string, boolean>
---@return boolean
function this:update(selected)
    local quest_data = s.get("app.MissionManager"):get_ActiveQuestData()
    if not quest_data then
        return false
    end

    local quest_ems = quest_data:getTargetEmId()
    for em_name, _ in pairs(selected) do
        local em_id = e.get("app.EnemyDef.ID")[em_name]
        if quest_ems:Contains(em_id) then
            return true
        end
    end

    return false
end

return this
