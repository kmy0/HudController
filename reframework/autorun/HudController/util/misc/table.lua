---@diagnostic disable: no-unknown

local this = {}
local rl = {}

---@generic T: table
---@param original T
---@param copies T?
---@return T
local function deep_copy(original, copies)
    copies = copies or {}
    local original_type = type(original)
    local copy
    if original_type == "table" then
        if copies[original] then
            copy = copies[original]
        else
            copy = {}
            copies[original] = copy
            for original_key, original_value in next, original, nil do
                copy[deep_copy(original_key, copies)] = deep_copy(original_value, copies)
            end
            setmetatable(copy, deep_copy(getmetatable(original), copies))
        end
    else -- number, string, boolean, etc
        copy = original
    end
    return copy
end

---@param path string
---@return string[]
local function parse_path(path)
    local keys = this.split_path(path)

    for i = 1, #keys do
        ---@diagnostic disable-next-line: assign-type-mismatch
        keys[i] = this.parse_path_key(keys[i])
    end

    return keys
end

---@generic K, V
---@param table table<K, V>
---@param value V
---@param clear boolean?
---@return K
function this.reverse_lookup(table, value, clear)
    if not rl[table] or clear then
        rl[table] = {}

        for k, v in pairs(table) do
            rl[table][v] = k
        end
    end

    return rl[table][value]
end

---@generic T: table
---@param t T
---@param predicate fun(t: T, source_index: integer, target_index: integer): boolean
---@return T
function this.filter_inplace(t, predicate)
    local i, j, n = 1, 1, #t
    while i <= n do
        if predicate(t, i, j) then
            local k = i
            repeat
                i = i + 1
            until i > n or not predicate(t, i, j + i - k)
            --if (k ~= j) then
            table.move(t, k, i - 1, j)
            --end
            j = j + i - k
        end
        i = i + 1
    end
    table.move(t, n + 1, n + n - j + 1, j)
    return t
end

---@generic K, V
---@param t table<K, V>
---@param ... V
---@return boolean
function this.contains_any(t, ...)
    local values = { ... }
    for _, v in pairs(t) do
        for _, v2 in pairs(values) do
            if v == v2 then
                return true
            end
        end
    end
    return false
end

---@generic T: table
---@param original T
---@return T
function this.deep_copy(original)
    return deep_copy(original)
end

---@generic T: table
---@param first T
---@param ... table
---@return T
function this.merge(first, ...)
    local tables_to_merge = { ... }
    local result = this.deep_copy(first)

    for i = 1, #tables_to_merge do
        local from = tables_to_merge[i]
        for key, value in pairs(from) do
            if type(value) == "table" then
                result[key] = result[key] or {}
                assert(type(result[key]) == "table", string.format("Expected a table: '%s'", key))
                result[key] = this.merge(result[key], value)
            else
                result[key] = value
            end
        end
    end

    return result
end

---@generic T: table
---@param target T
---@param ... table
---@return T
function this.update(target, ...)
    local tables_to_merge = { ... }
    for i = 1, #tables_to_merge do
        local from = tables_to_merge[i]
        for key, value in pairs(from) do
            if type(value) == "table" then
                target[key] = target[key] or {}
                assert(type(target[key]) == "table", string.format("Expected a table: '%s'", key))
                target[key] = this.merge(target[key], value)
            else
                target[key] = value
            end
        end
    end

    return target
end

