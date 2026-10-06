local config = require("HudController.config.init")
local multi_select = require("HudController.hud.bind.condition.conditions.multi_select")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.init"
local hud = util_misc.lazy_require("HudController.hud.init")

---@class HudCondition : MultiSelectCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = multi_select })

---@return HudCondition
function this:new()
    local o = multi_select.new(
        self,
        "_HUD",
        config.lang.make_placeholder("menu.bind.condition.condition_hud"),
        {}
    )
    setmetatable(o, self)
    ---@cast o HudCondition

    return o
end

---@return { key: any, value: string }[], string[]
function this:get_sorted()
    ---@type { key: integer, value: string }[]
    local sorted = {}
    for _, hud_config in ipairs(config.current.mod.hud) do
        table.insert(sorted, { key = hud_config.key, value = hud_config.name })
    end

    local sorted_values = util_table.transform(sorted, function(value)
        return value.value
    end)

    return sorted, sorted_values
end

---@param selected table<string, boolean>
---@return boolean
function this:update(selected)
    local current = hud.get_current()
    return current and selected[tostring(current.key)] or false
end

return this
