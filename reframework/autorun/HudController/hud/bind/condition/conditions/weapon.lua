---@class WeaponCondition : MultiSelectCondition

local ace_player = require("HudController.util.ace.player")
local config = require("HudController.config.init")
local data_ace = require("HudController.data.ace")
local e = require("HudController.util.game.enum")
local multi_select = require("HudController.hud.bind.condition.conditions.multi_select")

---@class WeaponCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = multi_select })

---@return WeaponCondition
function this:new()
    local o = multi_select.new(
        self,
        "_WEAPON",
        config.lang.make_placeholder("menu.bind.condition.condition_weapon"),
        data_ace.map.weaponid_name_to_local_name,
        function(a, b)
            return a.value < b.value
        end
    )
    setmetatable(o, self)
    ---@cast o WeaponCondition
    return o
end

---@param selected table<string, boolean>
---@return boolean
function this:update(selected)
    local weapon = e.get("app.WeaponDef.TYPE")[ace_player.get_weapon_type()]
    return selected[weapon]
end

return this
