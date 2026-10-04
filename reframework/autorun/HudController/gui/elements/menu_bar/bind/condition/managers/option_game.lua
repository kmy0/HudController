---@class OptionGameGuiCondManagerBase : GuiCondManagerBase

local ace = require("HudController.data.ace")
local base = require("HudController.gui.elements.menu_bar.bind.condition.managers.base")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local options = require("HudController.hud.manager.options")
local set = require("HudController.gui.set")

local mod_enum = data.mod.enum

---@class OptionGameGuiCondManagerBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = base })

---@return OptionGameGuiCondManagerBase
function this:new()
    ---@type OptionGameGuiCondManagerBase
    return setmetatable(base.new(self, mod_enum.bind_cond_type.OPTION_GAME), self)
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
    local free_value = cd.combo.option_game_bind:get_key(index)

    if not invalid.free_value then
        --fix index after removal/add

        if free_value and free_value ~= rule.free_value then
            config:set(target_select_key, cd.combo.option_game_bind:get_index(rule.free_value))
        end
    end

    local changed = set:combo_filter(
        "##cond_target|" .. rule_path,
        target_select_key,
        cd.combo.option_game_bind
    )

    if not free_value and changed and invalid.free_value then
        -- preserving invalid state if index was out of range
        changed = false
    end

    if changed then
        index = config:get(target_select_key)
        rule.free_value = cd.combo.option_game_bind:get_key(index)
        rule.free_value2 = 0
    end

    return changed
end

---@param rule_path string
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:draw_option(rule_path)
    local option_key = config:get(string.format("%s.free_value", rule_path))

    if not option_key then
        imgui.combo("##cond_option|" .. rule_path)
        return false
    end

    return generic.draw_option(
        option_key,
        string.format("%s.free_value2", rule_path),
        nil,
        "##" .. rule_path,
        false
    )
end

---@return boolean
function this:empty()
    return cd.combo.option_game_bind:empty()
end

---@param rule_path string
---@param with_manager_name boolean?
---@return string
function this:get_rule_name(rule_path, with_manager_name)
    local rule = config:get(rule_path) --[[@as ConditionBindRuleConfig]]
    local invalid = self:get_rule_invalid(rule_path)
    local option_data = ace.map.option[rule.free_value] or {}
    local key = option_data.name_local
    ---@type any?
    local value

    if not key or invalid.free_value then
        return self:format_rule_name(nil, nil, with_manager_name)
    else
        value = options.get_option_setting_name(rule.free_value, rule.free_value2)
    end

    return self:format_rule_name(key, value, with_manager_name)
end

return this
