---@class GuiCondManagerBase

local bind_condition = require("HudController.hud.bind.condition.init")
local cd = require("HudController.data.combo")
local combo_multi = require("HudController.util.imgui.combo.combo_multi")
local config = require("HudController.config.init")
local util_table = require("HudController.util.misc.table")

---@class GuiCondManagerBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@return GuiCondManagerBase
function this:new()
    return setmetatable({}, self)
end

---@param rule_path string
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:draw_target(rule_path)
    return false
end

---@param rule_path string
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:draw_option(rule_path)
    return false
end

---@param conds_path string
---@return (string | ConditionConfigBase)?
function this:draw_condition_target(conds_path)
    local conditions = config:get(conds_path) --[==[@as ConditionConfigBase[]]==]
    local selection = util_table.fill({}, false, cd.combo.condition:size())
    local keys = cd.combo.condition:get_keys()

    for i, cls_name in ipairs(keys) do
        if
            util_table.index(conditions, function(o)
                return o.class == cls_name
            end)
        then
            selection[i] = true
        end
    end

    local changed, new_selection = combo_multi.combo_multi_filter(
        "##" .. conds_path,
        util_table.deep_copy(selection),
        config.lang:tr("menu.bind.condition.combo_add_cond"),
        cd.combo.condition.values,
        true
    )

    if changed then
        for i, b in ipairs(selection) do
            if b ~= new_selection[i] then
                if new_selection[i] then
                    local cond_key = cd.combo.condition:get_key(i)
                    local cond = bind_condition.conditions[cond_key]
                    return cond:new_config()
                else
                    return cd.combo.condition:get_key(i)
                end
            end
        end
    end
end

function this:empty()
    return false
end

---@param rule_path string
---@param with_manager_name boolean?
---@return string
---@diagnostic disable-next-line: unused-local
function this:get_rule_name(rule_path, with_manager_name)
    return ""
end

---@param rule_path string
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:is_rule_triggering(rule_path)
    return false
end

---@param rule_path string
---@return boolean
function this:is_rule_invalid(rule_path)
    local rule = config:get(rule_path) --[[@as ConditionBindRuleConfig]]
    if rule.invalid then
        return true
    end

    for _, condition_group in ipairs(rule.conditions or {}) do
        for _, condition in ipairs(condition_group) do
            if condition.invalid then
                return true
            end
        end
    end

    return false
end

---@param rule_path string
---@return ValidationState
function this:get_rule_invalid(rule_path)
    local rule = config:get(rule_path) --[[@as ConditionBindRuleConfig]]
    if rule.invalid then
        return rule.invalid
    end
    return {}
end

---@param cond_path string
---@return boolean
function this:is_cond_triggering(cond_path)
    return false
end

---@param cond_path string
---@return ValidationState
function this:get_cond_invalid(cond_path)
    local cond = config:get(cond_path) --[[@as ConditionConfigBase]]
    if cond.invalid then
        return cond.invalid
    end
    return {}
end

return this
