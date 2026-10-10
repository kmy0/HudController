local ace_misc = require("HudController.util.ace.misc")
local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")

---@class ItembarOpenCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@return ItembarOpenCondition
function this:new()
    local o = condition_base.new(
        self,
        "_ITEMBAR_OPEN",
        config.lang.make_placeholder("menu.bind.condition.condition_itembar_open")
    )
    setmetatable(o, self)
    ---@cast o ItembarOpenCondition

    return o
end

---@return boolean
function this:update()
    return ace_misc.is_item_slider_open()
end

return this