---@generic T: table
---@param protected string[]?
---@param ignore_empty boolean?
---@param ... T
---@return T
function this.merge_protected(protected, ignore_empty, ...)
    if protected == nil then
        protected = {}
    end

    if ignore_empty == nil then
        ignore_empty = false
    end

    local tables_to_merge = { ... }
    assert(#tables_to_merge > 1, "There should be at least two tables to merge them")

    for key, table in ipairs(tables_to_merge) do
        assert(
            type(table) == "table",
            string.format("Expected a table as function parameter %d", key)
        )
    end

    local result = this.deep_copy(tables_to_merge[1])

    for i = 2, #tables_to_merge do
        local from = tables_to_merge[i]
        for key, value in pairs(from) do
            if
                this.contains_any(protected, key)
                or ignore_empty
                    and result[key] == nil
                    and (type(key) ~= "string" or not key:find("_combo"))
            then
                goto continue
            end

            if
                type(value) == "table"
                and (not ignore_empty or (ignore_empty and not this.empty(value)))
            then
                result[key] = result[key] or {}
                assert(type(result[key]) == "table", string.format("Expected a table: '%s'", key))
                result[key] = this.merge_protected(protected, ignore_empty, result[key], value)
            else
                result[key] = value
            end
            ::continue::
        end
    end

    return result
end

---@generic K, V, R
---@overload fun(t: table<K,  V>, value_getter: fun(o: V): R): R[]
---@overload fun(t: table<K,  V>): V[]
---@param t table<K,  V>
---@param value_getter (fun(o: V): R?)?
function this.values(t, value_getter)
    local ret = {}
    for _, o_value in pairs(t) do
        local value = o_value
        if value_getter then
            value = value_getter(o_value)
        end

        if value ~= nil then
            table.insert(ret, value)
        end
    end
    return ret
end

---@generic K, V
---@param t table<K, V>
---@return K[]
function this.keys(t)
    local ret = {}
    for key, _ in pairs(t) do
        table.insert(ret, key)
    end
    return ret
end

---@generic T
---@param t T[]
---@param predicate T | fun(o: T): boolean
---@return integer?
function this.index(t, predicate)
    local is_fn = type(predicate) == "function"

    for i, v in ipairs(t) do
        if (is_fn and predicate(v)) or v == predicate then
            return i
        end
    end
end

---@generic T: table
---@param t T[]
---@param key (fun(o: T): any)?
---@param ... T[]
---@return T[]
function this.unique(t, key, ...)
    local tables = { t, ... }
    local ret = {}
    for _, tbl in pairs(tables) do
        for _, value in pairs(tbl) do
            if key then
                ret[key(value)] = value
            else
                ret[value] = 1
            end
        end
    end

    if key then
        return this.values(ret)
    end

    return this.keys(ret)
end

---@generic T: table
---@param t T
---@param keys any[]
---@param value any
---@return T
function this.insert_nested_value(t, keys, value)
    local current = t
    local size = #keys

    for i = 1, size do
        local key = keys[i]
        if current[key] == nil then
            current[key] = {}
        end
        current = current[key]
    end

    table.insert(current, value)
    return t
end

---@generic T: table
---@param t T
---@param keys any[]
---@param value any
---@return T
function this.set_nested_value(t, keys, value)
    local current = t
    local size = #keys

    for i = 1, size - 1 do
        local key = keys[i]
        if current[key] == nil then
            current[key] = {}
        end
        current = current[key]
    end
    current[keys[size]] = value
    return t
end

---@param t table
---@param keys any[]
---@return any
function this.get_nested_value(t, keys)
    local ret = t
    local size = #keys

    for i = 1, size - 1 do
        ret = ret[keys[i]]
        if ret == nil then
            return
        end
    end
    return ret[keys[size]]
end

---@generic T
---@param target T[]
---@param ... T[]
---@return T[]
function this.extend(target, ...)
    local arrays_to_merge = { ... }
    for i = 1, #arrays_to_merge do
        local t = arrays_to_merge[i]
        table.move(t, 1, #t, #target + 1, target)
    end
    return target
end

---@param ... any[]
---@return any[]
function this.concat(...)
    local arrays_to_merge = { ... }
    local ret = this.deep_copy(arrays_to_merge[1])
    for i = 2, #arrays_to_merge do
        local t = arrays_to_merge[i]
        table.move(t, 1, #t, #ret + 1, ret)
    end
    return ret
end

---@param t table
---@param keys any[]
---@param t_merge table
---@return table
function this.extend_nested(t, keys, t_merge)
    local current = t
    local size = #keys

    for i = 1, size do
        local key = keys[i]
        if current[key] == nil then
            current[key] = {}
        end
        current = current[key]
    end

    return this.extend(current, t_merge)
end

---@generic K, V
---@param t table<K, V>
---@param predicate fun(o: V) : boolean
---@return boolean
function this.all(t, predicate)
    for _, value in pairs(t) do
        if not predicate(value) then
            return false
        end
    end
    return true
end

---@generic K, V
---@param t table<K, V>
---@param predicate (fun(key: K, value: V) : boolean)?
---@return boolean
function this.any(t, predicate)
    for key, value in pairs(t) do
        if (predicate and predicate(key, value)) or (not predicate and value == true) then
            return true
        end
    end
    return false
end

---@generic T, K, V
---@overload fun(t: T[]): table<string, T>
---@overload fun(t: T[], key: fun(value: T): K): table<K, T>
---@overload fun(t: T[], key: fun(value: T): K, value: fun(value: T): V): table<K, V>
function this.index_by(t, key, value)
    local ret = {}
    for _, v in pairs(t) do
        ret[key and key(v) or tostring(v)] = value and value(v) or v
    end
    return ret
end

---@generic K, V
---@param t table<K, V>
---@param key_transform (fun(o: K): any)?
---@param value_transform (fun(o: V): any)?
---@return table<any, any>
function this.transform_items(t, key_transform, value_transform)
    local ret = {}
    for k, v in pairs(t) do
        ret[key_transform and key_transform(k) or k] = value_transform and value_transform(v) or v
    end
    return ret
end

---@param t table
---@return integer
function this.size(t)
    local ret = 0
    for _, _ in pairs(t) do
        ret = ret + 1
    end
    return ret
end

---@generic K, V
---@param t table<K, V>
---@param key K | fun(key: K, value: V): boolean
---@return V?
function this.pop(t, key)
    local is_fn = type(key) == "function"

    for k, v in pairs(t) do
        if (is_fn and key(k, v)) or k == key then
            t[k] = nil
            return v
        end
    end
end

---@param t table
function this.clear(t)
    for i, _ in pairs(t) do
        t[i] = nil
    end
end

---@param t table
---@return boolean
function this.empty(t)
    return next(t) == nil
end

---@generic T
---@overload fun(t: T[], index1: integer, index2: integer, strict: false|nil): T[]
---@overload fun(t: T[], index1: integer, index2: integer, strict: true): T[]?
function this.slice(t, index1, index2, strict)
    local ret = {}
    for i = index1, index2 do
        table.insert(ret, t[i])
    end

    if strict and this.empty(ret) then
        return
    end
    return ret
end

---@generic T
---@param t T[]
---@param sort_func (fun(a: T, b: T): boolean)?
---@return T[]
function this.sort(t, sort_func)
    table.sort(t, sort_func)
    return t
end

---@generic K, V
---@param t table<K, V>
---@param predicate fun(key: K, value: V): boolean
---@return V?
function this.find_value(t, predicate)
    for k, v in pairs(t) do
        if predicate(k, v) then
            return v
        end
    end
end

---@generic K, V
---@param t table<K, V>
---@param predicate fun(key: K, value: V): boolean
---@return K?
function this.find_key(t, predicate)
    for k, v in pairs(t) do
        if predicate(k, v) then
            return k
        end
    end
end

---@generic K, V
---@param t table<K, V>
---@param func fun(t: table<K, V>, key: K, value: V): boolean?
---@return boolean
function this.do_something(t, func)
    for k, v in pairs(t) do
        if func(t, k, v) == false then
            return false
        end
    end
    return true
end

---@param t table
---@param indent integer?
---@param visited table<table, boolean>?
function this.pprint(t, indent, visited)
    indent = indent or 2
    visited = visited or {}
    local spacing = string.rep("  ", indent)

    if visited[t] then
        print(spacing .. "[Circular Ref]")
        return
    end

    visited[t] = true
    for k, v in pairs(t) do
        local key = tostring(k)
        if type(v) == "table" then
            print(spacing .. key .. " = {")
            this.pprint(v, indent + 1, visited)
            print(spacing .. "}")
        elseif type(v) == "string" then
            print(spacing .. key .. ' = "' .. v .. '"')
        else
            print(spacing .. key .. " = " .. tostring(v))
        end
    end

    visited[t] = nil
end

---@generic T
---@param t T[]
---@param n integer
---@return T[][]
function this.chunks(t, n)
    local ret = {}
    local chunk = {}
    local size = #t

    for i = 1, size do
        table.insert(chunk, t[i])
        if #chunk == n or i == size then
            table.insert(ret, chunk)
            chunk = {}
        end
    end

    return ret
end

---@generic K, V, R
---@param t table<K, V>
---@param key_func fun(t: table<K, V>, key: K, value: V): R
---@return {[R]: {[K]: V}}
function this.groupby(t, key_func)
    local ret = {}
    for k, v in pairs(t) do
        local key = key_func(t, k, v)
        this.insert_nested_value(ret, { key, k }, v)
    end

    return ret
end

---@generic K, V
---@param t table<K, V>
---@param predicate fun(key: K, value: V): boolean
---@return table<K, V>
function this.filter(t, predicate)
    local ret = {}
    for k, v in pairs(t) do
        if predicate(k, v) then
            ret[k] = v
        end
    end

    return ret
end

---@generic T
---@param t T[]
---@param predicate fun(i: integer, value: T): boolean
---@return T[]
function this.filter_array(t, predicate)
    local ret = {}
    for k, v in pairs(t) do
        if predicate(k, v) then
            table.insert(ret, v)
        end
    end

    return ret
end

---@param path string
---@return string | integer
function this.parse_path_key(path)
    local pattern = "^int:(%d+)$"
    if string.match(path, pattern) then
        return tonumber(string.match(path, pattern)) --[[@as integer]]
    end
    return path
end

---@param path string
---@return string[]
function this.split_path(path)
    local ret = {}
    for i in string.gmatch(path, "([^%.]+)") do
        table.insert(ret, i)
    end
    return ret
end

---@param t table
---@param path string
---@return any
function this.get_by_path(t, path)
    if not path:find(".", 1, true) then
        return t[this.parse_path_key(path)]
    end

    return this.get_nested_value(t, parse_path(path))
end

---@param t table
---@param path string
---@param value any
function this.set_by_path(t, path, value)
    if not path:find(".", 1, true) then
        t[this.parse_path_key(path)] = value
        return
    end

    this.set_nested_value(t, parse_path(path), value)
end

---@generic T
---@param t T[]
---@param ... T
---@return T
function this.insert_front(t, ...)
    local values = { ... }
    for i = #values, 1, -1 do
        table.insert(t, 1, values[i])
    end
    return t
end

---@generic T
---@param t T[]?
---@return T?
function this.unwrap_first(t)
    if type(t) == "table" then
        return t[1]
    end
    return t
end

---@generic T
---@param t table<integer, T>
---@return table<T, integer>
function this.index_by_value(t)
    local ret = {}
    for k, v in pairs(t) do
        ret[v] = k
    end
    return ret
end

---@param t table
---@return string
function this.repr(t)
    if type(t) == "table" then
        local parts = {}
        for i, v in ipairs(t) do
            parts[i] = this.repr(v)
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    elseif type(t) == "string" then
        return '"' .. t .. '"'
    else
        return tostring(t)
    end
end

---@generic T
---@param iterator fun(): T
---@return T[]
function this.collect(iterator)
    local ret = {}
    for i in iterator do
        table.insert(ret, i)
    end
    return ret
end

---@generic K, V
---@param iterator fun(): K, V
---@return {[K]: V}
function this.collect_pairs(iterator)
    local ret = {}
    for k, v in iterator do
        ret[k] = v
    end
    return ret
end

---@generic K, V
---@param t {[K]: V}
---@return {key: K, value: V}[]
function this.entries(t)
    local ret = {}
    for k, v in pairs(t) do
        table.insert(ret, { key = k, value = v })
    end
    return ret
end

---@generic T
---@param t1 T
---@param t2 T
---@return boolean
function this.equal(t1, t2)
    if t1 == t2 then
        return true
    end

    if type(t1) == "number" and type(t2) == "number" then
        return math.abs(t1 - t2) <= 1e-6
    end

    if type(t1) ~= "table" or type(t2) ~= "table" then
        return false
    end

    for k, v1 in pairs(t1) do
        local v2 = t2[k]
        if not this.equal(v1, v2) then
            return false
        end
    end

    for k in pairs(t2) do
        if t1[k] == nil then
            return false
        end
    end

    return true
end

---@param t table<string, any>
---@param ... string
---@return table<string, any>
function this.select_keys(t, ...)
    local ret = {}
    local keys = { ... }

    for _, k in pairs(keys) do
        ret[k] = t[k]
    end

    return ret
end

---@generic T, R
---@param t T[]
---@param transform fun(value: T): R
---@return R[]
function this.transform(t, transform)
    local ret = {}
    for _, val in ipairs(t) do
        table.insert(ret, transform(val))
    end
    return ret
end

---@generic T
---@param t T[]
---@param value T
---@param size integer
---@return T[]
function this.fill(t, value, size)
    for _ = 1, size do
        table.insert(t, value)
    end

    return t
end

---@generic T
---@param t T[]
---@return T[]
function this.reverse(t)
    local i, j = 1, #t

    while i < j do
        t[i], t[j] = t[j], t[i]
        i = i + 1
        j = j - 1
    end

    return t
end

return this
