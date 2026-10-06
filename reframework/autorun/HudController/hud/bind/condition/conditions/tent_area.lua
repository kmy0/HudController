local ace_player = require("HudController.util.ace.player")
local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")

---@class TentAreaCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@return TentAreaCondition
function this:new()
    local o = condition_base.new(
        self,
        "_TENT_AREA",
        config.lang.make_placeholder("menu.bind.condition.condition_tent_area")
    )
    setmetatable(o, self)
    ---@cast o TentAreaCondition

    return o
end

---@return boolean
function this:update()
    local master_char = ace_player.get_master_char()
    if not master_char or master_char:get_IsInTent() then
        return true
    end

    local ctx = master_char:get_HunterContext()
    local tent_info = ctx:get_TentAreaInfo()
    return tent_info:get_IsInTentArea()
end

return this
