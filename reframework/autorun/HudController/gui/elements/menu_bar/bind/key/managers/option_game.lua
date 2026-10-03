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

function this:set_default()
    config:set("__temp.option_value", 0)
end

---@param set_default boolean?
---@return BindBase
function this:make_base_bind(set_default)
    if set_default then
        self:set_default()
    end

    return base.make_base_bind(self, {
        key = cd.combo.option_game_bind:get_key(config:get("__temp.combo_target")),
        value = util_table.deep_copy(config:get("__temp.option_value")),
    })
end

---@param bind ModBind<string, integer>
---@return string
function this:get_bind_name(bind)
    if bind.invalid then
        return config.lang:tr("misc.text_unknown")
    end

    local key = bind.bound_value.key
    return base.format_name(
        self,
        ace.map.option[key].name_local,
        options.get_option_setting_name(key, bind.bound_value.value)
    )
end

---@return boolean
function this:is_disabled()
    return cd.combo.option_game_bind:empty()
end

return this
