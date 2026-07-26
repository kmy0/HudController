---@class (exact) ConditionSetPass
---@field conditions table<integer, boolean>
---@field pass boolean

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

---@return integer?
local function eval_conditions()
    local bind_conditions = config.current.mod.bind.condition
    for _, hud_conditions in ipairs(bind_conditions.hud) do
        if
            util_table.all(hud_conditions.conditions or {}, function(o)
                local cond = this.conditions[o.class]

                if not cond then
                    return true
                end

                local combo = gui_state.bind_condition_options[o.class]
                local option_key = combo and combo:get_key(o.combo)
                return cond:update(option_key)
            end)
        then
            return hud_conditions.hud_key
        end
    end
end

---@return integer?
local function eval_all_conditions()
    local bind_conditions = config.current.mod.bind.condition
    ---@type integer?
    local ret

    for i, hud_conditions in ipairs(bind_conditions.hud) do
        util_table.set_nested_value(this.passing_sets, { i, "pass" }, false)

        local ok = not ret
        for j, o in pairs(hud_conditions.conditions or {}) do
            local cond = this.conditions[o.class]
            if not cond then
                util_table.set_nested_value(this.passing_sets, { i, "conditions", j }, true)
                goto continue
            end

            local combo = gui_state.bind_condition_options[o.class]
            local option_key = combo and combo:get_key(o.combo)
            local res = cond:update(option_key)
            ok = ok and res
            util_table.set_nested_value(this.passing_sets, { i, "conditions", j }, res)

            ::continue::
        end

        util_table.set_nested_value(this.passing_sets, { i, "pass" }, ok)
        if ok then
            ret = hud_conditions.hud_key
        end
    end

    return ret
end

---@param current_hud HudProfileConfig
---@return HudProfileConfig?
function this.update(current_hud)
    local bind_conditions = config.current.mod.bind.condition
    ---@type integer?
    local new_hud_key
    this.passing_sets = {}

    if bind_conditions.highlight_pass and config.gui.current.gui.main.is_opened then
        new_hud_key = eval_all_conditions()
    else
        new_hud_key = eval_conditions()
    end

    if new_hud_key == current_hud.key then
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

---@param hud HudProfileConfig
---@return ConditionSetConfig
function this.new_condition_set(hud)
    return {
        hud_key = hud.key,
        conditions = {},
        combo_hud = 1,
        combo_condition = 1,
        collapsed = false,
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
