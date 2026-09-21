---@class (exact) Combo<K, V, R>
---@field values string[]
---@field map {key: K, value: string}[]
---@field sort_fn (fun(a: {key: K, value: string}, b: {key: K, value: string}): boolean)?
---@field map_fn (fun(value: V, key: K): string)?
---@field _translate_fn (fun(key: K, value: string): string)?
---@field _is_disabled_fn (fun(self: Combo): boolean)?
---@field _getter_fn (fun(self: Combo): R?)?
---@field disabled {key: K, value: string}[]

---@class (exact) ComboOptionalArgs<K, V, R>
---@field sort_fn (fun(a: {key: K, value: string}, b: {key: K, value: string}): boolean)?
---@field map_fn (fun(value: V, key: K): string)?
---@field translate_fn (fun(key: K, value: string): string)?
---@field is_disabled_fn (fun(self: Combo): boolean)?
---@field getter_fn (fun(self: Combo<K, V, R>): R?)?
---@field swap_fn (fun(self: Combo, key_to_value: table<K, V>, current_index: integer?, disabled_keys: K[]?): integer?)?
---@field disabled_keys K[]?

local util_table = require("HudController.util.misc.table")

---@class Combo
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param key_to_value table<K, V>?
---@param optional_args ComboOptionalArgs<K ,V, R>?
---@return Combo
function this:new(key_to_value, optional_args)
    optional_args = optional_args or {}

    local o = {
        sort_fn = optional_args.sort_fn,
        map_fn = optional_args.map_fn,
        _translate_fn = optional_args.translate_fn,
        _is_disabled_fn = optional_args.is_disabled_fn,
        _getter_fn = optional_args.getter_fn,
        disabled = {},
        map = {},
        values = {},
    }
    if key_to_value then
        this._map(o, key_to_value)
    end

    setmetatable(o, self)
    ---@cast o Combo

    if optional_args.swap_fn then
        o.swap = optional_args.swap_fn
    end

    for _, key in pairs(optional_args.disabled_keys or {}) do
        o:disable_item(key)
    end
    return o
end

---@overload fun(key_to_value: table<any, any>, current_index: integer): integer
---@overload fun(key_to_value: table<any, any>)
---@param key_to_value table
---@param current_index integer?
---@param disabled_keys any[]?
---@return integer?
function this:swap(key_to_value, current_index, disabled_keys)
    self.disabled = {}
    local ret = 1

    if current_index then
        local current_value = self.map[current_index]
        local current_key = current_value and current_value.key
        ret = current_key and current_index or 1

        self:_map(key_to_value)
        if self._translate_fn then
            self:translate()
        end

        if current_key then
            ret = util_table.index(self.map, function(o)
                return o.key == current_key
            end) or 1
        end

        self:disable_items(disabled_keys or {})
    else
        self:_map(key_to_value)
        self:disable_items(disabled_keys or {})
    end

    return ret
end

---@overload fun(key_to_value: table, current_index: integer): integer
---@overload fun(key_to_value: table)
---@param key_to_value table
---@param current_index integer?
---@param disabled_keys any[]?
---@return integer?
function this:swap_init(key_to_value, current_index, disabled_keys)
    self.disabled = {}

    self:_map(key_to_value)
    if self._translate_fn then
        self:translate()
    end

    self:disable_items(disabled_keys or {})
    if current_index then
        if self.map[current_index] then
            return current_index
        else
            return 1
        end
    end
end

---@param current_index integer?
function this:translate(current_index)
    if not self._translate_fn then
        return
    end

    self.values = {}
    local current_item = self.map[current_index or 1] or {}
    local current_key = current_item.key

    for _, v in pairs(self.map) do
        v.value = self._translate_fn(v.key, v.value)
    end

    for _, v in pairs(self.disabled) do
        v.value = self._translate_fn(v.key, v.value)
    end

    if self.sort_fn then
        table.sort(self.map, self.sort_fn)
    end

    for i = 1, #self.map do
        local m = self.map[i]
        table.insert(self.values, m.value)
    end

    return util_table.index(self.map, function(o)
        return o.key == current_key
    end) or 1
end

function this:is_disabled()
    if self:empty() then
        return true
    end

    if self._is_disabled_fn then
        return self:_is_disabled_fn()
    end

    return false
end

---@param index integer
---@return K
function this:get_key(index)
    local ret = self.map[index]
    if ret then
        return ret.key
        ---@diagnostic disable-next-line: missing-return
    end
end

---@param index integer
---@return string
function this:get_value(index)
    return self.map[index].value
