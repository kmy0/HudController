---@class SharpnessChanged : ChangedCondition
---@field sharpness ValueChecker

local ace_player = require("HudController.util.ace.player")
local changed_condition = require("HudController.hud.bind.condition.conditions.changed")
local config = require("HudController.config.init")
local value_checker = require("HudController.util.misc.value_checker")

---@class SharpnessChanged
local this = {}
this.__index = this
setmetatable(this, { __index = changed_condition })

---@return SharpnessChanged
function this:new()
    local o = changed_condition.new(
        self,
        "_SHARPNESS_CHANGED",
        config.lang.make_placeholder("menu.bind.condition.condition_sharpness_changed")
    )
    setmetatable(o, self)
    ---@cast o SharpnessChanged

    o.sharpness = value_checker:new()
    return o
end

function this:update()
    local char = ace_player.get_master_char()
    if not char then
        return false
    end

    local handling = char:get_WeaponHandling()
    if not handling then
        return false
    end

    local kireaji = handling:get_Kireaji()
    if not kireaji then
        return false
    end

    return self:check(self.sharpness:is_changed(kireaji:get_CurrentValue()))
end

function this:reset()
    changed_condition.reset(self)
    self.sharpness:reset()
end

return this
