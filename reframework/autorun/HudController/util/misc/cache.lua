---@class (exact) Cache
---@field memoize fun(func: (fun(...): any), predicate: (fun(cached_value: any, key: any?): boolean)?, do_hash: boolean?, deep_hash_table: boolean?): any
---@field clear_all fun()
---@field protected _map table<any, any>

local hash = require("HudController.util.misc.hash")

---@class Cache
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
---@type Cache[]
---@diagnostic disable-next-line: inject-field
this.instances = setmetatable({}, { __mode = "v" })

---@return Cache
function this:new()
    local o = {
        _map = {},
    }
    setmetatable(o, self)
    ---@cast o Cache
    table.insert(this.instances, self)
    return o
end

---@param key any
---@param value any
function this:set(key, value)
    ---@diagnostic disable-next-line: no-unknown
    self._map[key] = value
end

---@param key any
---@return any
function this:get(key)
    return self._map[key]
end

---@param deep_hash_table boolean?
---@param ... any
---@return any, string
function this:get_hashed(deep_hash_table, ...)
    local key = hash.hash_args(deep_hash_table, ...)
    return self:get(key), key
end

function this:clear()
    self._map = {}
end

---@param func fun(...): any
---@param predicate (fun(cached_value: any, key: any?): boolean)?
---@param do_hash boolean?
---@param deep_hash_table boolean?
---@return fun(...): any
function this.memoize(func, predicate, do_hash, deep_hash_table)
    local cache = this:new()

    return function(...)
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

        local cached = cache:get(key)

        if cached ~= nil and (not predicate or (predicate and predicate(cached, key))) then
            return cached
        end

        local ret = func(...)
        cache:set(key, ret)
        return ret
    end
end

function this.clear_all()
    for _, o in pairs(this.instances) do
        o:clear()
    end
end

return this
