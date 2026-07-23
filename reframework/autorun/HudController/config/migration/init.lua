local migrations = require("HudController.config.migration.migrations.init") --[==[@as Migration[]]==]
local version = require("HudController.util.misc.version_base")

local this = {}

---@param from Version
---@param to Version
local function get_migrations(from, to)
    ---@type Migration[]
    local ret = {}
    for _, m in pairs(migrations) do
        if m.version > from and m.version <= to then
            table.insert(ret, m)
        end
    end

    table.sort(ret, function(a, b)
        return a.version < b.version
    end)

    return ret
end

---@param from string
---@param to string
---@return boolean
function this.need_migrate(from, to)
    return version.new(from) < version.new(to)
end

---@param from string
---@param to string
---@param config MainSettings
function this.migrate(from, to, config)
    local ms = get_migrations(version.new(from), version.new(to))
    for _, m in ipairs(ms) do
        m:migrate(config)
    end
    config.version = to
end

return this
