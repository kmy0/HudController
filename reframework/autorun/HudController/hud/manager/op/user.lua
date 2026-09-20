local bind_condition = require("HudController.hud.bind.condition.init")
local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local user_option = require("HudController.hud.user.option")
local util_table = require("HudController.util.misc.table")

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

---@param elem_config HudBaseConfig
function this.merge_elem_user_options(elem_config)
    local hud_name = e.get("app.GUIHudDef.TYPE")[elem_config.hud_id]

    for k, opt in pairs(user_option.element[hud_name] or {}) do
        elem_config.user_options[k] = opt.default
    end

    for opt, _ in pairs(config.current.mod.game_options.elements[elem_config.name_key] or {}) do
        elem_config.options[opt] = -1
    end
end

---@param hud_config ModProfileConfig
function this.merge_hud_user_options(hud_config)
    for k, opt in pairs(user_option.hud) do
        hud_config.user_options[k] = opt.default
    end

    for opt, _ in pairs(config.current.mod.game_options.hud) do
        hud_config.options[opt] = -1
    end
end

function this.merge_mod_user_settings()
    local config_mod = config.current.mod
    for k, opt in pairs(user_option.mod) do
        if not config_mod.user_options[k] then
            config_mod.user_options[k] = opt.default
        end
    end
end

function this.verify_options()
    local config_mod = config.current.mod

    for k, _ in pairs(config_mod.user_options) do
        if not user_option.mod[k] then
            config_mod.user_options[k] = nil
        end
    end

    for _, hud in pairs(config_mod.hud) do
        for k, _ in pairs(hud.user_options or {}) do
            if not user_option.hud[k] then
                hud.user_options[k] = nil
            end
        end

        for _, elem in pairs(hud.elements) do
            local hud_name = e.get("app.GUIHudDef.TYPE")[elem.hud_id]
            for k, _ in pairs(elem.user_options or {}) do
                if not util_table.get_nested_value(user_option.element, { hud_name, k }) then
                    elem.user_options[k] = nil
                end
            end
        end
    end

    local res = {}
    for _, b in ipairs(config_mod.bind.key.option_user) do
        if this.all[b.bound_value.key] then
            table.insert(res, b)
        end
    end

    config_mod.bind.key.option_user = res
end

return this
