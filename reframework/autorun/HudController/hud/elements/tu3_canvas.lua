---@class (exact) TU3_Canvas : HudBase
---@field panel_pos via.gui.Control?

local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local hud_base = require("HudController.hud.def.hud_base")
local util_mod = require("HudController.util.mod.init")

local mod = data.mod

---@class TU3_Canvas
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args HudBaseConfig
---@return TU3_Canvas
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o TU3_Canvas
    return o
end

---@return via.gui.Control
function this:get_panel_position()
    if not self.panel_pos then
        self.panel_pos = util_mod.get_gui_cls("app.GUI020902")._PanelPosition
    end

    return self.panel_pos
end

---@protected
---@param ctrl via.gui.Control
---@return boolean
function this:_write(ctrl)
    if self.offset then
        self:get_panel_position():set_PlayState("DEFAULT")
    end

    return hud_base._write(self, ctrl)
end

---@return HudBaseConfig
function this.get_config()
    local base = hud_base.get_config(e.get_noexact("app.GUIHudDef.TYPE").TU3_CANVAS, "TU3_CANVAS")
    base.hud_type = mod.enum.hud_type.TU3_CANVAS
    return base
end

return this
