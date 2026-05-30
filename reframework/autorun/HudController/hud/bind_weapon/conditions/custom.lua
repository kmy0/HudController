---@class CustomCondition : ConditionBase
---@field switch_back boolean

local condition_base = require("HudController.hud.def.condition_base")

---@class CustomCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@param name string?
---@param switch_back boolean? by default, false - if true profile is changed back after condition is no longer triggered
---@return CustomCondition
function this:new(name, switch_back)
    local o = condition_base.new(self, name or "CUSTOM_CONDITION")
    setmetatable(o, self)
    ---@cast o CustomCondition
    o.switch_back = switch_back or false
    return o
end

---@param name string
---@param update_fn fun(self: CustomCondition): boolean if the function returns true, condition is triggered
---@param switch_back boolean? by default, false - if true profile is changed back after condition is no longer triggered
---@return CustomCondition
function this.new_condition(name, update_fn, switch_back)
    local o = this:new(name, switch_back)
    o.update = update_fn

    return o
end

return this
