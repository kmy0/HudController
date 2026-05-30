local ace_misc = require("HudController.util.ace.misc")
local ace_player = require("HudController.util.ace.player")
local combat_condition = require("HudController.hud.bind_weapon.conditions.combat")
local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local m = require("HudController.util.ref.methods")

local this = {}

---@return WeaponBindConfig?
local function get_weapon_config()
    local bind_weapon = config.current.mod.bind.weapon

    local mode = bind_weapon.singleplayer_only and "singleplayer"
        or (ace_misc.is_multiplayer() and "multiplayer" or "singleplayer")
    ---@type table<string, WeaponBindConfig>
    local t = bind_weapon[mode]

    if t["GLOBAL"].enabled then
        return t["GLOBAL"]
    end

    local weapon_type = ace_player.get_weapon_type()
    local weapon_name = e.get("app.WeaponDef.TYPE")[weapon_type]
    if not weapon_name then
        return
    end

    local weapon_config = t[weapon_name]
    if weapon_config.enabled then
        return weapon_config
    end

    if m.isGunnerWeapon(weapon_type) then
        return t["RANGED"].enabled and t["RANGED"] or nil
    else
        return t["MELEE"].enabled and t["MELEE"] or nil
    end
end

---@return HudProfileConfig?
function this.update()
    local weapon_config = get_weapon_config()
    if not weapon_config then
        return
    end

    combat_condition:update()

    local config_mod = config.current.mod
    local state_config =
        weapon_config[combat_condition:is_village() and "camp" or (combat_condition:is_combat() and "combat_in" or "combat_out")] --[[@as WeaponBindConfigData]]
    local hud_config = config_mod.hud[state_config.combo]

    if state_config.hud_key == hud_config.key then
        return hud_config
    end
end

function this.reset()
    condition_base.reset_all()
end

return this
