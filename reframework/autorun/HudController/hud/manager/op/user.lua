local bind_condition = require("HudController.hud.bind.condition.init")
local config = require("HudController.config.init")

local this = {}

function this.verify_conditions()
    local config_mod = config.current.mod

    for key, _ in pairs(config_mod.bind.condition.condition_options) do
        if not bind_condition.conditions[key] then
            config_mod.bind.condition.condition_options = nil
        end
    end

    ---@param condition_set ConditionSetConfig[]
    local function filter(condition_set)
        for _, cond_set in ipairs(condition_set) do
            local res = {}
            for _, cond in ipairs(cond_set.conditions or {}) do
                if bind_condition.conditions[cond.class] then
                    table.insert(res, cond)
                end
            end

            cond_set.conditions = res
            filter(cond_set.element_profile or {})
            filter(cond_set.hud_option or {})
            filter(cond_set.mod_option or {})
            filter(cond_set.game_option or {})
        end
    end

    filter(config_mod.bind.condition.hud)
end

return this
