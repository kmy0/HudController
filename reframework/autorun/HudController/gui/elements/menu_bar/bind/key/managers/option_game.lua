---@class GuiOptionGameKeyManager : GuiKeyManagerBase
---@field manager ModBindManager

local ace = require("HudController.data.ace")
local base = require("HudController.gui.elements.menu_bar.bind.key.managers.base")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local options = require("HudController.hud.manager.options")
local set = require("HudController.gui.set")
local util_table = require("HudController.util.misc.table")

---@class GuiOptionGameKeyManager
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = base })

---@param manager ModBindManager
---@param config_key string
---@return GuiOptionGameKeyManager
function this:new(manager, config_key)
    local o = base.new(self, manager, config_key)
    setmetatable(o, self)
    ---@cast o GuiOptionGameKeyManager
    return o
end

---@return boolean
function this:draw_target()
    return set:combo_filter("##bind_target_combo", "__temp.combo_target", cd.combo.option_game_bind)
end

---@return boolean
function this:draw_option()
    if not self:is_disabled() then
        local key = cd.combo.option_game_bind:get_key(config:get("__temp.combo_target"))
        return generic.draw_option(key, "__temp.option_value", nil, "##" .. key, false)
    end

    return false
end

---@param set_default boolean?
---@return ModBind
function this:make_base_bind(set_default)
    if set_default then
        config:set("__temp.option_value", 0)
    end

    self.base_bind = {
        action_type = cd.combo.bind_action_type:get_key(config:get("__temp.combo_action_type")),
        bound_value = {
            key = cd.combo.option_game_bind:get_key(config:get("__temp.combo_target")),
            value = util_table.deep_copy(config:get("__temp.option_value")),
        },
        trigger_repeat = cd.combo.bind_trigger_type:get_key(
            config:get("__temp.combo_trigger_type")
        ) == "REPEAT",
    }

    return self.base_bind
end

---@param bind ModBind<string, integer>
---@return string
function this:get_bind_name(bind)
    local key = bind.bound_value.key

    return string.format(
        "%s (%s)",
        ace.map.option[key].name_local,
        options.get_option_setting_name(key, bind.bound_value.value)
    )
end

---@return boolean
function this:is_disabled()
    return cd.combo.option_game_bind:empty()
end

return this
