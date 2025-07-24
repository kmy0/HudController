---@class Timer
---@field key string
---@field start_time integer
---@field limit integer
---@field now integer
---@field callback fun()?
---@field protected _finished boolean
---@field protected _do_call boolean
---@field protected _do_restart boolean
---@field protected _instances table<string, Timer>

---@class Timer
local this = {}
this.__index = this
this._instances = {}

---@param key string
---@param limit integer
---@param callback fun()?
---@param start_finished boolean?
function this.new(key, limit, callback, start_finished)
    local now = os.clock()
    local o = {
        key = key,
        start_time = now,
        now = now,
        limit = limit,
        callback = callback,
        _finished = start_finished and true or false,
        _do_restart = false,
        _do_call = true,
    }
    setmetatable(o, this)
    ---@cast o Timer
    this._instances[key] = o
    return o
end

---@protected
---@return number
function this:_update()
    self.now = os.clock()
    return self.now
end

---@protected
function this:_restart()
    self._finished = false
    self.start_time = os.clock()
    self._do_call = true
    self._do_restart = false
end

---@return number
function this:elapsed()
    return self.now - self.start_time
end

---@return number
function this:remaining()
    return self.limit - self:elapsed()
end

function this:restart()
    self._do_restart = true
end

---@return boolean
function this:update()
    if self._do_restart then
        self:_restart()
    end

    if self._finished then
        return self._finished
    end

    self:_update()
    self._finished = self:elapsed() >= self.limit

    if self._finished and self.callback and self._do_call then
        self.callback()
        self._do_call = false
    end

    return self._finished
end

function this.iter()
    for _, t in pairs(this._instances) do
        t:update()
    end
end

---@param key string
---@param limit integer
---@param callback fun()?
---@param start_finished boolean?
function this.check(key, limit, callback, start_finished)
    local timer = this._instances[key]
    if not timer then
        timer = this.new(key, limit, callback, start_finished)
    end

    timer.limit = limit
    timer.callback = callback

    return timer:update()
end

---@param key string
function this.restart_key(key)
    local timer = this._instances[key]
    if timer then
        timer:restart()
    end
end

---@param key string
---@return integer
function this.remaining_key(key)
    local timer = this._instances[key]
    if not timer or timer:update() then
        return 0
    end
    return timer:remaining()
end

---@param key string
function this.reset_key(key)
    local timer = this._instances[key]
    if timer then
        timer._finished = true
    end
end

return this
