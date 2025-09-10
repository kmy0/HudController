---@class FrameTimer : Timer

local frame_counter = require("HudController.util.misc.frame_counter")
local timer = require("HudController.util.misc.timer")

---@class FrameTimer
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = timer })

---@param key string
---@param limit integer
---@param callback fun()?
---@param start_finished boolean?
---@param restart_on_finish boolean?
function this.new(key, limit, callback, start_finished, restart_on_finish)
    local o = timer.new(key, limit, callback, start_finished, restart_on_finish)
    setmetatable(o, this)
    ---@cast o FrameTimer
    o.now = frame_counter.frame
    o.start_time = frame_counter.frame
    this._instances[key] = o
    return o
end

---@protected
---@return number
function this:_update()
    self.now = frame_counter.frame
    return self.now
end

---@protected
function this:_restart()
    self._finished = false
    self.start_time = frame_counter.frame
    self._do_restart = false
end

return this
