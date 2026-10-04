---@class OptionElemGuiCondManagerBase : GuiCondManagerBase

local base = require("HudController.gui.elements.menu_bar.bind.condition.managers.base")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local def = require("HudController.data.option.element.init")
local elem_opt_selector = require("HudController.gui.elements.menu_bar.bind.elem_opt_selector")
local util_bind = require("HudController.gui.elements.menu_bar.bind.condition.util")
local util_table = require("HudController.util.misc.table")

local mod_enum = data.mod.enum

---@class OptionElemGuiCondManagerBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = base })

---@return OptionElemGuiCondManagerBase
function this:new()
    ---@type OptionElemGuiCondManagerBase
    return setmetatable(base.new(self, mod_enum.bind_cond_type.OPTION_ELEM), self)
end

---@param rule_path string
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:draw_target(rule_path)
    local free_value_path = rule_path .. ".free_value"
    local changed = false

    if not config:get(free_value_path) then
        config:set(free_value_path, def.tree.nodes[1].leaves[1].path)
        changed = true
    end

    changed = elem_opt_selector.draw("##cond_target|" .. rule_path, free_value_path) or changed
    if changed then
        local path = config:get(free_value_path)
        local opt = def.get_opt(path)
        config:set(rule_path .. ".free_value2", util_table.deep_copy(opt.default_value))
        config:set(rule_path .. ".free_value3", opt.ctx_path)
    end

    return changed
end

---@param rule_path string
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:draw_option(rule_path)
    local option_key = config:get(rule_path .. ".free_value")

    if not option_key then
        return false
    end

    local opt = def.get_opt(option_key)
    local config_key = string.format("%s.free_value2", rule_path)
    return util_bind.draw_option(config_key, function()
        return opt:draw("##user_opt" .. rule_path, config_key)
    end)
end

---@param rule_path string
---@param with_manager_name boolean?
---@return string
function this:get_rule_name(rule_path, with_manager_name)
    local rule = config:get(rule_path) --[[@as ConditionBindRuleConfig]]
    local invalid = self:get_rule_invalid(rule_path)
    local opt = rule.free_value and def.get_opt(rule.free_value)
    local key = opt and elem_opt_selector.make_short_name(opt.path)
    ---@type string?
    local value

    if not key or invalid.free_value then
        return self:format_rule_name(nil, nil, with_manager_name)
    else
        value = opt:format(rule.free_value2)
    end

    return self:format_rule_name(key, value, with_manager_name)
end

return this
