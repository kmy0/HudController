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
    local current_hud = hud.get_current()
    local hud_callback = {}

    for i = 1, #self.managers["hud"].actions do
        local bind = self.managers["hud"].actions[i]

        if
            not current_hud
            or bind.bound_value.hud ~= current_hud.key
            or bind.bound_value.profile ~= current_hud.profile
            or (
                fade_manager.is_active()
                and (
                    (
                        bind.bound_value.hud == current_hud.key
                        and hud.profile_switcher.requested_hud
                        and bind.bound_value.hud ~= hud.profile_switcher.requested_hud.hud.key
                    )
                    or (
                        bind.bound_value.profile == current_hud.profile
                        and hud.profile_switcher.requested_hud
                        and bind.bound_value.profile
                            ~= hud.profile_switcher.requested_hud.hud.profile
                    )
                )
            ) --TODO: refactor
        then
            table.insert(hud_callback, bind)
            break
        end
    end

    self.managers["hud"].actions = hud_callback
    bind_monitor.execute_actions(self)
end

return this
