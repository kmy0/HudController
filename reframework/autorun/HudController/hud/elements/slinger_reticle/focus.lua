---@class (exact) SlingerReticleFocus : HudChild
---@field root SlingerReticle
---@field parent SlingerReticle
---@field get_config fun(): SlingerReticleFocusConfig
---@field children {
--- slinger: SlingerReticleSlinger,
--- }

---@class (exact) SlingerReticleFocusConfig : HudChildConfig
---@field children {
--- slinger: HudChildConfig,
--- }

local hud_child = require("HudController.hud.def.hud_child")
local slinger = require("HudController.hud.elements.slinger_reticle.slinger")

---@class SlingerReticleFocus
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

---@param args SlingerReticleFocusConfig
---@param parent SlingerReticle
---@return SlingerReticleFocus
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        if parent:is_GUI020002_visible() then
            parent:reset_slinger()
            return parent:get_GUI020002_pnl()
        end
    end)
    setmetatable(o, self)
    ---@cast o SlingerReticleFocus

    ---@diagnostic disable-next-line: missing-fields
    o.children.slinger = slinger:new({}, o, function(s, hudbase, gui_id, ctrl)
        return s:get_slinger_pnl()
    end, nil, nil, true)
    return o
end

---@protected
---@param ctrl via.gui.Control
---@return boolean
function this:_write(ctrl)
    self.children.slinger:apply_other(self)
    hud_child._write(self, ctrl)

    return true
end

---@param ctrl via.gui.Control
---@param key SlingerReticleSlingerWriteKey
function this:reset_ctrl(ctrl, key)
    ---@diagnostic disable-next-line: param-type-mismatch
    hud_child.reset_ctrl(self, ctrl, key)
    ---@diagnostic disable-next-line: param-type-mismatch
    self.children.slinger:reset_ctrl(self.children.slinger:get_slinger_pnl(), key)
end

---@return SlingerReticleFocusConfig
function this.get_config()
    local base = hud_child.get_config("focus") --[[@as SlingerReticleFocusConfig]]
    local children = base.children
    children.slinger = {
        name_key = "__slinger",
    }

    return base
end

return this
