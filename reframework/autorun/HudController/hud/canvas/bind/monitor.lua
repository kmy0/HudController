---@class CanvasBindMonitor : BindMonitor
---@field action CanvasActionEnum?
---@field action_type BindActionType

local bind_monitor = require("HudController.util.game.bind.monitor")

---@class CanvasBindMonitor
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = bind_monitor })

---@param ... BindManager
---@return CanvasBindMonitor
function this:new(...)
    local o = bind_monitor.new(self, ...)
    setmetatable(o, self)
    ---@cast o CanvasBindMonitor
    return o
end

---@return CanvasActionEnum?
function this:monitor()
    bind_monitor.monitor(self)
    local ret = self.action

    if self.action_type == "TOGGLE" then
        self.action = nil
    end

    return ret
end

return this
