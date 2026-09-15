local ace_porter = require("HudController.util.ace.porter")
local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")

---@class RidingCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@return RidingCondition
function this:new()
    local o = condition_base.new(
        self,
        "_RIDING",
        "menu.bind.condition.condition_riding",
        { config.lang:tr("misc.text_yes"), config.lang:tr("misc.text_no") }
    )
    setmetatable(o, self)
    ---@cast o RidingCondition

    return o
end

---@return boolean
function this:update()
    return ace_porter.is_master_riding()
end

return this