end

---@return R
function this:get()
    if self._getter_fn then
        ---@diagnostic disable-next-line: return-type-mismatch
        return self:_getter_fn()
        ---@diagnostic disable-next-line: missing-return
    end
end

---@param key K?
---@param value string?
---@return {key: K, value: string}
function this:get_disabled(key, value)
    ---@diagnostic disable-next-line: return-type-mismatch
    return util_table.find_value(self.disabled, function(_, item)
        return key == item.key or value == item.value
    end)
end

---@param key K?
---@param value string?
---@return integer
function this:disable_item(key, value)
    local index = self:get_index(key, value)
    if index then
        local item = table.remove(self.map, index)
        table.insert(self.disabled, item)
        table.remove(self.values, index)

        if index <= #self.values then
            return index
        else
            return math.max(index - 1, 1)
        end
    end

    return 1
end

---@param key K?
---@param value string?
---@return integer
function this:enable_item(key, value)
    ---@type integer
    local index

    if key then
        index = util_table.index(self.disabled, function(o)
            return o.key == key
        end) --[[@as integer]]
    elseif value then
        index = util_table.index(self.disabled, function(o)
            return o.value == value
        end) --[[@as integer]]
    end

    local item = table.remove(self.disabled, index)
    table.insert(self.map, item)

    if self.sort_fn then
        table.sort(self.map, self.sort_fn)
    end

    self.values = {}
    for i = 1, #self.map do
        local m = self.map[i]
        table.insert(self.values, m.value)
    end

    return self:get_index(key, value) --[[@as integer]]
end

function this:enable_all_items()
    for _, v in pairs(util_table.values(self.disabled)) do
        ---@diagnostic disable-next-line: param-type-mismatch
        self:enable_item(v.key)
    end
end

function this:disable_all_items()
    for _, v in pairs(util_table.values(self.map)) do
        self:disable_item(v.key)
    end
end

---@param keys K[]
function this:disable_items(keys)
    for _, key in pairs(keys) do
        self:disable_item(key)
    end
end

---@param keys K[]
function this:enable_items(keys)
    for _, key in pairs(keys) do
        self:enable_item(key)
    end
end

---@param key K?
---@param value string?
---@return integer?
function this:get_index(key, value)
    if key then
        return util_table.index(self.map, function(o)
            return o.key == key
        end)
    end

    if value then
        return util_table.index(self.map, function(o)
            return o.value == value
        end)
    end
end

---@return integer
function this:size()
    return #self.values
end

---@return boolean
function this:empty()
    return util_table.empty(self.values)
end

---@param key_to_value table<K, V>
function this:_map(key_to_value)
    self.values = {}
    self.map = {}

    local t = key_to_value
    if self.map_fn then
        t = util_table.transform_items(t, nil, self.map_fn)
    end

    for k, v in pairs(t) do
        table.insert(self.map, { key = k, value = v })
    end

    if self.sort_fn then
        table.sort(self.map, self.sort_fn)
    end

    for i = 1, #self.map do
        local m = self.map[i]
        table.insert(self.values, m.value)
    end
end

---@param query string
---@return {key: K, value: string}[]
function this:filter_by_key(query)
    ---@type {key: K, value: string}[]
    local ret = {}
    query = query:lower()
    for _, m in ipairs(self.map) do
        local key = tostring(m.key):lower()
        if query == "" or key:match(query) then
            table.insert(ret, m)
        end
    end

    return ret
end

---@param query string
---@return {key: K, value: string}[]
function this:filter_by_value(query)
    ---@type {key: K, value: string}[]
    local ret = {}
    query = query:lower()
    for _, m in ipairs(self.map) do
        local v = m.value:lower()
        if query == "" or v:match(query) then
            table.insert(ret, m)
        end
    end

    return ret
end

---@param key K
---@return string
function this:get_value_by_key(key)
    local index = self:get_index(key) --[[@as integer]]
    return self:get_value(index)
end

---@param key K
---@return string
function this:find_disabled(key)
    for _, map in pairs(self.disabled) do
        if map.key == key then
            return map.value
        end
        ---@diagnostic disable-next-line: missing-return
    end
end

---@return string[]
function this:get_values()
    return util_table.collect(util_table.iterator(function(index)
        local m = self.map[index]
        if m then
            return self.map[index].value
        end
    end))
end

---@return K[]
function this:get_keys()
    return util_table.collect(util_table.iterator(function(index)
        local m = self.map[index]
        if m then
            return self.map[index].key
        end
    end))
end

return this
