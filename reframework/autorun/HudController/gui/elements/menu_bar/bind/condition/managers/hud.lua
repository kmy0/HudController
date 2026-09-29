---@class HudGuiCondManagerBase : GuiCondManagerBase

local base = require("HudController.gui.elements.menu_bar.bind.condition.managers.base")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local op = require("HudController.hud.manager.op.init")
local set = require("HudController.gui.set")
local util_bind = require("HudController.gui.elements.menu_bar.bind.util")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local mod_enum = data.mod.enum

---@class HudGuiCondManagerBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = base })

---@return HudGuiCondManagerBase
function this:new()
    ---@type HudGuiCondManagerBase
    return setmetatable(base.new(self), self)
end

---@param rule_path string
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:draw_target(rule_path)
    local config_mod = config.current.mod
    local target_select_key = string.format("%s.target_select", rule_path)
    local rule = config:get(rule_path) --[[@as ConditionBindRuleConfig]]
    local invalid = self:get_rule_invalid(rule_path)
    local index = config:get(target_select_key) --[[@as integer]]
    local hud_config = config_mod.hud[index]

    if not invalid.free_value then
        --fix index after sort

        ---@type integer?
        local free_value
        if hud_config then
            free_value = hud_config.key
        end

        if free_value and free_value ~= rule.free_value then
            config:get(target_select_key, cd.combo.hud:get_index(rule.free_value))
        end
    end

    local changed = set:combo_filter("##cond_target|" .. rule_path, target_select_key, cd.combo.hud)

    if not hud_config and changed and invalid.free_value then
        -- preserving invalid state if index was out of range
        changed = false
    end

    if changed then
        index = config:get(target_select_key) --[[@as integer]]
        rule.free_value = config_mod.hud[index].key
        rule.free_value2 = 0
    end

    return changed
end

---@param rule_path string
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:draw_option(rule_path)
    local rule = config:get(rule_path) --[[@as ConditionBindRuleConfig]]
    local hud_key = rule and rule.free_value
    local invalid = self:get_rule_invalid(rule_path)
    ---@type HudBaseConfigProfileForShow[]
    local values
    ---@type ModProfileConfig?
    local hud_profile

    if hud_key then
        hud_profile = op.hud_profile.get_hud_by_key(hud_key)
    end

    if hud_profile then
        values = util_table.slice(hud_profile.profile, 2, #hud_profile.profile)
    else
        values = {}
    end

    util_imgui.begin_disabled(util_table.empty(values) and not invalid.free_value2)
    local changed = set:combo_multi_bits_filter(
        "##cond_option|" .. rule_path,
        string.format("%s.free_value2", rule_path),
        config.lang:tr("misc.text_none"),
        values,
        function(v)
            return v.key
        end,
        function(v)
            return v.name
        end
    )

    if invalid.free_value2 and util_table.empty(values) and imgui.is_item_active() then
        -- clearing invalid state
        changed = true
    end

    util_imgui.end_disabled()
    return changed
end

---@return boolean
function this:empty()
    return cd.combo.hud:empty()
end

---@param config_key string
---@param with_manager_name boolean?
---@return string
function this:get_rule_name(config_key, with_manager_name)
    with_manager_name = with_manager_name == nil or with_manager_name
    local rule = config:get(config_key) --[[@as ConditionBindRuleConfig]]
    local hud_profile = op.hud_profile.get_hud_by_key(rule.free_value)
    ---@type string?
    local ret

    if not hud_profile then
        ret = config.lang:tr("misc.text_unknown")
    else
        ret = hud_profile.name

        if rule.free_value2 ~= 0 then
            local invalid = self:get_rule_invalid(config_key)

            if invalid.free_value2 then
                ret = string.format("%s (%s)", ret, config.lang:tr("misc.text_unknown"))
            else
                local profiles = util_bind.elem_profiles_to_name(hud_profile, rule.free_value2)
                ret = string.format("%s (%s)", ret, profiles)
            end
        end
    end

    if with_manager_name then
        ret = string.format(
            "%s: %s",
            config.lang:tr("menu.bind.condition.bind_cond_type." .. mod_enum.bind_cond_type.HUD),
            ret
        )
    end

    return util_misc.trunc_string2(ret, util_imgui.scale_w_font_size(180))
end

return this
