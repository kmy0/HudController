---@class (exact) DamageNumbersCriticalState : HudChild

local data = require("HudController.data")
local hud_child = require("HudController.hud.def.hud_child")

local ace_enum = data.ace.enum

---@class DamageNumbersCriticalState
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

---@param args HudChildConfig
---@param parent DamageNumbersDamageStateCls
---@param cls HudChild
---@return DamageNumbersCriticalState
function this:new(args, parent, cls)
    setmetatable(self, { __index = cls })
    local o = cls.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        ---@cast hudbase app.GUI020020.DAMAGE_INFO
        if
            not hudbase
            or ace_enum.critical_state[hudbase:get_field("<criticalState>k__BackingField")] == args.name_key
        then
            return ctrl
        end
    end)
    setmetatable(o, self)
    ---@cast o DamageNumbersCriticalState

    return o
end

---@param key HudChildWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    self.parent.reset(self, key)
end

return this
