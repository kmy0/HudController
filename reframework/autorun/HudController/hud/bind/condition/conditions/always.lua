local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")

---@class AlwaysCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@return AlwaysCondition
function this:new()
    local o = condition_base.new(
        self,
        "_ALWAYS",
        config.lang.make_placeholder("menu.bind.condition.condition_always")
    )
    setmetatable(o, self)
    ---@cast o AlwaysCondition

    return o
end

---@return boolean
function this:update()
    return true
end

return this
