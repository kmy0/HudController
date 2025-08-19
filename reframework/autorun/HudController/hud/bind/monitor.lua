---@class ModBindMonitor : BindMonitor

---@module "HudController.hud"
local hud
local bind_monitor = require("HudController.util.game.bind.monitor")

---@class ModBindMonitor
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = bind_monitor })

---@param ... BindManager
---@return ModBindMonitor
function this:new(...)
    local o = bind_monitor.new(self, ...)
    setmetatable(o, self)
    ---@cast o ModBindMonitor
    return o
end

function this:execute_actions()
    if not hud then
        hud = require("HudController.hud")
    end

    local current_hud = hud.get_current()
    local hud_callback = {}

    for i = 1, #self.managers["hud"].actions do
        local bind = self.managers["hud"].actions[i]
        if not current_hud or bind.bound_value ~= current_hud.key then
            table.insert(hud_callback, bind)
            break
        end
    end

    self.managers["hud"].actions = hud_callback
    bind_monitor.execute_actions(self)
end

return this
