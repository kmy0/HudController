---@class StageCondition : MultiSelectCondition

local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local game_lang = require("HudController.util.game.lang")
local m = require("HudController.util.ref.methods")
local multi_select = require("HudController.hud.bind.condition.conditions.multi_select")
local s = require("HudController.util.ref.singletons")
local util_ref = require("HudController.util.ref.init")

---@class StageCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = multi_select })

---@return StageCondition
function this:new()
    ---@type table<app.FieldDef.STAGE, string>
    local values = {}
    for _, stage_id in e.iter("app.FieldDef.STAGE") do
        local guid = util_ref.value_type("System.Guid")
        m.getStageNameGuid(stage_id, guid:address())
        local name = game_lang.get_message_local2(guid)

        if name ~= "" then
            values[stage_id] = game_lang.get_message_local2(guid)
        end
    end

    local o = multi_select.new(
        self,
        "_STAGE",
        config.lang.make_placeholder("menu.bind.condition.condition_stage"),
        values,
        function(a, b)
            return a.value < b.value
        end
    )
    setmetatable(o, self)
    ---@cast o StageCondition
    return o
end

---@param selected table<string, boolean>
---@return boolean
function this:update(selected)
    local stage = s.get("app.MasterFieldManager"):get_CurrentStage()
    return selected[tostring(stage)]
end

return this
