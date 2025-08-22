---@class FrameCache : Cache
---@field protected _map_frame table<any, any>
---@field max_frame integer

local cache = require("HudController.util.misc.cache")
local frame_counter = require("HudController.util.misc.frame_counter")
local hash = require("HudController.util.misc.hash")

---@class FrameCache
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = cache })

---@param max_frame integer? by default, 0
---@return FrameCache
function this:new(max_frame)
    local o = cache.new(self)
    setmetatable(o, self)
    ---@cast o FrameCache
    o.max_frame = max_frame or 0
    o._map_frame = {}
    return o
end

---@param key any
---@param value any
function this:set(key, value)
    ---@diagnostic disable-next-line: no-unknown
    self._map[key] = value
    self._map_frame[key] = frame_counter.frame
end

---@param key any
---@return any
function this:get(key)
    if self._map_frame[key] and frame_counter.frame - self._map_frame[key] <= self.max_frame then
        return self._map[key]
    end

    self._map[key] = nil
end

function this:clear()
    self._map_frame = {}
    cache.clear(self)
end

---@generic T: fun(...): any
---@param func T
---@param max_frame integer?
---@param do_hash boolean?
---@param deep_hash_table boolean?
---@return T
function this.memoize(func, max_frame, do_hash, deep_hash_table)
    local frame_cache = this:new(max_frame)

    local wrapped = {
        clear = function()
            frame_cache:clear()
        end,
    }
    setmetatable(wrapped, {
        __call = function(self, ...)
            ---@type any
            local key
            if do_hash then
                key = hash.hash_args(deep_hash_table, ...)
            else
                key = { ... }
                if #key > 0 then
                    ---@diagnostic disable-next-line: no-unknown
                    key = key[1]
                else
                    key = 1
                end
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
