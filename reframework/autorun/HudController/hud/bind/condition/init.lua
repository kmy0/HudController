---@class (exact) ConditionEvalResult
---@field hud {key: integer, profile: integer[]}?
---@field option_hud table<string, integer>?
---@field option_mod table<string, integer>?
---@field option_game table<string, integer>?
---@field option_user table<string, any>?
---@field option_elem table<string, {
--- ctx_path: OptionCtxPath,
--- value: any,
--- }>?

local _ = require("HudController.hud.bind.condition.conditions.custom")
local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local mod = require("HudController.data.mod")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.manager.op.init"
local op = util_misc.lazy_require("HudController.hud.manager.op.init")

local conditions = {
    combat = require("HudController.hud.bind.condition.conditions.combat"),
    game_mode = require("HudController.hud.bind.condition.conditions.game_mode"),
    village = require("HudController.hud.bind.condition.conditions.village"),
    weapon = require("HudController.hud.bind.condition.conditions.weapon"),
    weapon_type = require("HudController.hud.bind.condition.conditions.weapon_type"),
    health_changed = require("HudController.hud.bind.condition.conditions.health_changed"),
    ammo_changed = require("HudController.hud.bind.condition.conditions.ammo_changed"),
    stamina_changed = require("HudController.hud.bind.condition.conditions.stamina_changed"),
    sharpness_changed = require("HudController.hud.bind.condition.conditions.sharpness_changed"),
    sharpness_color = require("HudController.hud.bind.condition.conditions.sharpness_color"),
    riding = require("HudController.hud.bind.condition.conditions.riding"),
    minimap_state = require("HudController.hud.bind.condition.conditions.minimap_state"),
    quest_rank = require("HudController.hud.bind.condition.conditions.quest_rank"),
    quest_target = require("HudController.hud.bind.condition.conditions.quest_target"),
    always = require("HudController.hud.bind.condition.conditions.always"),
    hud = require("HudController.hud.bind.condition.conditions.hud"),
    key = require("HudController.hud.bind.condition.conditions.key"),
    health_threshold = require("HudController.hud.bind.condition.conditions.health_threshold"),
    stamina_threshold = require("HudController.hud.bind.condition.conditions.stamina_threshold"),
    quest = require("HudController.hud.bind.condition.conditions.quest"),
    weapon_drawn = require("HudController.hud.bind.condition.conditions.weapon_drawn"),
}

local mod_enum = mod.enum
local key_map = {
    [mod_enum.bind_cond_type.HUD] = "hud",
    [mod_enum.bind_cond_type.OPTION_HUD] = "option_hud",
    [mod_enum.bind_cond_type.OPTION_ELEM] = "option_elem",
    [mod_enum.bind_cond_type.OPTION_GAME] = "option_game",
    [mod_enum.bind_cond_type.OPTION_MOD] = "option_mod",
    [mod_enum.bind_cond_type.OPTION_USER] = "option_user",
}

local this = {
    ---@type table<string, ConditionBase>
    conditions = {},
    ---@type table<string, boolean>
    successful_paths = {},
    ---@type table<string, boolean>
    overridden_paths = {},
    ---@type table<string, table<string, string>>  [type_key][opt_key] = rule path
    applied_by = {},
    ---@type {key: integer, paths: string[]}?
    applied_hud = nil,
}

---@param cond_config ConditionBindStateConfig | ConditionBindRuleConfig
---@param base_path string?
---@param triggered_rules ConditionBindRuleConfig[]?
---@return {rule: ConditionBindRuleConfig, path: string?, type: BindCondType}[]?
local function evaluate(cond_config, base_path, triggered_rules)
    triggered_rules = triggered_rules or {}

    for i, rule_set in ipairs(cond_config.sets) do
        ---@type string?
        local set_path
        if base_path then
            set_path = string.format("%s.sets.int:%s", base_path, i)
        end

        for j, rule in ipairs(rule_set.rules) do
            ---@type string?
            local rule_path
            if set_path then
                rule_path = string.format("%s.rules.int:%s", set_path, j)
            end

            local pass = true
            for _, cond_group in ipairs(rule.conditions) do
                pass = true

                if util_table.empty(cond_group) then
                    pass = false
                    goto next_cond_group
                end

                for _, cond in ipairs(cond_group) do
                    pass = this.eval_cond(cond)

                    if cond.invalid then
                        return
                    end

                    if not pass then
                        break
                    end
                end

                if pass then
                    break
                end

                ::next_cond_group::
            end

            if pass then
                table.insert(
                    triggered_rules,
                    { rule = rule, path = rule_path, type = rule_set.type }
                )

                if not evaluate(rule, rule_path, triggered_rules) then
                    return
                end
            end
        end
    end

    return triggered_rules
end

