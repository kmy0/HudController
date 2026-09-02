---@class Timer
---@field timeout integer
---@field auto_restart boolean
---@field callback fun()?
---@field protected _started_at integer
---@field protected _now integer
---@field protected _finished boolean
---@field protected _started boolean
---@field protected _auto_instances Timer[]
---@field protected _one_time_instances table<any, Timer>
---@field protected _updated_frame integer
---@field protected _auto_update boolean
---@field protected _type TimerType

---@alias TimerType "os_clock" | "time_delta" | "frame"

---@class TimerOptionalArgs
---@field callback fun()?
---@field auto_start boolean?
---@field auto_restart boolean?
---@field auto_update boolean?
---@field type TimerType? by default, os_clock

---@class TimerUpdateOptionalArgs : TimerOptionalArgs
---@field timeout integer?
---@field auto_update nil
---@field type nil

local frame_counter = require("HudController.util.misc.frame_counter")

---@class Timer
local this = {}
this.__index = this
this._auto_instances = setmetatable({}, { __mode = "v" })
this._one_time_instances = {}

---@param timeout integer
---@param optional_args TimerOptionalArgs?
function this:new(timeout, optional_args)
    optional_args = optional_args or {}
    local o = {
        auto_restart = optional_args.auto_restart and true or false,
        timeout = timeout,
        callback = optional_args.callback,
        _finished = false,
        _started = false,
        _update_frame = 0,
        _auto_update = optional_args.auto_update,
        _type = optional_args.type or "os_clock",
    }
    setmetatable(o, self)
    ---@cast o Timer

    if optional_args.auto_start then
        o:start()
    end

    if optional_args.auto_update then
        table.insert(this._auto_instances, o)
    end

    o.elapsed = o._update_on_call(o, o.elapsed)
    o.remaining = o._update_on_call(o, o.remaining)
    o.active = o._update_on_call(o, o.active)
    o.finished = o._update_on_call(o, o.finished)

    return o
end

---@param key any
---@param timeout number
---@param callback fun()
---@param type TimerType? by default, os_clock
function this.request_one_timer(key, timeout, callback, type)
    local t = this._one_time_instances[key]
    if t then
        t:restart()
    else
        this._one_time_instances[key] =
            this:new(timeout, { callback = callback, type = type, auto_start = true })
    end
end

---@protected
---@generic T: fun(...)
---@param fn T
---@return T
function this:_update_on_call(fn)
    return function(...)
        if not self._auto_update then
            self:update()
        end

        return fn(...)
    end
end

---@protected
---@return number
function this:_get_time()
    if self._type == "os_clock" then
        return os.clock()
    elseif self._type == "frame" then
        return frame_counter.frame
    elseif self._type == "time_delta" then
        local time_counter = require("HudController.util.misc.time_counter")
        return time_counter.time
    end

    return os.clock()
end

---@protected
---@return number
function this:_update()
    self._now = self:_get_time()
    return self._now
end

---@param optional_args TimerUpdateOptionalArgs?
function this:update_args(optional_args)
    optional_args = optional_args or {}
    self.timeout = optional_args.timeout or self.timeout
    self.callback = optional_args.callback or self.callback

    if optional_args.auto_restart ~= nil then
        self.auto_restart = optional_args.auto_restart
    end
end

---@param optional_args TimerUpdateOptionalArgs?
function this:start(optional_args)
    optional_args = optional_args or {}
    self:update_args(optional_args)
    if not self._started then
        local now = self:_get_time()
        self._now = now
        self._started_at = now
        self._started = true
    end
end

---@return number
function this:elapsed()
    if not self._started then
        return 0
    end
    return self._now - self._started_at
end

---@return boolean
function this:started()
    return self._started
end

---@return number
function this:remaining()
    return math.max(0, self.timeout - self:elapsed())
end

---@param optional_args TimerUpdateOptionalArgs?
function this:restart(optional_args)
    self._finished = false
    self._started = false
    self:start(optional_args)
end

---@return boolean
function this:active()
    return self._started and not self._finished
end

function this:update()
    if frame_counter.frame == self._updated_frame then
        return
    end

    self._updated_frame = frame_counter.frame

    if not self._started or self._finished then
        return
    end

    self:_update()
    self._finished = self:elapsed() >= self.timeout

    if self._finished and self.callback then
        self.callback()
    end

    if self._finished and self.auto_restart then
        self:restart()
    end
end

---@return boolean
function this:finished()
    return self._started and self._finished
end

function this:abort()
    self._finished = true
    self._started = false
    self._now = nil
    self._started_at = nil
end

function this:abort_and_execute()
    if self._started and not self._finished and self.callback then
        self.callback()
    end
    self:abort()
end

re.on_frame(function()
    for _, t in pairs(this._auto_instances) do
        t:update()
    end

    for key, t in pairs(this._one_time_instances) do
        t:update()
        if t:finished() then
            this._one_time_instances[key] = nil
        end
    end
end)

return this
