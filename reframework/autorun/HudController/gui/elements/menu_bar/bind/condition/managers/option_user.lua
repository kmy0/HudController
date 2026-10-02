---@class OptionUserGuiCondManagerBase : GuiCondManagerBase

local base = require("HudController.gui.elements.menu_bar.bind.condition.managers.base")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local set = require("HudController.gui.set")
local user = require("HudController.hud.user.init")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")

local mod_enum = data.mod.enum

---@class OptionUserGuiCondManagerBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = base })

---@return OptionUserGuiCondManagerBase
function this:new()
    ---@type OptionUserGuiCondManagerBase
    return setmetatable(base.new(self), self)
end

---@param rule_path string
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:draw_target(rule_path)
    local target_select_key = string.format("%s.target_select", rule_path)
    local rule = config:get(rule_path) --[[@as ConditionBindRuleConfig]]
    local invalid = self:get_rule_invalid(rule_path)
    local index = config:get(target_select_key) --[[@as integer]]
    ---@type RegisteredUserOption?
    local registered_opt = cd.combo.option_user_bind:get_key(index)
    ---@type string?
    local free_value

    if registered_opt and registered_opt.bindable then
        free_value = registered_opt.key
    end

    if not invalid.free_value then
        --fix index after removal/add

        if free_value and free_value ~= rule.free_value and registered_opt then
            config:set(target_select_key, cd.combo.option_user_bind:get_index(registered_opt))
        end
    end

    local changed = set:combo_filter(
        "##cond_target|" .. rule_path,
        target_select_key,
        cd.combo.option_user_bind
    )

    if not free_value and changed and invalid.free_value then
        -- preserving invalid state if index was out of range
        changed = false
    end

    if changed then
        index = config:get(target_select_key)
        registered_opt = cd.combo.option_user_bind:get_key(index)
        rule.free_value = registered_opt.key
        rule.free_value2 = user.option.get_default(registered_opt)
    end

    return changed
end

---@param rule_path string
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:draw_option(rule_path)
    local option_key = config:get(string.format("%s.free_value", rule_path))
    local registered_opt = user.option.bindable[option_key]

    if not registered_opt then
        util_imgui.begin_disabled(true)
        imgui.input_text("##user_opt" .. rule_path, "")
        util_imgui.end_disabled()
        return false
    end

    return registered_opt:draw(
        "##user_opt" .. rule_path,
        string.format("%s.free_value2", rule_path)
    )
end

---@return boolean
function this:empty()
    return cd.combo.option_user_bind:empty()
end

---@param rule_path string
---@param with_manager_name boolean?
---@return string
function this:get_rule_name(rule_path, with_manager_name)
    with_manager_name = with_manager_name == nil or with_manager_name
    local rule = config:get(rule_path) --[[@as ConditionBindRuleConfig]]
    local invalid = self:get_rule_invalid(rule_path)
    local option_key = config:get(string.format("%s.free_value", rule_path))
    local registered_opt = user.option.bindable[option_key]
    local name = registered_opt and registered_opt.name
    ---@type string?
    local ret

    if not name or invalid.free_value then
        ret = config.lang:tr("misc.text_unknown")
    else
        ret = name

        if invalid.free_value2 then
            ret = string.format("%s (%s)", ret, config.lang:tr("misc.text_unknown"))
        else
            ret = string.format("%s (%s)", ret, registered_opt:format(rule.free_value2))
        end
    end

    if with_manager_name then
        ret = string.format(
            "%s: %s",
            config.lang:tr(
                "menu.bind.condition.bind_cond_type." .. mod_enum.bind_cond_type.OPTION_USER
            ),
            ret
        )
    end

    return util_misc.trunc_string2(ret, util_imgui.scale_w_font_size(180))
end

return this
