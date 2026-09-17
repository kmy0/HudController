---@class AmmoChanged : ChangedCondition
---@field ammo ValueChecker
---@field ammo_type ValueChecker

local ace_player = require("HudController.util.ace.player")
local changed_condition = require("HudController.hud.bind.condition.conditions.changed")
local config = require("HudController.config.init")
local util_ref = require("HudController.util.ref.init")
local value_checker = require("HudController.util.misc.value_checker")

---@class AmmoChanged
local this = {}
this.__index = this
setmetatable(this, { __index = changed_condition })

---@return AmmoChanged
function this:new()
    local o = changed_condition.new(
        self,
        "_AMMO_CHANGED",
        config.lang.make_placeholder("menu.bind.condition.condition_ammo_changed")
    )
    setmetatable(o, self)
    ---@cast o AmmoChanged

    o.ammo = value_checker:new(-1)
    o.ammo_type = value_checker:new(-1)
    return o
end

function this:update()
    local char = ace_player.get_master_char()
    if not char then
        return false
    end

    local handling = char:get_WeaponHandling()
    if not handling or not util_ref.is_a(handling, "app.cHunterWpGunHandling") then
        return false
    end

    ---@cast handling app.cHunterWpGunHandling
    local ammo = handling:getCurrentAmmo()
    if not ammo then
        return false
    end

    local ammo_changed = self.ammo:is_changed(ammo:get_LoadedAmmo())
    local ammo_type_changed = self.ammo_type:is_changed(handling:get_SelectedShellItem())

    return self:check(ammo_changed or ammo_type_changed)
end

function this:reset()
    changed_condition.reset(self)
    self.ammo:reset()
end

return this