---@param triggered_rules {rule: ConditionBindRuleConfig, path: string?, type: BindCondType}[]
---@return ConditionEvalResult
local function get_evaluation_result(triggered_rules)
    ---@type table<BindCondType, table<any, boolean>>
    local triggered = {}
    ---@type ConditionEvalResult
    local ret = {}

    for i = #triggered_rules, 1, -1 do
        local t = triggered_rules[i]
        local key = key_map[t.type]
        local opt_key = t.rule.free_value
        local opt_value = t.rule.free_value2
        local key_taken = util_table.get_nested_value(triggered, { t.type, opt_key })
        local applied = true
        local path = t.path

        if t.type == mod_enum.bind_cond_type.HUD then
            if key_taken then
                table.insert(ret.hud.profile, opt_value)
            elseif triggered[t.type] then
                applied = false
            else
                ret.hud = { key = opt_key, profile = { opt_value } }
                this.applied_hud = { key = opt_key, paths = {} }
            end
        elseif key_taken then
            applied = false
        elseif t.type == mod_enum.bind_cond_type.OPTION_ELEM then
            util_table.set_nested_value(
                ret,
                { key, opt_key },
                { value = opt_value, ctx_path = t.rule.free_value3 }
            )
        else
            util_table.set_nested_value(ret, { key, opt_key }, opt_value)
        end

        if applied then
            util_table.set_nested_value(triggered, { t.type, opt_key }, true)
        end

        if path then
            if applied then
                this.successful_paths[path] = true

                if t.type == mod_enum.bind_cond_type.HUD then
                    table.insert(this.applied_hud.paths, t.path)
                else
                    this.applied_by[key] = this.applied_by[key] or {}
                    this.applied_by[key][opt_key] = t.path
                end
            else
                this.overridden_paths[path] = true
            end
        end
    end

    return ret
end

---@param cond_config ConditionConfigBase
---@return boolean
function this.eval_cond(cond_config)
    if cond_config.invalid then
        return false
    end

    local cls = this.conditions[cond_config.class]
    local res = false

    util_misc.try(function()
        res = cls:update(cls:get_update_arg(cond_config))
    end, function(err)
        op.bind.set_condition_error(cond_config, "class_config", err)
    end)

    if cond_config.negate then
        res = not res
    end

    if cond_config.invalid then
        res = false
    end

    return res
end

---@param path string?
function this.demote_path(path)
    if path and this.successful_paths[path] then
        this.successful_paths[path] = nil
        this.overridden_paths[path] = true
    end
end

---@param current_hud ModHud
---@param force boolean?
---@return ConditionEvalResult?
function this.update(current_hud, force)
    local ret = this.eval_rules()

    if not ret then
        return
    end

    local same_as_current = current_hud
        and ret.hud
        and ret.hud.key == current_hud.hud.key
        and util_table.equal(ret.hud.profile, current_hud.profile_bits or {})

    if same_as_current and not force then
        ret.hud = nil
    end

    return ret
end

---@return ConditionEvalResult?
function this.eval_rules()
    this.successful_paths = {}
    this.overridden_paths = {}
    this.applied_by = {}
    this.applied_hud = nil

    local config_gui = config.gui.current.gui.main
    local config_cond = config.current.mod.bind.condition
    local base_path = config_cond.highlight_pass_rule
            and config_gui.is_opened
            and "mod.bind.condition"
        or nil

    local rules = evaluate(config_cond, base_path)
    if rules then
        return get_evaluation_result(rules)
    end
end

function this.reset()
    condition_base.reset_all()
end

---@return ConditionBindRuleConfig
function this.new_condition_rule()
    return {
        conditions = { {} },
        sets = {},
        cond_type_selection = mod_enum.bind_cond_type.HUD,
    }
end

---@param rule_type BindCondType
---@return ConditionBindRuleSet
function this.new_condition_rule_set(rule_type)
    return {
        type = rule_type,
        rules = { this.new_condition_rule() },
        ok = true,
        selection = 1,
    }
end

function this.new_conditions()
    return {}
end

---@return boolean
function this.check_invalid()
    return config.current.mod.bind.condition.invalid
end

---@param condition ConditionBase
function this.register_condition(condition)
    assert(
        this.conditions[condition.condition_name] == nil,
        string.format("Condition %s already exists!", condition.condition_name)
    )
    this.conditions[condition.condition_name] = condition
    config.current.mod.bind.condition.condition_options[condition.condition_name] =
        util_table.merge(
            condition:new_additional_options(),
            config.current.mod.bind.condition.condition_options[condition.condition_name] or {}
        )
end

---@return boolean
function this.init()
    for _, cond in pairs(conditions) do
        local cls = cond:new()
        this.register_condition(cls)
    end

    return true
end

return this
