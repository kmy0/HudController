local util_table = require("HudController.util.misc.table")

local this = {}

---@param config Settings
local function to_0_0_5_weapon_binds_camp(config)
    for _, binds in pairs({ config.mod.bind.weapon.multiplayer, config.mod.bind.weapon.singleplayer }) do
        for _, b in pairs(binds) do
            if b.enabled then
                b.camp = util_table.deep_copy(b.combat_out)
            end
        end
    end
end

this.migrations = {
    ["0.0.5"] = function(config)
        to_0_0_5_weapon_binds_camp(config)
    end,
}

---@param from string?
---@param to string
---@return string[]
local function get_funcs(from, to, check_only)
    from = from or "0.0.0"

    if from == to then
        return {}
    end

    ---@type string[]
    local sorted = {}
    local from_n = this.version_to_number(from)
    local to_n = this.version_to_number(to)
    for ver in pairs(this.migrations) do
        local ver_n = this.version_to_number(ver)
        if ver_n > from_n and ver_n <= to_n then
            table.insert(sorted, ver)
        end
    end

    table.sort(sorted, function(a, b)
        return this.version_to_number(a) < this.version_to_number(b)
    end)

    return sorted
end

---@param version string
---@return number
function this.version_to_number(version)
    local major, minor, patch = version:match("(%d+)%.(%d+)%.(%d+)")
    return tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
end

---@param from string
---@param to string
---@return boolean
function this.need_migrate(from, to)
    return not util_table.empty(get_funcs(from, to))
end

---@param from string?
---@param to string
---@param config Settings
function this.migrate(from, to, config)
    local sorted = get_funcs(from, to)
    for i = 1, #sorted do
        local f = this.migrations[sorted[i]]
        f(config)
    end
    config.version = to
end

return this
