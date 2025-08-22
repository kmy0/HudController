---@class FrameCache : Cache
---@field map_frame table<any, any>

local cache = require("HudController.util.misc.cache")
local frame_counter = require("HudController.util.misc.frame_counter")
local hash = require("HudController.util.misc.hash")

local this = {}

---@generic T: fun(...): any
---@param func T
---@param do_hash boolean?
---@param deep_hash_table boolean?
---@return T
function this.memoize(func, do_hash, deep_hash_table)
    local frame_cache = cache:new() --[[@as FrameCache]]
    ---@diagnostic disable-next-line: invisible
    frame_cache.map_frame = {}

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

            if cached ~= nil and frame_counter.frame == frame_cache.map_frame[key] then
                return cached
            end

            ---@diagnostic disable-next-line: no-unknown
            local ret = func(...)
            frame_cache:set(key, ret)
            frame_cache.map_frame[key] = frame_counter.frame

            return ret
        end,
    })

    ---@diagnostic disable-next-line: return-type-mismatch
    return wrapped
end

return this
