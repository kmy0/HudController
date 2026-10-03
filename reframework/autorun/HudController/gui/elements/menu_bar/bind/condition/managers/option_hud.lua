---@class OptionHudGuiCondManagerBase : GuiCondManagerBase

local base = require("HudController.gui.elements.menu_bar.bind.condition.managers.base")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local def = require("HudController.data.option.hud")
local set = require("HudController.gui.set")
local util_bind = require("HudController.gui.elements.menu_bar.bind.condition.util")

local mod_enum = data.mod.enum

---@class OptionHudGuiCondManagerBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = base })

---@return OptionHudGuiCondManagerBase
function this:new()
    ---@type OptionHudGuiCondManagerBase
    return setmetatable(base.new(self, mod_enum.bind_cond_type.OPTION_HUD), self)
end

---@param rule_path string
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:draw_target(rule_path)
    local target_select_key = string.format("%s.target_select", rule_path)
    local rule = config:get(rule_path) --[[@as ConditionBindRuleConfig]]
    local invalid = self:get_rule_invalid(rule_path)
    local index = config:get(target_select_key) --[[@as integer]]
    ---@type string?
    local free_value = cd.combo.option_hud_bind:get_key(index)

    if not invalid.free_value then
        --fix index after removal/add

        if free_value and free_value ~= rule.free_value then
            config:set(target_select_key, cd.combo.option_hud_bind:get_index(rule.free_value))
        end
    end

    local changed =
        set:combo_filter("##cond_target|" .. rule_path, target_select_key, cd.combo.option_hud_bind)

    if not free_value and changed and invalid.free_value then
        -- preserving invalid state if index was out of range
        changed = false
    end

    if changed then
        index = config:get(target_select_key)
        rule.free_value = cd.combo.option_hud_bind:get_key(index)
        rule.free_value2 = def.get_default(def.opt[rule.free_value])
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

    local opt = def.opt[option_key]
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
    local opt = def.opt[rule.free_value]
    local key = opt and config.lang:tr(opt.lang_key)
    ---@type string?
    local value

    if not key or invalid.free_value then
        return self:format_rule_name(nil, nil, with_manager_name)
    else
        key = key
        value = opt:format(rule.free_value2)
    end

    return self:format_rule_name(key, value, with_manager_name)
end

return this
