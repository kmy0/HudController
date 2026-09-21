---@class GuiOptionUserKeyManager : GuiKeyManagerBase
---@field manager ModBindManager

local base = require("HudController.gui.elements.menu_bar.bind.key.managers.base")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local set = require("HudController.gui.set")
local user_option = require("HudController.hud.user.option")
local util_bind = require("HudController.gui.elements.menu_bar.bind.key.util")
local util_table = require("HudController.util.misc.table")

---@class GuiOptionUserKeyManager
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = base })

---@param manager ModBindManager
---@param config_key string
---@return GuiOptionUserKeyManager
function this:new(manager, config_key)
    local o = base.new(self, manager, config_key)
    setmetatable(o, self)
    ---@cast o GuiOptionUserKeyManager
    return o
end

---@return boolean
function this:draw_target()
    return set:combo_filter("##bind_target_combo", "__temp.combo_target", cd.combo.option_user_bind)
end

---@return boolean
function this:draw_option()
    if not self:is_disabled() then
        return util_bind.draw_option(function()
            local opt = cd.combo.option_user_bind:get_key(config:get("__temp.combo_target"))
            return opt:draw(opt.label, "__temp.option_value")
        end)
    end

    return false
end

---@param set_default boolean?
---@return ModBind
function this:make_base_bind(set_default)
    if set_default then
        local opt = cd.combo.option_user_bind:get_key(config:get("__temp.combo_target")) --[[@as RegisteredUserOption]]
        config:set("__temp.option_value", user_option.get_default(opt))
    end

    self.base_bind = {
        action_type = cd.combo.bind_action_type:get_key(config:get("__temp.combo_action_type")),
        bound_value = {
            key = cd.combo.option_user_bind:get_key(config:get("__temp.combo_target")).key,
            value = util_table.deep_copy(config:get("__temp.option_value")),
        },
        trigger_repeat = cd.combo.bind_trigger_type:get_key(
            config:get("__temp.combo_trigger_type")
        ) == "REPEAT",
    }

    return self.base_bind
end

---@param bind ModBind<string, any>
---@return string
function this:get_bind_name(bind)
    local user_opt = user_option.bindable[bind.bound_value.key]
    return string.format(
        "%s (%s)",
        user_opt.label,
        user_option.format_value(user_opt, bind.bound_value.value)
    )
end

---@return boolean
function this:is_disabled()
    return cd.combo.option_user_bind:empty()
end

return this
