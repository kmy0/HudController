local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local util_mod = require("HudController.util.mod.init")

---@class MapOpenCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@return MapOpenCondition
function this:new()
    local o = condition_base.new(
        self,
        "_MAP_OPEN",
        config.lang.make_placeholder("menu.bind.condition.condition_map_open")
    )
    setmetatable(o, self)
    ---@cast o MapOpenCondition

    return o
end

---@return boolean
function this:update()
    local component = util_mod.get_component("app.GUI060000")
    return component and component:get_Enabled()
end

return this
