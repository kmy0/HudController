local ace_misc = require("HudController.util.ace.misc")
local ace_player = require("HudController.util.ace.player")
local combat_condition = require("HudController.hud.bind_weapon.conditions.combat")
local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local m = require("HudController.util.ref.methods")
local util_misc = require("HudController.util.misc.util")
local util_table = require("HudController.util.misc.table")
local logger = require("HudController.util.misc.logger").g

local this = {
    custom_conditions = {
        ---@type table<string, CustomCondition>
        map = {},
        ---@type string[]
        sorted = {},
        ---@type string?
        active = nil,
        ---@type integer?
        previous_hud_key = nil,
    },
}

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

---@param current_hud HudProfileConfig
---@return HudProfileConfig?
function this.update(current_hud)
    local weapon_config = get_weapon_config()
    if not weapon_config then
        return
    end

    for _, fname in ipairs(this.custom_conditions.sorted) do
        local condition = this.custom_conditions.map[fname]
        local state_config = weapon_config[fname] --[[@as WeaponBindConfigData]]

        if not state_config or state_config.hud_key == -1 then
            goto continue
        end

        if condition:update() then
            if fname ~= this.custom_conditions.active then
                this.custom_conditions.active = fname

                if not this.custom_conditions.previous_hud_key and condition.switch_back then
                    this.custom_conditions.previous_hud_key = current_hud.key
                end
            end

            return util_table.value(config.current.mod.hud, function(_, value)
                return value.key == state_config.hud_key
            end)
        end

        ::continue::
    end

    this.custom_conditions.active = nil
    if this.custom_conditions.previous_hud_key then
        local key = this.custom_conditions.previous_hud_key
        this.custom_conditions.previous_hud_key = nil

        return util_table.value(config.current.mod.hud, function(_, value)
            return value.key == key
        end)
    end

    combat_condition:update()

    local state_config =
        weapon_config[combat_condition:is_village() and "camp" or (combat_condition:is_combat() and "combat_in" or "combat_out")] --[[@as WeaponBindConfigData]]

    if state_config.hud_key == -1 then
        return
    end

    return util_table.value(config.current.mod.hud, function(_, value)
        return value.key == state_config.hud_key
    end)
end

function this.reset()
    condition_base.reset_all()
    this.custom_conditions.previous_hud_key = nil
    this.custom_conditions.active = nil
end

---@return boolean
function this.init()
    for k, v in
        pairs(package.loaded --[[@as table<string ,table>]])
    do
        k = string.match(k, "^(HudController.*)%.init$")
        if k then
            ---@diagnostic disable-next-line: no-unknown
            package.loaded[k] = v
        end
    end

    local files = fs.glob(util_misc.join_paths_b(config.name, "user_conditions", ".*lua"))

    for _, file in pairs(files) do
        local name = util_misc.get_file_name(file, false)

        if not string.find(name, "example") and not string.match(name, "^_") then
            util_misc.try(function()
                local module = require(
                    string.format("reframework.data.%s.user_conditions.%s", config.name, name)
                ) --[[@as CustomCondition | fun()]]

                if type(module) == "function" then
                    this.custom_conditions.map[name] = module()
                else
                    ---@cast module CustomCondition
                    this.custom_conditions.map[name] = module:new()
                end

                logger:info(string.format("[UserCondition] %s loaded.", name))
            end, function(err)
                logger:error(string.format("[UserCondition] %s failed: %s.", name, err))
            end)
        end
    end

    this.custom_conditions.sorted = util_table.keys(this.custom_conditions.map)
    table.sort(this.custom_conditions.sorted)

    return true
end

return this
