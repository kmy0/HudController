---@class Cache
---@field protected _map table<any, any>
---@field protected _clearable boolean
---@field protected _nil_key table
---@field protected _value_key table

---@class (exact) CacheMemoizeOptionalArgs
---@field key_index integer?
---@field key_as_string boolean?
---@field predicate (fun(cached_value: any, key: any?): boolean)?
---@field key_fn (fun(...): any)?

---@class Cache
local this = {}
this.__index = this
---@type Cache[]
this._instances = setmetatable({}, { __mode = "v" })
this._nil_key = {}
this._value_key = {}

---@return Cache
function this:new()
    local o = {
        _map = {},
        _clearable = true,
    }

    setmetatable(o, self)
    ---@cast o Cache

    table.insert(this._instances, o)
    return o
end

---@param key any
---@param value any
function this:set(key, value)
    self._map[key] = value
end

---@param key any
---@return any
function this:get(key)
    return self._map[key]
end

---@param node table
---@return any
function this:_get_hashed_value(node)
    return node[self._value_key]
end

---@param node table
---@param value any
function this:_set_hashed_value(node, value)
    ---@diagnostic disable-next-line: no-unknown
    node[self._value_key] = value
end

---@param ... any
---@return any
function this:get_hashed(...)
    local node = self._map

    for i = 1, select("#", ...) do
        local key = select(i, ...)

        if key == nil then
            key = self._nil_key
        end

        node = node[key]

        if node == nil then
            return nil
        end
    end

    return self:_get_hashed_value(node)
end

---@param value any
---@param ... any
function this:set_hashed(value, ...)
    local node = self._map

    for i = 1, select("#", ...) do
        local key = select(i, ...)

        if key == nil then
            key = self._nil_key
        end

        local next_node = node[key]

        if next_node == nil then
            next_node = {}
            node[key] = next_node
        end

        node = next_node
    end

    self:_set_hashed_value(node, value)
end

function this:clear()
    self._map = {}
end

---@generic T: fun(...): any
---@param func T
---@param optional_args CacheMemoizeOptionalArgs?
---@return T
function this.memoize(func, optional_args)
    local cache = this:new()
    local opts = optional_args or {}

    local key_index = opts.key_index or 1
    local key_as_string = opts.key_as_string
    local predicate = opts.predicate
    local key_fn = opts.key_fn

    local wrapped = {
        clear = function()
            cache:clear()
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

            ---@diagnostic disable-next-line: invisible
            local cached = cache._map[key]
            if cached ~= nil and (not predicate or predicate(cached, key)) then
                return cached
            end

            ---@diagnostic disable-next-line: no-unknown
            local ret = func(...)
            ---@diagnostic disable-next-line: invisible
            cache._map[key] = ret

            return ret
        end,
    })

    return wrapped
end

function this.clear_all()
    for _, cache in pairs(this._instances) do
        if cache._clearable then
            cache:clear()
        end
    end
end

return this
