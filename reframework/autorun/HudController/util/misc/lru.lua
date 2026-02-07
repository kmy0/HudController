-- based on https://github.com/starius/lua-lru

---@class (exact) LRUTuple : [any, LRUTuple, LRUTuple, any]

---@class LRU : Cache
---@field max_size integer
---@field protected _size integer
---@field protected _map table<any, LRUTuple>
---@field protected _newest LRUTuple?
---@field protected _oldest LRUTuple?
---@field protected _removed LRUTuple?

local cache = require("HudController.util.misc.cache")
local hash = require("HudController.util.misc.hash")

---@class LRU
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = cache })

local VALUE = 1
local PREV = 2
local NEXT = 3
local KEY = 4

---@param max_size integer
---@return LRU
function this:new(max_size)
    local o = cache.new(self)
    setmetatable(o, self)
    ---@cast o LRU
    o.max_size = max_size
    o._size = 0
    return o
end

---@param key any
---@param value any
function this:set(key, value)
    local exists = self._map[key]
    if exists then
        self:_del(key, exists)
    end

    self:_free_space()
    local tuple = self._removed or {}
    self._map[key] = tuple
    self._map[key] = tuple
    tuple[VALUE] = value
    tuple[KEY] = key
    self._size = self._size + 1
    self:_set_newest(tuple)
    self._removed = nil
end

---@param key any
---@return any
function this:get(key)
    local tuple = self._map[key]
    if not tuple then
        return nil
    end
    self:_cut(tuple)
    self:_set_newest(tuple)
    return tuple[VALUE]
end

---@param key any
function this:delete(key)
    self:set(key, nil)
end

---@protected
---@param tuple LRUTuple
function this:_set_newest(tuple)
    if not self._newest then
        self._newest = tuple
        self._oldest = tuple
    else
        tuple[NEXT] = self._newest
        self._newest[PREV] = tuple
        self._newest = tuple
    end
end

---@protected
function this:_free_space()
    while self._size + 1 > self.max_size do
        self:_del(self._oldest[KEY], self._oldest)
    end
end

---@protected
---@param key any
---@param tuple LRUTuple
function this:_del(key, tuple)
    self._map[key] = nil
    self:_cut(tuple)
    self._size = self._size - 1
    self._removed = tuple
end

---@protected
---@param tuple LRUTuple
function this:_cut(tuple)
    local tuple_prev = tuple[PREV]
    local tuple_next = tuple[NEXT]
    tuple[PREV] = nil
    tuple[NEXT] = nil
    if tuple_prev and tuple_next then
        tuple_prev[NEXT] = tuple_next
        tuple_next[PREV] = tuple_prev
    elseif tuple_prev then
        tuple_prev[NEXT] = nil
        self._oldest = tuple_prev
    elseif tuple_next then
        tuple_next[PREV] = nil
        self._newest = tuple_next
    else
        self._newest = nil
        self._oldest = nil
    end
end

---@generic T: fun(...): any
---@param func T
---@param size integer
---@param predicate (fun(cached_value: any, key: any?): boolean)?
---@param do_hash boolean?
---@param deep_hash_table boolean?
---@param key_index integer?
---@return T
function this.memoize(func, size, predicate, do_hash, deep_hash_table, key_index)
    local _cache = this:new(size)

    local wrapped = {
        clear = function()
            cache:clear()
        end,
    }
    setmetatable(wrapped, {
        __call = function(_, ...)
            ---@type any
            local key
            if do_hash then
                key =
                    ---@diagnostic disable-next-line: param-type-mismatch
                    hash.hash_args(deep_hash_table, not key_index and ... or select(key_index, ...))
            else
                if select("#", ...) > 0 then
                    ---@diagnostic disable-next-line: no-unknown
                    key = select(key_index or 1, ...)
                else
                    key = 1
                end
            end

            local cached = _cache:get(key)
            if cached ~= nil and (not predicate or (predicate and predicate(cached, key))) then
                return cached
            end

            ---@diagnostic disable-next-line: no-unknown
            local ret = func(...)
            _cache:set(key, ret)
            return ret
        end,
    })

    return wrapped
end

return this
