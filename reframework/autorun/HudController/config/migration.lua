---@class Version
---@field major number
---@field minor number
---@field patch number
---@field commit number

local game_data = require("HudController.util.game.data")
local util_misc = require("HudController.util.misc.util")
local util_table = require("HudController.util.misc.table")

local rl = game_data.reverse_lookup

local this = {}

---@class Version
local Version = {}
---@diagnostic disable-next-line: inject-field
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
        return string.format("Version(%d.%d.%d-%d)", self.major, self.minor, self.patch, self.commit)
    end
    return string.format("Version(%d.%d.%d)", self.major, self.minor, self.patch)
end

---@param config MainSettings
local function to_0_0_5_weapon_binds_camp(config)
    for _, binds in pairs({ config.mod.bind.weapon.multiplayer, config.mod.bind.weapon.singleplayer }) do
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
            if key ~= "PROGRESS" or not elem.children or not elem.children.timer or elem.children.quest_timer then
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
        ---@diagnostic disable-next-line: no-unknown
        config.mod.lang = util_table.deep_copy(config.gui.lang)
    end
end

---@param config table
local function to_0_1_0_keybinds(config)
    ---@type table<ace.ACE_PAD_KEY.BITS, string>
    local pad_enum = {}
    local kb_enum = {}
    game_data.get_enum("ace.ACE_PAD_KEY.BITS", pad_enum)
    game_data.get_enum("ace.ACE_MKB_KEY.INDEX", kb_enum)

    if util_table.empty(pad_enum) or util_table.empty(kb_enum) then
        error("Bind Enum, not found. Please press Reset Scripts button.")
    end

    if config.mod.combo_hud then
        ---@diagnostic disable-next-line: no-unknown
        config.mod.combo.hud = config.mod.combo_hud
        ---@diagnostic disable-next-line: no-unknown
        config.mod.combo_hud = nil
    end

    if config.mod.bind.key.option then
        ---@diagnostic disable-next-line: no-unknown
        config.mod.bind.key.option_hud = config.mod.bind.key.option
        ---@diagnostic disable-next-line: no-unknown
        config.mod.bind.key.option = nil
    end

    for _, bind in
        pairs(config.mod.bind.key.hud --[==[@as ModBind[]]==])
    do
        bind.action_type = "NONE"
        ---@diagnostic disable-next-line: undefined-field
        bind.bound_value = bind.key
    end

    for _, bind in
        pairs(config.mod.bind.key.option_hud--[==[@as ModBind[]]==])
    do
        bind.action_type = "TOGGLE"
        ---@diagnostic disable-next-line: undefined-field
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
                ---@diagnostic disable-next-line: no-unknown, inject-field
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
