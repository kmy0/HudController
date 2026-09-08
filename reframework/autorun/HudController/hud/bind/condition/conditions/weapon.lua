---@class WeaponCondition : ConditionBase
---@field protected _index_to_name table<integer, string>

local ace_player = require("HudController.util.ace.player")
local condition_base = require("HudController.hud.def.condition_base")
local data_ace = require("HudController.data.ace")
local e = require("HudController.util.game.enum")
local util_table = require("HudController.util.misc.table")

---@class WeaponCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@return WeaponCondition
function this:new()
    ---@type table<integer, string>
    local index_to_name = {}
    ---@type string[]
    local sorted_weapons = {}
    local weapons = util_table.map_to_array(data_ace.map.weaponid_name_to_local_name)

    table.sort(weapons, function(a, b)
        return a.value < b.value
    end)

    util_table.do_something(weapons, function(_, key, value)
        index_to_name[key] = value.key
        table.insert(sorted_weapons, value.value)
    end)

    local o =
        condition_base.new(self, "_WEAPON", "menu.bind.condition.condition_weapon", sorted_weapons)
    setmetatable(o, self)
    ---@cast o WeaponCondition

    o._index_to_name = index_to_name
    return o
end

---@param option_key integer
---@return boolean
function this:update(option_key)
    local name = self._index_to_name[option_key]
    local weapon = e.get("app.WeaponDef.TYPE")[name]
    return weapon == ace_player.get_weapon_type()
end

return this
