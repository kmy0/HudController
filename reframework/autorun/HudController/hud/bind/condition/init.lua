---@class (exact) ConditionSetPass
---@field conditions table<integer, boolean>
---@field pass boolean
---@field element_profile ConditionSetPass[]
---@field hud_option ConditionSetPass[]
---@field mod_option ConditionSetPass[]
---@field game_option ConditionSetPass[]

---@class (exact) ConditionEvalResult
---@field hud {key: integer, profile: integer[]}
---@field hud_option table<string, integer>?
---@field mod_option table<string, integer>?
---@field game_option table<string, integer>?
---@field user_option table<string, any>?

---@class (exact) ConditionEvalRet : ConditionEvalResult
---@field hud {key: integer, profile: integer[]}?

local cd = require("HudController.data.combo")
local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local mod = require("HudController.data.mod")
local util_table = require("HudController.util.misc.table")

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
}

local condition_set_children = {
    "element_profile",
    "hud_option",
    "mod_option",
    "game_option",
    "user_option",
}

local this = {
    ---@type table<string, ConditionBase>
    conditions = {},
    ---@type ConditionSetPass[]
    passing_sets = {},
}

---@param o ConditionConfigBase
---@return boolean
local function eval_condition(o)
    local cond = this.conditions[o.class]
    if not cond then
        return true
    end

    local combo = cd.bind_condition_options[o.class]
    local option_key = combo and combo:get_key(o.combo)

    local res = cond:update(option_key)

    if o.expected_result == mod.enum.expected_result.FALSE then
        res = not res
    end

    return res
end

---@param conditions ConditionConfigBase[]
---@return boolean
local function eval(conditions)
    return util_table.all(conditions or {}, eval_condition)
end

---@param condition_sets ConditionSetConfig[]
---@param cache ConditionSetPass[]
---@param parent_key (integer|string)?
---@return integer[]
local function eval_all_and_store(condition_sets, cache, parent_key)
    ---@type integer[]
    local ret = {}

    for i, cond_set in ipairs(condition_sets or {}) do
        if parent_key and parent_key ~= cond_set.parent_key then
            goto continue_set
        end

        ---@type ConditionSetPass
        local pass = {
            conditions = {},
            pass = true,
            element_profile = {},
            hud_option = {},
            mod_option = {},
            game_option = {},
        }

        cache[i] = pass
        for j, condition in pairs(cond_set.conditions or {}) do
            local res = eval_condition(condition)
            pass.conditions[j] = res
            pass.pass = pass.pass and res
        end

        for _, child_name in ipairs(condition_set_children) do
            eval_all_and_store(
                cond_set[child_name] or {},
                pass[child_name] --[==[@as ConditionSetPass[]]==],
                cond_set.key
            )
        end

        if pass.pass then
            table.insert(ret, cond_set.key)
        end

        ::continue_set::
    end

    return ret
end

---@param hud_conditions ConditionSetConfig
---@return integer[]
local function eval_profiles(hud_conditions)
    ---@type integer[]
    local ret = {}
    for _, profile_conditions in ipairs(hud_conditions.element_profile or {}) do
        if
            profile_conditions.parent_key == hud_conditions.key
            and eval(profile_conditions.conditions or {})
        then
            table.insert(ret, profile_conditions.key)
        end
    end

    return ret
end

---@param option_conditions ConditionSetConfig[]
---@return table<string, any>
local function eval_options(option_conditions)
    ---@type table<string, any>
    local ret = {}
    for _, cond in ipairs(option_conditions) do
        if ret[cond.key] == nil and eval(cond.conditions or {}) then
            ---@diagnostic disable-next-line: no-unknown
            ret[cond.key] = cond.free_value
        end
    end

    return ret
end

---@return ConditionEvalResult?
local function eval_conditions()
    local bind_conditions = config.current.mod.bind.condition
    for _, hud_conditions in ipairs(bind_conditions.hud) do
        if eval(hud_conditions.conditions or {}) then
            return {
                hud = { key = hud_conditions.key, profiles = eval_profiles(hud_conditions) },
                hud_option = eval_options(hud_conditions.hud_option or {}),
                mod_option = eval_options(hud_conditions.mod_option or {}),
            }
        end
    end
end

---@param condition_sets ConditionSetConfig[]
---@param cache ConditionSetPass[]
---@param parent_key integer|string
---@return table<string, any>
local function collect_options(condition_sets, cache, parent_key)
    ---@type table<string, any>
    local ret = {}

    for i, cond_set in ipairs(condition_sets or {}) do
        if
            cond_set.parent_key == parent_key
            and ret[cond_set.key] == nil
            and cache[i]
            and cache[i].pass
        then
            ---@diagnostic disable-next-line: no-unknown
            ret[cond_set.key] = cond_set.free_value
        end
    end

    return ret
end

---@return ConditionEvalResult?
local function eval_all_conditions()
    local bind_conditions = config.current.mod.bind.condition
    local passing_huds = eval_all_and_store(bind_conditions.hud, this.passing_sets)
    local hud = passing_huds[1]

    if not hud then
        return
    end

    for i, hud_conditions in ipairs(bind_conditions.hud) do
        if hud_conditions.key == hud then
            local hud_pass = this.passing_sets[i]

            ---@type integer[]
            local profiles = {}
            for j, profile_conditions in ipairs(hud_conditions.element_profile or {}) do
                if
                    profile_conditions.parent_key == hud_conditions.key
                    and hud_pass.element_profile[j]
                    and hud_pass.element_profile[j].pass
                then
                    table.insert(profiles, profile_conditions.key)
                end
            end

            local ret = {
                hud = { key = hud, profile = profiles },
            }

            for _, child_name in ipairs(condition_set_children) do
                if child_name ~= "element_profile" then
                    ret[child_name] = collect_options(
                        hud_conditions[child_name] or {},
                        hud_pass[child_name],
                        hud_conditions.key
                    )
                end
            end

            ---@cast ret ConditionEvalResult
            return ret
        end
    end
end

---@param current_hud ModHud
---@param force boolean?
---@return ConditionEvalRet?
function this.update(current_hud, force)
    local bind_conditions = config.current.mod.bind.condition
    ---@type ConditionEvalResult?
    local res

    this.passing_sets = {}

    if bind_conditions.highlight_pass and config.gui.current.gui.main.is_opened then
        res = eval_all_conditions()
    else
        res = eval_conditions()
    end

    if not res then
        return
    end

    local same_as_current = current_hud
        and res.hud.key == current_hud.hud.key
        and util_table.equal(res.hud.profile, current_hud.profile_bits or {})

    if same_as_current and not force then
        res.hud = nil
    end

    ---@cast res ConditionEvalRet
    return res
end

function this.update_conditions_only()
    this.passing_sets = {}
    eval_all_conditions()
end

function this.reset()
    condition_base.reset_all()
end

---@param key integer|string
---@param parent_key (integer|string)?
---@return ConditionSetConfig
function this.new_condition_set(key, parent_key)
    return {
        key = key,
        conditions = {},
        combo_profile = 1,
        combo_condition = 1,
        collapsed = false,
        parent_key = parent_key,
        element_profile = {},
        hud_option = {},
        mod_option = {},
        game_option = {},
        user_option = {},
    }
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

function this.reinit()
    this.conditions = {}
    this.passing_sets = {}
    this.init()
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
