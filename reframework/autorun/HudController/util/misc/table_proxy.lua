---@generic K, V
---@class TableProxy<K, V> : {[K]: V}
---@field clear fun()
---@field new fun(new_table: table<K, V>?)

local this = {}

---@generic K, V
---@param initial table<K, V>?
---@return TableProxy<K, V>
function this.new(initial)
    local real = initial or {}

    local proxy = {}

    local mt = {
        __index = function(_, k)
            if k == "clear" then
                return function()
                    real = {}
                end
            elseif k == "new" then
                return function(_, newTable)
                    real = newTable or {}
                end
            end
            return real[k]
        end,
        __newindex = function(_, k, v)
            real[k] = v
        end,
        __len = function()
            return #real
        end,
        __pairs = function()
            return pairs(real)
        end,
    }

    setmetatable(proxy, mt)

    ---@cast proxy TableProxy
    return proxy
end

return this
