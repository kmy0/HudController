---@class CustomCondition : ConditionBase

local condition_base = require("HudController.hud.def.condition_base")
local frame_cache = require("HudController.util.misc.frame_cache")

---@class CustomCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@param name string?
---@param options string[]? combobox selectables
---@return CustomCondition
function this:new(name, options)
    if type(options) ~= "table" then
        options = nil
    end

    local o =
        condition_base.new(self, name or "CUSTOM_CONDITION", name or "CUSTOM_CONDITION", options)
    setmetatable(o, self)
    ---@cast o CustomCondition

    return o
end

---@param name string
---@param update_fn fun(self: CustomCondition, option_key: any?): boolean if the function returns true, condition is triggered
---@param options string[]? combobox selectables
---@return CustomCondition
function this.new_condition(name, update_fn, options)
    local o = this:new(name, options)
    o.update = frame_cache.memoize(update_fn, { key_index = 2, key_as_string = true })
    return o
end

return this
