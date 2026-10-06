local util_table = require("HudController.util.misc.table")

---@class BindSlot
local this = {}

---@param name ManagerName
---@param key any
---@return any[]
function this.path(name, key)
    if name == "hud" then
        return { name }
    end

    return { name, key }
end

---@param requests ConditionEvalResult
---@param name ManagerName
---@param key any
---@return any
function this.get(requests, name, key)
    return util_table.get_nested_value(requests, this.path(name, key))
end

---@param requests ConditionEvalResult
---@param name ManagerName
---@param key any
---@param value any
function this.set(requests, name, key, value)
    util_table.set_nested_value(requests, this.path(name, key), value)
end

return this
