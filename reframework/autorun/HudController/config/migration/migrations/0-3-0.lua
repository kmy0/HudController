---@diagnostic disable: undefined-field, no-unknown, inject-field

local migration_base = require("HudController.util.misc.migration_base")
local util_misc = require("HudController.util.misc.util")
local util_table = require("HudController.util.misc.table")

local this = migration_base.new("0.3.0")

---@param config MainSettings
function this.fns.config_keys(config)
    config.mod.enable_condition_binds = config.mod.enable_weapon_binds
    config.mod.disable_condition_binds_held = config.mod.disable_weapon_binds_held
    config.mod.disable_condition_binds_timed = config.mod.disable_weapon_binds_timed
    config.mod.disable_condition_binds_time = config.mod.disable_weapon_binds_time

    config.mod.enable_weapon_binds = nil
    config.mod.disable_weapon_binds_held = nil
    config.mod.disable_weapon_binds_timed = nil
    config.mod.disable_weapon_binds_time = nil

    for _, bind in pairs(config.mod.bind.key.option_mod) do
        if bind.bound_value == "disable_weapon_binds_timed" then
            bind.bound_value = "disable_condition_binds_timed"
        elseif bind.bound_value == "disable_weapon_binds_held" then
            bind.bound_value = "disable_condition_binds_held"
        elseif bind.bound_value == "enable_weapon_binds" then
            bind.bound_value = "enable_condition_binds"
        end
    end
end

---@param config MainSettings
function this.fns.conditions(config)
    local data_ace = require("HudController.data.ace")
    local bind_condition = require("HudController.hud.bind_condition.init")

    local config_cond = config.mod.bind.condition
    local config_wep = config.mod.bind.weapon
    config_cond.condition_options._COMBAT = {
        quest_in_combat = config_wep.quest_in_combat,
        out_of_combat_delay = config_wep.out_of_combat_delay,
        in_combat_delay = config_wep.in_combat_delay,
        ride_ignore_combat = config_wep.ride_ignore_combat,
    }
    config_cond.hud = {}

    local WEAPON_TYPE_MELEE, WEAPON_TYPE_RANGED = 1, 2
    local COMBAT_IN, COMBAT_OUT = 1, 2
    local GAME_MODE_SINGLEPLAYER, GAME_MODE_MULTIPLAYER = 1, 2

    local function get_cond_set(hud_key)
        ---@diagnostic disable-next-line: missing-fields
        local ret = bind_condition.new_condition_set({ key = hud_key })
        ret.combo_hud = util_table.index(config.mod.hud, function(o)
            return o.key == hud_key
        end) --[[@as integer]]
        return ret
    end

    local function get_combat_cond(mode, key)
        ---@type ConditionSetConfig[]
        local ret = {}
        local combat_in = config_wep[mode][key].combat_in.hud_key --[[@as integer]]
        local combat_out = config_wep[mode][key].combat_out.hud_key --[[@as integer]]
        local village = config_wep[mode][key].camp.hud_key --[[@as integer]]

        if village == combat_in and combat_out == village then
            local cond_set = get_cond_set(village)
            table.insert(ret, cond_set)
        else
            local cond_set = get_cond_set(village)
            table.insert(cond_set.conditions, { class = "_VILLAGE", combo = 1 })
            table.insert(ret, cond_set)

            if combat_in ~= combat_out then
                if combat_in ~= -1 then
                    cond_set = get_cond_set(combat_in)
                    table.insert(cond_set.conditions, { class = "_COMBAT", combo = COMBAT_IN })
                    table.insert(ret, cond_set)
                end

                if combat_out ~= -1 then
                    cond_set = get_cond_set(combat_out)
                    table.insert(cond_set.conditions, { class = "_COMBAT", combo = COMBAT_OUT })
                    table.insert(ret, cond_set)
                end
            elseif combat_in ~= -1 and combat_out ~= -1 then
                cond_set = get_cond_set(combat_out)
                table.insert(ret, cond_set)
            end
        end

        return ret
    end

    ---@return ConditionSetConfig[]
    local function tag_and_merge(ret, mode, key, class, combo)
        if not config_wep[mode][key] or not config_wep[mode][key].enabled then
            return ret
        end

        local res = get_combat_cond(mode, key)

        if class then
            for _, cond_set in pairs(res) do
                table.insert(cond_set.conditions, { class = class, combo = combo })
            end
        end

        return util_table.array_merge(ret, res)
    end

    local function get_weapon_cond(mode)
        ---@type ConditionSetConfig[]
        local ret = {}

        if not config_wep[mode].GLOBAL then
            return ret
        end

        ret = tag_and_merge(ret, mode, "GLOBAL", nil, nil)

        if util_table.empty(ret) then
            ret = tag_and_merge(ret, mode, "MELEE", "_WEAPON_TYPE", WEAPON_TYPE_MELEE)
            ret = tag_and_merge(ret, mode, "RANGED", "_WEAPON_TYPE", WEAPON_TYPE_RANGED)

            local weapons = util_table.map_to_array(data_ace.map.weaponid_name_to_local_name)
            table.sort(weapons, function(a, b)
                return a.value < b.value
            end)

            for i, w in ipairs(weapons) do
                ret = tag_and_merge(ret, mode, w.key, "_WEAPON", i)
            end
        end

        return ret
    end

    local function merge_gamemode_conditions(singleplayer, multiplayer)
        local function contains(list, cond_set)
            return util_table.index(list, function(o)
                return util_table.equal(cond_set, o)
            end) ~= nil
        end

        ---@type ConditionSetConfig[]
        local shared = util_table.filter_array(singleplayer, function(_, cond_set)
            return contains(multiplayer, cond_set)
        end)
        ---@type ConditionSetConfig[]
        local unique_singleplayer = util_table.filter_array(singleplayer, function(_, cond_set)
            return not contains(multiplayer, cond_set)
        end)
        ---@type ConditionSetConfig[]
        local unique_multiplayer = util_table.filter_array(multiplayer, function(_, cond_set)
            return not contains(singleplayer, cond_set)
        end)

        if util_table.empty(unique_multiplayer) then
            return util_table.array_merge(shared, unique_singleplayer)
        end

        for _, cond in pairs(unique_singleplayer) do
            table.insert(cond.conditions, { class = "_GAME_MODE", combo = GAME_MODE_SINGLEPLAYER })
        end

        for _, cond in pairs(unique_multiplayer) do
            table.insert(cond.conditions, { class = "_GAME_MODE", combo = GAME_MODE_MULTIPLAYER })
        end

        return util_table.array_merge(shared, unique_singleplayer, unique_multiplayer)
    end

    if config_wep.singleplayer_only then
        config_cond.hud = get_weapon_cond("singleplayer")
    else
        local singleplayer = get_weapon_cond("singleplayer")
        local multiplayer = get_weapon_cond("multiplayer")
        config_cond.hud = merge_gamemode_conditions(singleplayer, multiplayer)
    end

    config.mod.bind.weapon = nil
end

---@param config MainSettings
function this.fns.font_size(config)
    local lang_file_name = util_misc.join_paths("HudController", "lang", config.mod.lang.file)
    local lang = json.load_file(lang_file_name)
    if not lang then
        return
    end

    local font_size = lang._font and lang._font.size
    if font_size then
        config.mod.lang.font_size = font_size
    end
end

return this
