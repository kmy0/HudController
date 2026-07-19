---@diagnostic disable: undefined-field, no-unknown, inject-field

---@class Version
---@field major number
---@field minor number
---@field patch number
---@field commit number

local e = require("HudController.util.game.enum")
local util_misc = require("HudController.util.misc.util")
local util_table = require("HudController.util.misc.table")

local this = {}

---@class Version
local Version = {}
Version.__index = Version

---@param version_string string 0.0.0-0
---@return Version
function Version.new(version_string)
    local major, minor, patch = version_string:match("(%d+)%.(%d+)%.(%d+)")
    local commit = version_string:match("%-(%d+)") or "0"

    local o = {
        major = tonumber(major),
        minor = tonumber(minor),
        patch = tonumber(patch),
        commit = tonumber(commit) or 0,
    }
    return setmetatable(o, Version) --[[@as Version]]
end

---@param a Version
---@param b Version
---@return boolean
function Version.__lt(a, b)
    if a.major ~= b.major then
        return a.major < b.major
    end
    if a.minor ~= b.minor then
        return a.minor < b.minor
    end
    if a.patch ~= b.patch then
        return a.patch < b.patch
    end
    return a.commit < b.commit
end

---@param a Version
---@param b Version
---@return boolean
function Version.__eq(a, b)
    return a.major == b.major and a.minor == b.minor and a.patch == b.patch and a.commit == b.commit
end

function Version.__le(a, b)
    return a < b or a == b
end
function Version.__gt(a, b)
    return not (a <= b)
end
function Version.__ge(a, b)
    return not (a < b)
end

---@return string
function Version:__tostring()
    if self.commit > 0 then
        return string.format(
            "Version(%d.%d.%d-%d)",
            self.major,
            self.minor,
            self.patch,
            self.commit
        )
    end
    return string.format("Version(%d.%d.%d)", self.major, self.minor, self.patch)
end

---@param config MainSettings
local function to_0_0_5_weapon_binds_camp(config)
    for _, binds in pairs({
        config.mod.bind.weapon.multiplayer,
        config.mod.bind.weapon.singleplayer,
    }) do
        for _, b in pairs(binds) do
            if b.enabled then
                b.camp = util_table.deep_copy(b.combat_out)
            end
        end
    end
end

---@param config MainSettings
local function to_0_0_6_objectives(config)
    for _, profile in pairs(config.mod.hud) do
        for key, elem in pairs(profile.elements or {}) do
            if
                key ~= "PROGRESS"
                or not elem.children
                or not elem.children.timer
                or elem.children.quest_timer
            then
                goto continue
            end

            local quest_timer_config = elem.children.timer
            elem.children.timer = nil

            quest_timer_config.name_key = "quest_timer"
            elem.children.quest_timer = quest_timer_config
            ::continue::
        end
    end
end

---@param config table
local function to_0_1_0_lang(config)
    if config.gui.lang then
        config.mod.lang = util_table.deep_copy(config.gui.lang)
    end
end

---@param config table
local function to_0_1_0_keybinds(config)
    local pad_enum = e.get("ace.ACE_PAD_KEY.BITS")
    local kb_enum = e.get("ace.ACE_MKB_KEY.INDEX")

    if util_table.empty(pad_enum) or util_table.empty(kb_enum) then
        error("Bind Enum, not found. Please press Reset Scripts button.")
    end

    if config.mod.combo_hud then
        config.mod.combo.hud = config.mod.combo_hud
        config.mod.combo_hud = nil
    end

    if config.mod.bind.key.option then
        config.mod.bind.key.option_hud = config.mod.bind.key.option
        config.mod.bind.key.option = nil
    end

    for _, bind in
        pairs(config.mod.bind.key.hud --[==[@as ModBind[]]==])
    do
        bind.action_type = "NONE"
        bind.bound_value = bind.key
    end

    for _, bind in
        pairs(config.mod.bind.key.option_hud--[==[@as ModBind[]]==])
    do
        bind.action_type = "TOGGLE"
        bind.bound_value = bind.key
    end

    for _, name in pairs({ "hud", "option_hud" }) do
        for _, bind in
            pairs(config.mod.bind.key[name] --[==[@as Bind[]]==])
        do
            ---@type string[]
            local names = {}

            if bind.device == "PAD" then
                bind.keys = {}
                for _, key in
                    pairs(util_misc.extract_bits(bind.bit --[[@as integer]]))
                do
                    table.insert(bind.keys, key)
                    table.insert(names, pad_enum[key])
                end

                bind.name_display = table.concat(names, " + ")
                bind.bit = nil
                table.sort(bind.keys, function(a, b)
                    return pad_enum[a] < pad_enum[b]
                end)
            else
                for i = 1, #bind.keys do
                    table.insert(names, kb_enum[bind.keys[i]])
                end

                bind.name_display = bind.name
                table.sort(bind.keys, function(a, b)
                    return kb_enum[a] < kb_enum[b]
                end)
            end

            bind.name = table.concat(names, " + ")
        end
    end
end

---@param config MainSettings
local function to_0_3_0_config_keys(config)
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
local function to_0_3_0_conditions(config)
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

this.migrations = {
    ["0.0.5"] = function(config)
        to_0_0_5_weapon_binds_camp(config)
    end,
    ["0.0.6"] = function(config)
        to_0_0_6_objectives(config)
    end,
    ["0.1.0"] = function(config)
        to_0_1_0_lang(config)
        to_0_1_0_keybinds(config)
    end,
    ["0.3.0"] = function(config)
        to_0_3_0_config_keys(config)
        to_0_3_0_conditions(config)
    end,
}

---@param from string?
---@param to string
---@return string[]
local function get_funcs(from, to)
    from = from or "0.0.0"

    if from == to then
        return {}
    end

    ---@type string[]
    local sorted = {}
    local from_n = Version.new(from)
    local to_n = Version.new(to)
    for ver in pairs(this.migrations) do
        local ver_n = Version.new(ver)
        if ver_n > from_n and ver_n <= to_n then
            table.insert(sorted, ver)
        end
    end

    table.sort(sorted, function(a, b)
        return Version.new(a) < Version.new(b)
    end)

    return sorted
end

---@param from string?
---@param to string
---@return boolean
function this.need_migrate(from, to)
    from = from or "0.0.0"
    return Version.new(from) < Version.new(to)
end

---@param from string?
---@param to string
---@param config MainSettings
function this.migrate(from, to, config)
    local sorted = get_funcs(from, to)
    for i = 1, #sorted do
        local f = this.migrations[sorted[i]]
        f(config)
    end
    config.version = to
end

return this
