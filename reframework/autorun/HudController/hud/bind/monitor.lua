---@class ModBindMonitor : BindMonitor

local util_misc = require("HudController.util.misc.init")
---@module "HudController.hud.init"
local hud = util_misc.lazy_require("HudController.hud.init")
local bind_monitor = require("HudController.util.game.bind.monitor")
local fade_manager = require("HudController.hud.fade.init")

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
    local current_hud = hud.get_current() --[[@as ModProfileConfig]]
    local requested_hud = hud.profile_switcher.requested_hud
    local is_fading = fade_manager.is_active()

    local hud_callbacks = {}

    for i = 1, #self.managers["hud"].actions do
        local bind = self.managers["hud"].actions[i]
        local value = bind.bound_value

        local hud_changed = not current_hud or value.hud ~= current_hud.key
        local profile_changed = not current_hud or value.profile ~= current_hud.profile

        local requested_hud_changed = is_fading
            and requested_hud
            and value.hud == current_hud.key
            and value.hud ~= requested_hud.hud.key

        local requested_profile_changed = is_fading
            and requested_hud
            and value.profile == current_hud.profile
            and value.profile ~= requested_hud.profile

        if hud_changed or profile_changed or requested_hud_changed or requested_profile_changed then
            table.insert(hud_callbacks, bind)
        end
    end

    self.managers["hud"].actions = hud_callbacks
    bind_monitor.execute_actions(self)
end

return this
