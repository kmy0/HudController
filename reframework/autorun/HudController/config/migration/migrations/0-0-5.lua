---@diagnostic disable: undefined-field, no-unknown, inject-field

local migration_base = require("HudController.util.misc.migration_base")
local util_table = require("HudController.util.misc.table")

local this = migration_base.new("0.0.5")

---@param config MainSettings
function this.fns.weapon_binds_camp(config)
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

return this
