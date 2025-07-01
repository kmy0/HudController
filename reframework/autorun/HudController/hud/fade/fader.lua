---@class (exact) Fader
---@field hud_type app.GUIHudDef.TYPE
---@field dir integer
---@field from number
---@field to number
---@field step number
---@field progress number
---@field ctrl via.gui.Control
---@field current_opacity number

local util_game = require("HudController.util.game")

---@class Fader
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param hud_type app.GUIHudDef.TYPE
---@param from number
---@param to number
---@param time number
---@param ctrl via.gui.Control
---@return Fader
function this:new(hud_type, from, to, time, ctrl)
    local dir = to > from and 1 or -1
    local o = {
        hud_type = hud_type,
        dir = dir,
        from = from,
        to = to,
        ctrl = ctrl,
        step = (
            time > 0 and 1 / (time / util_game.get_time_delta()) or 1 --[[@as number]]
        ) * dir,
        progress = 0,
        current_opacity = from,
    }
    setmetatable(o, self)
    ---@cast o Fader
    return o
end

---@protected
function this:_update(val)
    local color = self.ctrl:get_ColorScale()
    color.w = val
    self.ctrl:set_ColorScale(color)
end

---@return boolean
function this:update()
    if not self:is_done() then
        self.current_opacity = self.current_opacity + self.step

        ---@type number
        local val
        if self.dir > 0 then
            val = math.min(self.current_opacity, self.to)
        else
            val = math.max(self.to, self.current_opacity)
        end

        self:_update(val)
        self.progress = 1 - math.abs(val - self.to)
        return false
    end
    return true
end

---@return boolean
function this:is_done()
    return self.progress >= 1
end

return this
