---@class GuiOptionHudKeyManager : GuiKeyManagerBase
---@field manager ModBindManager

local base = require("HudController.gui.elements.menu_bar.bind.key.managers.base")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local def = require("HudController.data.option.hud")
local set = require("HudController.gui.set")
local util_bind = require("HudController.gui.elements.menu_bar.bind.key.util")
local util_table = require("HudController.util.misc.table")

---@class GuiOptionHudKeyManager
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = base })

---@param manager ModBindManager
---@param config_key string
---@return GuiOptionHudKeyManager
function this:new(manager, config_key)
    local o = base.new(self, manager, config_key)
    setmetatable(o, self)
    ---@cast o GuiOptionHudKeyManager
    return o
end

---@return boolean
function this:draw_target()
    return set:combo_filter("##bind_target_combo", "__temp.combo_target", cd.combo.option_hud_bind)
end

---@return boolean
function this:draw_option()
    return util_bind.draw_option(function()
        local key = cd.combo.option_hud_bind:get_key(config:get("__temp.combo_target"))
        local opt = def.opt[key]
        return opt:draw(nil, "__temp.option_value")
    end)
end

function this:set_default()
    local key = cd.combo.option_hud_bind:get_key(config:get("__temp.combo_target"))
    config:set("__temp.option_value", def.get_default(def.opt[key]))
end

---@param set_default boolean?
---@return BindBase
function this:make_base_bind(set_default)
    if set_default then
        self:set_default()
    end

    return base.make_base_bind(self, {
        key = cd.combo.option_hud_bind:get_key(config:get("__temp.combo_target")),
        value = util_table.deep_copy(config:get("__temp.option_value")),
    })
end

---@param bind ModBind<string, any>
---@return string
function this:get_bind_name(bind)
    if bind.invalid then
        return config.lang:tr("misc.text_unknown")
    end

    local opt = def.opt[bind.bound_value.key]
    return base.format_name(self, config.lang:tr(opt.lang_key), opt:format(bind.bound_value.value))
end

return this
