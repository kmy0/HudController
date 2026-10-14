local bind_manager = require("HudController.hud.bind.key.init")
local config = require("HudController.config.init")
local multi_select = require("HudController.hud.bind.condition.conditions.multi_select")
local util_table = require("HudController.util.misc.table")

---@class KeyCondition : MultiSelectCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = multi_select })

---@return KeyCondition
function this:new()
    local o = multi_select.new(
        self,
        "_KEY",
        config.lang.make_placeholder("menu.bind.condition.condition_key"),
        {}
    )
    setmetatable(o, self)
    ---@cast o KeyCondition

    return o
end

---@return { key: any, value: string }[], string[]
function this:get_sorted()
    ---@type { key: integer, value: string }[]
    local sorted = {}
    for _, bind in ipairs(bind_manager.condition:get_base_binds()) do
        table.insert(sorted, { key = bind.name, value = bind.name_display })
    end

    local sorted_values = util_table.transform(sorted, function(value)
        return value.value
    end)

    return sorted, sorted_values
end

---@param selected table<string, boolean>
---@return boolean
function this:update(selected)
    for bind_name, _ in pairs(selected) do
        if
            util_table.get_nested_value(
                bind_manager.monitor.frame_storage,
                { "condition", bind_name }
            )
        then
            return true
        end
    end
    return false
end

return this
