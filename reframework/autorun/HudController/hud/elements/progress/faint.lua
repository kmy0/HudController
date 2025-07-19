---@class (exact) ProgressPartTaskFaint : ProgressPartTask
---@field get_config fun(): ProgressPartTaskFaintConfig
---@field root Progress

---@class (exact) ProgressPartTaskFaintConfig : ProgressPartTaskConfig

local part_task = require("HudController.hud.elements.progress.task")

---@class ProgressPartTaskFaint
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = part_task })

---@param args ProgressPartTaskFaintConfig
---@param parent Progress
---@return ProgressPartTaskFaint
function this:new(args, parent)
    local o = part_task.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        local pnl = this._get_panel(s)
        if pnl then
            parent.children.task:reset_ctrl(pnl)
            return pnl
        end
    end)
    setmetatable(o, self)
    ---@cast o ProgressPartTaskFaint

    return o
end

---@protected
---@return via.gui.Panel?
function this:_get_panel()
    local GUI020018 = self.root:get_GUI020018()
    local die = GUI020018._DiePanelData
    if die then
        return die._DuplicatePanel
    end
end

---@return ProgressPartTaskFaintConfig
function this.get_config()
    local base = part_task.get_config() --[[@as ProgressPartTaskFaintConfig]]
    base.enabled_offset = false
    base.offset = { x = 0, y = 0 }
    base.name_key = "faint"
    return base
end

return this
