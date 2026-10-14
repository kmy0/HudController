---@class (exact) DumpedJsonCache
---@field thread_hash integer
---@field cache table<string, any>

---@class JsonCache : Cache
---@field thread_hash integer
---@field path string
---@field memoize nil
---@field protected _key_by_json_key table<string, any>
---@field protected _json_key_by_key table<string, any>
---@field protected _value_by_json_key table<string, any>
---@field protected _do_dump boolean
---@field protected _dumped_keys table<string, boolean>

local cache = require("HudController.util.misc.cache")
local util_misc = require("HudController.util.misc.util")

---@class JsonCache
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = cache })

---@param path string
---@return JsonCache
function this:new(path)
    local o = cache.new(self)
    setmetatable(o, self)
    ---@cast o JsonCache
    o.path = path
    o._key_by_json_key = {}
    o._value_by_json_key = {}
    o._json_key_by_key = {}
    o._do_dump = true
    o._dumped_keys = {}
    o._clearable = false
    o.memoize = nil
    o.thread_hash = thread.get_hash()

    return o
end

---@param enabled boolean
function this:set_auto_dump(enabled)
    self._do_dump = enabled
end

function this:enable_auto_dump()
    self:set_auto_dump(true)
end

function this:disable_auto_dump()
    self:set_auto_dump(false)
end

function this:snapshot_keys()
    self._dumped_keys = {}
    for json_key in pairs(self._value_by_json_key) do
        self._dumped_keys[json_key] = true
    end
end

---@return boolean
function this:keys_changed()
    for json_key in pairs(self._value_by_json_key) do
        if not self._dumped_keys[json_key] then
            return true
        end
    end

    for json_key in pairs(self._dumped_keys) do
        if self._value_by_json_key[json_key] == nil then
            return true
        end
    end

    return false
end

function this:dump_if_keys_changed()
    if self._do_dump and self:keys_changed() then
        self:dump()
    end
end

---@param key any
---@return string
function this:to_json_key(key)
    if self._json_key_by_key[key] then
        return self._json_key_by_key[key]
    end

    local json_key = tostring(key)
    self._json_key_by_key[key] = json_key
    self._key_by_json_key[json_key] = key
    return json_key
end

---@param func fun()
function this:with_dump(func)
    local do_dump = self._do_dump
    self._do_dump = false
    util_misc.try(function()
        func()
    end)
    self._do_dump = do_dump
    self:dump()
end

---@param json_key string
function this:remove_by_json_key(json_key)
    local key = self._key_by_json_key[json_key]
    self._value_by_json_key[json_key] = nil
    self._key_by_json_key[json_key] = nil

    if key then
        self._map[key] = nil
        self._json_key_by_key[key] = nil
    end

    self:dump_if_keys_changed()
end

---@param key any
function this:remove_by_key(key)
    local json_key = self:to_json_key(key)
    self._value_by_json_key[json_key] = nil
    self._key_by_json_key[json_key] = nil
    self._map[key] = nil
    self._json_key_by_key[key] = nil

    self:dump_if_keys_changed()
end

---@param key any
---@return any
function this:get(key)
    if self._map[key] ~= nil then
        return self._map[key]
    end

    local json_key = self:to_json_key(key)
    local value = self._value_by_json_key[json_key]
    if value ~= nil then
        self._map[key] = value
        return value
    end
end

---@param key any
---@param value any
function this:set(key, value)
    local json_key = self:to_json_key(key)
    self._map[key] = value
    self._value_by_json_key[json_key] = value

    self:dump_if_keys_changed()
end

function this:dump()
    json.dump_file(self.path, { thread_hash = self.thread_hash, cache = self._value_by_json_key })
    self:snapshot_keys()
end

function this:clear()
    self._value_by_json_key = {}
    self._key_by_json_key = {}
    self._json_key_by_key = {}
    cache.clear(self)
    self:dump()
end

---@return boolean
function this:init()
    local t = json.load_file(self.path) --[[@as DumpedJsonCache?]]
    if t and t.thread_hash == self.thread_hash then
        self._value_by_json_key = t.cache or {}
        self:snapshot_keys()
    else
        self:dump()
    end

    return true
end

return this
