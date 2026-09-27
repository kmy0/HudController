---@class FrameCache : Cache
---@field protected _map_frame table<any, integer>
---@field protected _frame_key table
---@field max_frame integer
---@field jitter integer

---@class (exact) FrameCacheMemoizeOptionalArgs : CacheMemoizeOptionalArgs
---@field max_frame integer?
---@field jitter integer?

local cache = require("HudController.util.misc.cache")
local frame_counter = require("HudController.util.misc.frame_counter")

---@class FrameCache
local this = {}
this.__index = this
setmetatable(this, { __index = cache })
this._frame_key = {}

---@param max_frame integer? by default, 0
---@param jitter integer? by default, 0
---@return FrameCache
function this:new(max_frame, jitter)
    local o = cache.new(self)
    setmetatable(o, self)
    ---@cast o FrameCache

    o.max_frame = max_frame or 0
    o.jitter = jitter or 0
    o._map_frame = {}

    return o
end

---@return integer
function this:_expiry()
    return frame_counter.frame + self.max_frame + math.random(0, self.jitter)
end

---@param key any
---@param value any
function this:set(key, value)
    self._map[key] = value
    self._map_frame[key] = self:_expiry()
end

---@param key any
---@return any
function this:get(key)
    local expiry = self._map_frame[key]

    if expiry == nil then
        return nil
    end

    if frame_counter.frame <= expiry then
        return self._map[key]
    end

    self._map[key] = nil
    self._map_frame[key] = nil
end

---@param node table
---@return any
function this:_get_hashed_value(node)
    ---@diagnostic disable-next-line: no-unknown
    local expiry = node[self._frame_key]

    if expiry == nil then
        return nil
    end

    if frame_counter.frame <= expiry then
        return node[self._value_key]
    end

    ---@diagnostic disable-next-line: no-unknown
    node[self._value_key] = nil
    ---@diagnostic disable-next-line: no-unknown
    node[self._frame_key] = nil
end

---@param node table
---@param value any
function this:_set_hashed_value(node, value)
    ---@diagnostic disable-next-line: no-unknown
    node[self._value_key] = value
    ---@diagnostic disable-next-line: no-unknown
    node[self._frame_key] = self:_expiry()
end

function this:clear()
    self._map_frame = {}
    cache.clear(self)
end

---@generic T: fun(...): any
---@param func T
---@param optional_args FrameCacheMemoizeOptionalArgs?
---@return T
function this.memoize(func, optional_args)
    local opts = optional_args or {}
    local frame_cache = this:new(opts.max_frame, opts.jitter)

    local key_index = opts.key_index or 1
    local key_as_string = opts.key_as_string
    local key_fn = opts.key_fn

    local wrapped = {
        clear = function()
            frame_cache:clear()
        end,
    }

    setmetatable(wrapped, {
        __call = function(_, ...)
            ---@type any
            local key

            if key_fn then
                key = key_fn(...)
            elseif select("#", ...) > 0 then
                key = select(key_index, ...)
            else
                key = 1
            end

            if key_as_string then
                key = tostring(key)
            end

            local cached = frame_cache:get(key)

            if cached ~= nil then
                return cached
            end

            ---@diagnostic disable-next-line: no-unknown
            local ret = func(...)
            frame_cache:set(key, ret)

            return ret
        end,
    })

    ---@diagnostic disable-next-line: return-type-mismatch
    return wrapped
end

return this
