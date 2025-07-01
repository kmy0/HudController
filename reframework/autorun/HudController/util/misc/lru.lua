-- based on https://github.com/starius/lua-lru

---@class (exact) LRUTuple : [any, LRUTuple, LRUTuple, any]

---@class (exact) LRU
---@field max_size integer
---@field memoize fun(func: (fun(...): any), size: integer, predicate: (fun(cached_value: any): boolean)?, deep_hash_table: boolean?): any
---@field protected _size integer
---@field protected _map table<any, LRUTuple>
---@field protected _newest LRUTuple?
---@field protected _oldest LRUTuple?
---@field protected _removed LRUTuple?

local hash = require("HudController.util.misc.hash")

---@class LRU
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

local VALUE = 1
local PREV = 2
local NEXT = 3
local KEY = 4

---@param max_size integer
---@return LRU
function this:new(max_size)
    local o = {
        max_size = max_size,
        _size = 0,
        _map = {},
    }
    setmetatable(o, self)
    ---@cast o LRU
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

---@param func fun(...): any
---@param size integer
---@param predicate (fun(cached_value: any): boolean)?
---@param deep_hash_table boolean?
---@return fun(...): any
function this.memoize(func, size, predicate, deep_hash_table)
    local cache = this:new(size)

    return function(...)
        local key = hash.hash_args(deep_hash_table, ...)
        local cached = cache:get(key)

        if cached ~= nil and (not predicate or (predicate and predicate(cached))) then
            return cached
        end

        local ret = func(...)
        cache:set(key, ret)
        return ret
    end
end

return this
