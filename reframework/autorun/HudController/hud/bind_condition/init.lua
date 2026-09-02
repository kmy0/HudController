---@class (exact) ConditionSetPass
---@field conditions table<integer, boolean>
---@field pass boolean
---@field children ConditionSetPass[]

local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local gui_state = require("HudController.gui.state")
local util_table = require("HudController.util.misc.table")
local conditions = {
    combat = require("HudController.hud.bind_condition.conditions.combat"),
    game_mode = require("HudController.hud.bind_condition.conditions.game_mode"),
    village = require("HudController.hud.bind_condition.conditions.village"),
    weapon = require("HudController.hud.bind_condition.conditions.weapon"),
    weapon_type = require("HudController.hud.bind_condition.conditions.weapon_type"),
}

local this = {
    ---@type table<string, ConditionBase>
    conditions = {},
    ---@type integer?
    previous_hud_key = nil,
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
---@return integer?
local function eval_all_and_store(conditions, cache)
    ---@type integer?
    local ret

    for i, cond_set in ipairs(conditions) do
        util_table.set_nested_value(cache, { i, "pass" }, false)
        util_table.set_nested_value(cache, { i, "children" }, {})

        local ok = not ret
        for j, o in pairs(cond_set.conditions or {}) do
            local cond = this.conditions[o.class]
            if not cond then
                util_table.set_nested_value(cache, { i, "conditions", j }, true)
                goto continue
            end

            local combo = gui_state.bind_condition_options[o.class]
            local option_key = combo and combo:get_key(o.combo)
            local res = cond:update(option_key)
            ok = ok and res
            util_table.set_nested_value(cache, { i, "conditions", j }, res)

            ::continue::
        end

        util_table.set_nested_value(cache, { i, "pass" }, ok)
        if ok then
            ret = cond_set.key
        end
    end

    return ret
end

---@return {hud: integer, profiles: integer?}?
local function eval_conditions()
    local bind_conditions = config.current.mod.bind.condition
    for _, hud_conditions in ipairs(bind_conditions.hud) do
        if eval(hud_conditions.conditions or {}) then
            for _, profile_conditions in ipairs(hud_conditions.children) do
                if eval(profile_conditions.conditions or {}) then
                    return { hud = hud_conditions.key, profiles = profile_conditions.key }
                end
            end

            return { hud = hud_conditions.key }
        end
    end
end

---@return {hud: integer, profiles: integer?}?
local function eval_all_conditions()
    local bind_conditions = config.current.mod.bind.condition
    ---@type integer?
    local profiles

    local hud = eval_all_and_store(bind_conditions.hud, this.passing_sets)
    for i, cond_set in ipairs(bind_conditions.hud) do
        local res = eval_all_and_store(cond_set.children or {}, this.passing_sets[i].children)
        if not profiles then
            profiles = res
        end
    end

    if hud then
        return { hud = hud, profiles = profiles }
    end
end

---@param current_hud ModProfileConfig
---@return ModProfileConfig?
function this.update(current_hud)
    local bind_conditions = config.current.mod.bind.condition
    ---@type integer?
    local new_hud_key
    ---@type integer?
    local new_profiles
    ---@type {hud: integer, profiles: integer?}?
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

    if current_hud and new_hud_key == current_hud.key then
        return
    elseif not new_hud_key and this.previous_hud_key and bind_conditions.switchback then
        new_hud_key = this.previous_hud_key
        this.previous_hud_key = nil
    elseif new_hud_key then
        this.previous_hud_key = current_hud.key
    else
        return
    end

    return util_table.value(config.current.mod.hud, function(_, value)
        return value.key == new_hud_key
    end)
end

function this.update_conditions_only()
    this.passing_sets = {}
    eval_all_conditions()
end

function this.reset()
    condition_base.reset_all()
    this.previous_hud_key = nil
end

---@param key integer
---@return ConditionSetConfig
function this.new_condition_set(key)
    return {
        key = key,
        conditions = {},
        combo_profile = 1,
        combo_condition = 1,
        collapsed = false,
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
