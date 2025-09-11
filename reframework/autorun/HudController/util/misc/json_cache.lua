---@class (exact) DumpedJsonCache
---@field boot_time integer
---@field cache table<string, any>

---@class JsonCache : Cache
---@field boot_time integer
---@field path string
---@field memoize nil
---@field protected _json_key_map table<string, any>
---@field protected _map_key_json table<string, any>
---@field protected _json_map table<string, any>
---@field protected _do_dump boolean

local cache = require("HudController.util.misc.cache")
local util_misc = require("HudController.util.misc.init")

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
    o._json_key_map = {}
    o._json_map = {}
    o._map_key_json = {}
    o._do_dump = true
    o._clearable = false
    o.memoize = nil
    o.boot_time = util_misc.get_boot_time()

    return o
end

---@param key any
---@return string
function this:to_json_key(key)
    if self._map_key_json[key] then
        return self._map_key_json[key]
    end

    local json_key = tostring(key)
    self._map_key_json[key] = json_key
    self._json_key_map[json_key] = key
    return json_key
end

---@param func fun()
function this:with_dump(func)
    self._do_dump = false
    func()
    self._do_dump = true
    self:dump()
end

---@param json_key string
function this:remove_by_json_key(json_key)
    local key = self._json_key_map[json_key]
    self._json_map[json_key] = nil
    self._json_key_map[json_key] = nil

    if key then
        self._map[key] = nil
        self._map_key_json[key] = nil
    end

    if self._do_dump then
        self:dump()
    end
end

---@param key any
function this:remove_by_key(key)
    local json_key = self:to_json_key(key)
    self._json_map[json_key] = nil
    self._json_key_map[json_key] = nil
    self._map[key] = nil
    self._map_key_json[key] = nil

    if self._do_dump then
        self:dump()
    end
end

---@param key any
---@return any
function this:get(key)
    if self._map[key] then
        return self._map[key]
    end

    local json_key = self:to_json_key(key)
    if self._json_map[json_key] then
        self._map[key] = self._json_map[json_key]
        return self._map[key]
    end
end

---@param key any
---@param value any
function this:set(key, value)
    local json_key = self:to_json_key(key)
    self._map[key] = value
    self._json_map[json_key] = value

    if self._do_dump then
        self:dump()
    end
end

function this:dump()
    json.dump_file(self.path, { boot_time = self.boot_time, cache = self._json_map })
end

function this:clear()
    self._json_map = {}
    self._json_key_map = {}
    self._map_key_json = {}
    cache.clear(self)
    self:dump()
end

---@return boolean
function this:init()
    local t = json.load_file(self.path) --[[@as DumpedJsonCache?]]
    if t and math.abs(self.boot_time - t.boot_time) < 5 then
        self._json_map = t.cache or {}
    else
        self:dump()
    end

    return true
end

return this
