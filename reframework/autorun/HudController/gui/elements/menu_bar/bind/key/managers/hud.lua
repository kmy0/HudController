---@class GuiHudKeyManager : GuiKeyManagerBase
---@field manager ModBindManager

local base = require("HudController.gui.elements.menu_bar.bind.key.managers.base")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local op = require("HudController.hud.manager.op.init")
local set = require("HudController.gui.set")
local util_bind = require("HudController.gui.elements.menu_bar.bind.util")
local util_imgui = require("HudController.util.imgui.init")
local util_table = require("HudController.util.misc.table")

---@class GuiHudKeyManager
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = base })

---@param manager ModBindManager
---@param config_key string
---@return GuiHudKeyManager
function this:new(manager, config_key)
    local o = base.new(self, manager, config_key)
    setmetatable(o, self)
    ---@cast o GuiHudKeyManager
    return o
end

---@return boolean
function this:draw_target()
    return set:combo_filter("##bind_target_combo", "__temp.combo_target", cd.combo.hud)
end

---@return boolean
function this:draw_option()
    local config_mod = config.current.mod
    local values = {}
    local hud_profile = config_mod.hud[config:get("__temp.combo_target")]
    if hud_profile then
        values = util_table.slice(hud_profile.profile, 2, #hud_profile.profile)
    end

    util_imgui.begin_disabled(util_table.empty(values))
    local changed = set:combo_multi_bits_filter(
        "##elem_profile_hud_bind",
        "__temp.option_value",
        config.lang:tr("misc.text_none"),
        values,
        function(v)
            return v.key
        end,
        function(v)
            return v.name
        end
    )
    util_imgui.end_disabled()

    return changed
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
        key = config.current.mod.hud[config:get("__temp.combo_target")].key,
        value = util_table.deep_copy(config:get("__temp.option_value")),
    })
end

---@param bind ModBind<integer, any>
---@return string
function this:get_bind_name(bind)
    if bind.invalid then
        return config.lang:tr("misc.text_unknown")
    end

    local hud_profile = op.hud_profile.get_hud_by_key(bind.bound_value.key)
    local name = hud_profile.name

    if bind.bound_value.value ~= 0 then
        local profiles = util_bind.elem_profiles_to_name(hud_profile, bind.bound_value.value)
        return string.format("%s (%s)", name, profiles)
    end

    return name
end

---@return boolean
function this:is_disabled()
    return util_table.empty(config.current.mod.hud)
end

return this
