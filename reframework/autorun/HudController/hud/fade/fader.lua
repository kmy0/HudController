---@class (exact) Fader
---@field hud_type app.GUIHudDef.TYPE
---@field dir integer
---@field from number
---@field to number
---@field step number
---@field ctrl via.gui.Control[]
---@field current_opacity number
---@field level integer
---@field speed_mod number
---@field synchronized boolean
---@field next Fader?
---@field stage_finished boolean
---@field free_value any
---@field free_value2 any
---@field on_start fun(fader: Fader)?
---@field on_finish fun(fader: Fader)?

---@class (exact) FaderOptionalArgs
---@field on_start fun(fader: Fader)?
---@field on_finish fun(fader: Fader)?
---@field next Fader?
---@field synchronized boolean?
---@field free_value any
---@field free_value2 any

local util_game = require("HudController.util.game.init")
---@class Fader
local this = {}

---@diagnostic disable-next-line: inject-field
this.__index = this

---@param hud_type app.GUIHudDef.TYPE
---@param ctrl via.gui.Control[]
---@param from number
---@param to number
---@param duration number
---@param optional_args FaderOptionalArgs?
---@return Fader
function this:new(hud_type, ctrl, from, to, duration, optional_args)
    optional_args = optional_args or {}

    local dir = to > from and 1 or -1
    local dist = math.abs(from - to)

    local o = {
        hud_type = hud_type,
        dir = dir,
        from = from,
        to = to,
        ctrl = ctrl,
        step = (
            duration > 0 and dist / (duration / util_game.get_time_delta())
            or 1 --[[@as number]]
        ) * dir,
        current_opacity = from,
        next = optional_args.next,
        level = 1,
        on_finish = optional_args.on_finish,
        on_start = optional_args.on_start,
        speed_mod = 1,
        synchronized = optional_args.synchronized ~= false,
        stage_finished = false,
        free_value = optional_args.free_value,
        free_value2 = optional_args.free_value2,
    }

    setmetatable(o, self)

    ---@cast o Fader
    return o
end

---@protected
---@param val number
function this:_update(val)
    for _, c in pairs(self.ctrl) do
        local color = c:get_ColorScale()
        color.w = val
        c:set_ColorScale(color)
    end
end

---@return boolean
function this:update_stage()
    if self.stage_finished then
        return true
    end

    local f = self.on_start
    if f then
        self.on_start = nil
        f(self)
        return false
    end

    if not self:is_done() then
        self.current_opacity = self.current_opacity + self.step * self.speed_mod

        ---@type number
        local val

        if self.dir > 0 then
            val = math.min(self.current_opacity, self.to)
        else
            val = math.max(self.to, self.current_opacity)
        end

        self:_update(val)
    end

    if self:is_done() then
        self.stage_finished = true

        f = self.on_finish
        if f then
            self.on_finish = nil
            f(self)
        end
    end

    return self.stage_finished
end

---@return boolean
function this:advance()
    if not self:is_waiting() then
        return false
    end

    local next_fader = self.next --[[@as Fader]]
    local next = next_fader.next
    local on_finish = next_fader.on_finish
    local on_start = next_fader.on_start

    local level = self.level
    local speed_mod = self.speed_mod
    local synchronized = self.synchronized

    ---@diagnostic disable-next-line: no-unknown
    for k, v in pairs(next_fader) do
        ---@diagnostic disable-next-line: no-unknown
        self[k] = v
    end

    self.next = next
    self.level = level + 1
    self.on_finish = on_finish
    self.on_start = on_start
    self.speed_mod = speed_mod
    self.synchronized = synchronized
    self.stage_finished = false

    return true
end

---@return boolean
function this:update()
    self:update_stage()

    if self:is_waiting() then
        self:advance()
        return false
    end

    return self:is_finished()
end

---@param mod number
function this:accelerate(mod)
    self.speed_mod = mod
end

---@return boolean
function this:is_done()
    if self.dir > 0 then
        return self.current_opacity >= self.to
    end

    return self.current_opacity <= self.to
end

---@return boolean
function this:is_waiting()
    return self.stage_finished and self.next ~= nil
end

---@return boolean
function this:is_finished()
    return self.stage_finished and self.next == nil
end

---@return boolean
function this:is_fade_out()
    return self.dir < 0
end

---@return boolean
function this:is_fade_in()
    return self.dir > 0
end

---@return integer
function this:get_level()
    return self.level
end

return this
