local bind_condition = require("HudController.hud.bind.condition.init")
local bind_manager = require("HudController.hud.bind.key.init")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local def = require("HudController.data.option.init")
local user = require("HudController.hud.user.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local mod_enum = data.mod.enum
local ace_map = data.ace.map

local this = {}

---@param lang_key string
---@param value any
---@return string
local function fmt_error(lang_key, value)
    return string.format("%s: %s", config.lang:tr(lang_key), value)
end

---@type table<BindCondType, fun(key: any): any>
local option_lookup = {
    [mod_enum.bind_cond_type.OPTION_USER] = function(key)
        return user.option.bindable[key]
    end,
    [mod_enum.bind_cond_type.OPTION_MOD] = function(key)
        local opt = def.mod.opt[key]
        return opt and opt.bindable
    end,
    [mod_enum.bind_cond_type.OPTION_HUD] = function(key)
        local opt = def.hud.opt[key]
        return opt and opt.bindable
    end,
    [mod_enum.bind_cond_type.OPTION_ELEM] = function(key)
        local opt = def.elem.get_opt(key)
        return opt and opt.bindable
    end,
    [mod_enum.bind_cond_type.OPTION_GAME] = function(key)
        return ace_map.option[key]
    end,
}

---@param cond_type BindCondType
---@param rule ConditionBindRuleConfig
local function check_option_rule(cond_type, rule)
    local lookup = option_lookup[cond_type]
    if not lookup then
        return
    end

    this.set_condition_error(
        rule,
        "free_value",
        not lookup(rule.free_value) and fmt_error("misc.text_missing_opt", rule.free_value)
    )
end

local function verify_keybinds()
    local config_mod = config.current.mod
    local bind_types = {
        { field = "option_game", cond = mod_enum.bind_cond_type.OPTION_GAME },
        { field = "option_user", cond = mod_enum.bind_cond_type.OPTION_USER },
        { field = "option_mod", cond = mod_enum.bind_cond_type.OPTION_MOD },
        { field = "option_hud", cond = mod_enum.bind_cond_type.OPTION_HUD },
        { field = "option_elem", cond = mod_enum.bind_cond_type.OPTION_ELEM },
    }

    for _, t in ipairs(bind_types) do
        local manager = bind_manager[t.field] --[[@as BindManager]]
        local lookup = option_lookup[t.cond]

        for _, b in pairs(manager.binds) do
            if not lookup(b.bound_value.key) then
                b.invalid = true
            end
        end

        config_mod.bind.key[t.field] = manager:get_base_binds()
    end
end

---@param sets ConditionBindRuleSet[]
local function merge_condition_sets(sets)
    if not sets then
        return
    end

    for key, set in pairs(sets) do
        set = util_table.merge(bind_condition.new_condition_rule_set(set.type), set)

        for j, rule in pairs(set.rules) do
            check_option_rule(set.type, rule)

            rule = util_table.merge(bind_condition.new_condition_rule(), rule)
            merge_condition_sets(rule.sets)

            set.rules[j] = rule
            for _, group in pairs(rule.conditions) do
                for k, cond in pairs(group) do
                    local cls = bind_condition.conditions[cond.class]
                    this.set_condition_error(
                        cond,
                        "class",
                        not cls and fmt_error("misc.text_missing_cond", cond.class)
                    )

                    if cls then
                        local ok = true
                        util_misc.try(function()
                            group[k] = util_table.merge_same_types(cls:new_config(), cond)
                        end, function(_)
                            group[k] = cls:new_config()
                            ok = false
                        end)

                        local merged = group[k]
                        if ok then
                            this.set_condition_error(
                                merged,
                                "class_config_value",
                                not cls:validate(cond) and config.lang:tr("misc.text_wrong_value")
                                    or nil
                            )
                        else
                            this.set_condition_error(
                                merged,
                                "class_config_value",
                                config.lang:tr("misc.text_config_changed")
                            )
                        end
                    end
                end
            end
        end

        sets[key] = set
    end
end

---@param root ConditionBindStateConfig
---@return fun(): ConditionBindRuleSet?, ConditionBindRuleConfig?
local function iter_all_rules(root)
    return coroutine.wrap(function()
        ---@param sets ConditionBindRuleSet[]
        local function visit(sets)
            for _, set in pairs(sets) do
                for _, rule in ipairs(set.rules) do
                    coroutine.yield(set, rule)
                    visit(rule.sets or {})
                end
            end
        end

        visit(root.sets)
    end)
end

---@param root ConditionBindStateConfig
---@return fun(): ConditionConfigBase?
local function iter_all_conditions(root)
    return coroutine.wrap(function()
        for _, rule in iter_all_rules(root) do
            for _, group in ipairs(rule.conditions) do
                for _, cond in ipairs(group) do
                    coroutine.yield(cond)
                end
            end
        end
    end)
end

---@param root ConditionBindStateConfig
local function condition_clear_class_config(root)
    for _, rule in iter_all_rules(root) do
        if rule.invalid then
            rule.invalid.class_config = nil
        end
    end

    for cond in iter_all_conditions(root) do
        if cond.invalid then
            cond.invalid.class_config = nil
        end
    end
end

local function check_user_option_bind()
    local config_mod = config.current.mod
    for rule in this.iter_rules(config_mod.bind.condition, mod_enum.bind_cond_type.OPTION_USER) do
        check_option_rule(mod_enum.bind_cond_type.OPTION_USER, rule)

        local reg_opt = user.option.bindable[rule.free_value]
        if reg_opt then
            local default_value = user.option.get_default(reg_opt)
            if not util_misc.eval_type(default_value, rule.free_value2) then
                this.set_condition_error(
                    rule,
                    "free_value2",
                    fmt_error("misc.text_wrong_value", rule.free_value2)
                )
                rule.free_value2 = default_value
            end
        end
    end

    for _, b in pairs(bind_manager.option_user.binds) do
        local reg_opt = user.option.bindable[b.bound_value.key]
        if
            not reg_opt
            or not util_misc.eval_type(user.option.get_default(reg_opt), b.bound_value.value)
        then
            b.invalid = true
        end
    end

    config_mod.bind.key.option_user = bind_manager.option_user:get_base_binds()
end

---@param root ConditionBindStateConfig
---@param cond_type BindCondType
---@return fun(): ConditionBindRuleConfig?
function this.iter_rules(root, cond_type)
    return coroutine.wrap(function()
        for set, rule in iter_all_rules(root) do
            if set.type == cond_type then
                coroutine.yield(rule)
            end
        end
    end)
end

---@param root ConditionBindStateConfig
---@param cond_class string
---@return fun(): ConditionConfigBase?
function this.iter_conditions(root, cond_class)
    return coroutine.wrap(function()
        for cond in iter_all_conditions(root) do
            if cond.class == cond_class then
                coroutine.yield(cond)
            end
        end
    end)
end

---@param hud_key integer
function this.mark_hud_invalid(hud_key)
    local config_mod = config.current.mod
    for rule in this.iter_rules(config_mod.bind.condition, mod_enum.bind_cond_type.HUD) do
        if rule.free_value == hud_key then
            this.set_condition_error(
                rule,
                "free_value",
                fmt_error("misc.text_missing_opt", rule.free_value)
            )
        end
    end

    for cond in this.iter_conditions(config_mod.bind.condition, "_HUD") do
        if cond.combo_key == hud_key then
            this.set_condition_error(
                cond,
                "class_config_value",
                fmt_error("misc.text_wrong_value", cond.combo_key)
            )
        end
    end

    this.evaluate_conditions(config_mod.bind.condition)

    for _, b in pairs(bind_manager.hud.binds) do
        if b.bound_value.key == hud_key then
            b.invalid = true
        end
    end

    config_mod.bind.key.hud = bind_manager.hud:get_base_binds()
    bind_manager.check_invalid()
end

---@param bind BindBase
---@param is_removal boolean?
function this.check_condition_key_bind(bind, is_removal)
    is_removal = is_removal and is_removal or false

    local config_mod = config.current.mod
    for cond in this.iter_conditions(config_mod.bind.condition, "_KEY") do
        if cond.combo_key == bind.name then
            this.set_condition_error(
                cond,
                "class_config_value",
                is_removal and fmt_error("misc.text_wrong_value", cond.combo_key)
            )
        end
    end

    this.evaluate_conditions(config_mod.bind.condition)
end

---@param hud_key integer
---@param profile_key integer
function this.mark_hud_profile_invalid(hud_key, profile_key)
    local config_mod = config.current.mod
    for rule in this.iter_rules(config_mod.bind.condition, mod_enum.bind_cond_type.HUD) do
        if rule.free_value == hud_key then
            local bit = rule.free_value2
            local unpacked = util_misc.unpack_bits(bit)

            if util_table.contains_any(unpacked, profile_key) then
                this.set_condition_error(
                    rule,
                    "free_value2",
                    fmt_error("misc.text_wrong_value", rule.free_value2)
                )
            end
        end
    end

    this.evaluate_conditions(config_mod.bind.condition)

    for _, b in pairs(bind_manager.hud.binds) do
        if b.bound_value.key == hud_key then
            local bit = b.bound_value.value
            local unpacked = util_misc.unpack_bits(bit)

            if util_table.contains_any(unpacked, profile_key) then
                b.invalid = true
            end
        end
    end

    config_mod.bind.key.hud = bind_manager.hud:get_base_binds()
    bind_manager.check_invalid()
end

---@param option_key string
---@param is_removal boolean?
function this.check_game_option_bind(option_key, is_removal)
    is_removal = is_removal and is_removal or false

    local config_mod = config.current.mod
    for rule in this.iter_rules(config_mod.bind.condition, mod_enum.bind_cond_type.OPTION_GAME) do
        if rule.free_value == option_key then
            this.set_condition_error(
                rule,
                "free_value",
                is_removal and fmt_error("misc.text_missing_opt", rule.free_value)
            )
        end
    end

    this.evaluate_conditions(config_mod.bind.condition)

    for _, b in pairs(bind_manager.option_game.binds) do
        if b.bound_value.key == option_key then
            b.invalid = is_removal
        end
    end

    config_mod.bind.key.option_game = bind_manager.option_game:get_base_binds()
    bind_manager.check_invalid()
end

---@param cond ConditionConfigBase | ConditionBindRuleConfig
---@param field string
---@param err any?
function this.set_condition_error(cond, field, err)
    if err then
        cond.invalid = cond.invalid or {}
        ---@diagnostic disable-next-line: no-unknown
        cond.invalid[field] = tostring(err)
    elseif cond.invalid then
        ---@diagnostic disable-next-line: no-unknown
        cond.invalid[field] = nil

        if next(cond.invalid) == nil then
            cond.invalid = nil
        end
    end
end

---@param root ConditionBindStateConfig
---@return boolean valid
function this.evaluate_conditions(root)
    local valid = true

    for _, rule in iter_all_rules(root) do
        if rule.invalid and next(rule.invalid) then
            valid = false
            break
        end
    end

    if valid then
        for cond in iter_all_conditions(root) do
            if cond.invalid and next(cond.invalid) then
                valid = false
                break
            end
        end
    end

    root.invalid = not valid
    return valid
end

function this.verify_binds()
    local config_mod = config.current.mod

    merge_condition_sets(config_mod.bind.condition.sets)
    condition_clear_class_config(config_mod.bind.condition)
    check_user_option_bind()
    verify_keybinds()

    this.evaluate_conditions(config_mod.bind.condition)
    bind_manager.check_invalid()
end

return this
