---@class (exact) ProgressQuestTimerBest : ProgressQuestTimer
---@field get_config fun(): ProgressQuestTimerBestConfig
---@field root Progress

---@class (exact) ProgressQuestTimerBestConfig : ProgressQuestTimerConfig

local quest_timer = require("HudController.hud.elements.progress.quest_timer")

---@class ProgressQuestTimerBest
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = quest_timer })

---@param args ProgressQuestTimerBestConfig
---@param parent Progress
---@return ProgressQuestTimerBest
function this:new(args, parent)
    local o = quest_timer.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        local pnl = this._get_panel(s)
        if pnl then
            parent.children.timer:reset_specific(nil, pnl)
        end
        return pnl
    end)
    setmetatable(o, self)
    ---@cast o ProgressQuestTimerBest

    return o
end

---@protected
---@return via.gui.Panel?
function this:_get_panel()
    local GUI020018 = self.root:get_GUI020018()
    local best = GUI020018._BestRecordPanelData
    if not best then
        return
    end

    return best._DuplicatePanel
end

---@return ProgressQuestTimerBestConfig
function this.get_config()
    local base = quest_timer.get_config() --[[@as ProgressQuestTimerBestConfig]]
    base.name_key = "best_timer"
    return base
end

return this
