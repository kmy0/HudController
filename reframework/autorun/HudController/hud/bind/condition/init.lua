---@class (exact) ConditionSetPass
---@field conditions table<integer, boolean>
---@field pass boolean
---@field children ConditionSetPass[]

local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local gui_state = require("HudController.gui.state")
local util_table = require("HudController.util.misc.table")
local conditions = {
    combat = require("HudController.hud.bind.condition.conditions.combat"),
    game_mode = require("HudController.hud.bind.condition.conditions.game_mode"),
    village = require("HudController.hud.bind.condition.conditions.village"),
    weapon = require("HudController.hud.bind.condition.conditions.weapon"),
    weapon_type = require("HudController.hud.bind.condition.conditions.weapon_type"),
}

local this = {
    ---@type table<string, ConditionBase>
    conditions = {},
    ---@type integer?
    previous_hud_key = nil,
    ---@type integer[]?
    previous_profile_keys = nil,
    ---@type ConditionSetPass[]
    passing_sets = {},
}

---@param conditions ConditionConfigBase[]
---@return boolean
local function eval(conditions)
    return util_table.all(conditions or {}, function(o)
        local cond = this.conditions[o.class]

        if not cond then
            return true
        end

        local combo = gui_state.bind_condition_options[o.class]
        local option_key = combo and combo:get_key(o.combo)
        return cond:update(option_key)
    end)
end

---@param conditions ConditionSetConfig[]
---@param cache ConditionSetPass[]
---@param parent_key integer?
---@return integer[]
local function eval_all_and_store(conditions, cache, parent_key)
    ---@type integer[]
    local ret = {}
    for i, cond_set in ipairs(conditions) do
        if parent_key and parent_key ~= cond_set.parent_key then
            goto continue_set
        end

        util_table.set_nested_value(cache, { i, "pass" }, false)
        util_table.set_nested_value(cache, { i, "children" }, {})

        local ok = true
        for j, o in pairs(cond_set.conditions or {}) do
            local cond = this.conditions[o.class]
            if not cond then
                util_table.set_nested_value(cache, { i, "conditions", j }, true)
                goto continue_condition
            end

            local combo = gui_state.bind_condition_options[o.class]
            local option_key = combo and combo:get_key(o.combo)
            local res = cond:update(option_key)

            ok = ok and res
            util_table.set_nested_value(cache, { i, "conditions", j }, res)

            ::continue_condition::
        end

        util_table.set_nested_value(cache, { i, "pass" }, ok)

        if ok then
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
    for _, profile_conditions in ipairs(hud_conditions.children or {}) do
        if
            profile_conditions.parent_key == hud_conditions.key
            and eval(profile_conditions.conditions or {})
        then
            table.insert(ret, profile_conditions.key)
        end
    end

    return ret
end

---@return {hud: integer, profiles: integer[]}?
local function eval_conditions()
    local bind_conditions = config.current.mod.bind.condition
    for _, hud_conditions in ipairs(bind_conditions.hud) do
        if eval(hud_conditions.conditions or {}) then
            return {
                hud = hud_conditions.key,
                profiles = eval_profiles(hud_conditions),
            }
        end
    end
end

---@return {hud: integer, profiles: integer[]}?
local function eval_all_conditions()
    local bind_conditions = config.current.mod.bind.condition
    local passing_huds = eval_all_and_store(bind_conditions.hud, this.passing_sets)
    local hud = passing_huds[1]
    ---@type integer[]
    local profiles = {}
    for i, hud_conditions in ipairs(bind_conditions.hud) do
        local passing_profiles = eval_all_and_store(
            hud_conditions.children or {},
            this.passing_sets[i].children,
            hud_conditions.key
        )

        if hud == hud_conditions.key then
            profiles = passing_profiles
        end
    end

    if hud then
        return {
            hud = hud,
            profiles = profiles,
        }
    end
end

---@param current_hud ModHud
---@param force boolean?
---@return {hud: ModProfileConfig?, profile: integer[]}?
function this.update(current_hud, force)
    local bind_conditions = config.current.mod.bind.condition

    ---@type integer?
    local new_hud_key
    ---@type integer[]?
    local new_profiles
    ---@type {hud: integer, profiles: integer[]}?
    local res
    this.passing_sets = {}

    if bind_conditions.highlight_pass and config.gui.current.gui.main.is_opened then
        res = eval_all_conditions()
    else
        res = eval_conditions()
    end

    if res then
        new_hud_key = res.hud
        new_profiles = res.profiles
    end

    local switchback = bind_conditions.switchback
    local same_as_current = current_hud
        and new_hud_key == current_hud.hud.key
        and util_table.equal(new_profiles or {}, current_hud.profile_bits or {})
    if same_as_current and not force then
        return
    end

    local restore_hud = switchback and not new_hud_key and this.previous_hud_key
    local restore_profile = switchback
        and new_hud_key
        and new_profiles
        and util_table.empty(new_profiles)
        and this.previous_profile_keys

    if restore_hud then
        new_hud_key = this.previous_hud_key
        new_profiles = this.previous_profile_keys

        this.previous_hud_key = nil
        this.previous_profile_keys = nil
    elseif restore_profile then
        new_profiles = this.previous_profile_keys
        this.previous_profile_keys = nil
    elseif new_hud_key and current_hud then
        this.previous_hud_key = current_hud.hud.key
        this.previous_profile_keys = current_hud.profile_bits
    else
        return
    end

    return {
        hud = util_table.value(config.current.mod.hud, function(_, value)
            return value.key == new_hud_key
        end),
        profile = new_profiles or {},
    }
end

function this.update_conditions_only()
    this.passing_sets = {}
    eval_all_conditions()
end

function this.reset()
    condition_base.reset_all()
    this.previous_hud_key = nil
    this.previous_profile_keys = nil
end

---@param key integer
---@param parent_key integer?
---@return ConditionSetConfig
function this.new_condition_set(key, parent_key)
    return {
        key = key,
        conditions = {},
        combo_profile = 1,
        combo_condition = 1,
        collapsed = false,
        parent_key = parent_key,
        children = {},
    }
end

---@param condition ConditionBase
function this.register_condition(condition)
    this.conditions[condition.condition_name] = condition
    config.current.mod.bind.condition.condition_options[condition.condition_name] =
        util_table.merge(
            condition:new_additional_options(),
            config.current.mod.bind.condition.condition_options[condition.condition_name] or {}
        )
end

function this.reinit()
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
