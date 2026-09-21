---@class GuiHudKeyManager : GuiKeyManagerBase
---@field manager ModBindManager

local base = require("HudController.gui.elements.menu_bar.bind.key.managers.base")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local op = require("HudController.hud.manager.op.init")
local set = require("HudController.gui.set")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@class GuiHudKeyManager
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = base })

---@param hud_config ModProfileConfig
---@param bits integer
---@return string
local function elem_profiles_to_name(hud_config, bits)
    local elem_profile_keys = util_misc.unpack_bits(bits)
    ---@type string[]
    local names = {}
    for _, key in ipairs(elem_profile_keys) do
        local profile = util_table.find_value(hud_config.profile, function(_, value)
            return value.key == key
        end) --[[@as HudBaseConfigProfileForShow]]
        if profile then
            table.insert(names, profile.name)
        end
    end

    return table.concat(names, ", ")
end

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

---@param set_default boolean?
---@return ModBind
function this:make_base_bind(set_default)
    if set_default then
        config:set("__temp.option_value", 0)
    end

    self.base_bind = {
        action_type = cd.combo.bind_action_type:get_key(config:get("__temp.combo_action_type")),
        bound_value = {
            key = cd.combo.hud:get_key(config:get("__temp.combo_target")),
            value = util_table.deep_copy(config:get("__temp.option_value")),
        },
        trigger_repeat = cd.combo.bind_trigger_type:get_key(
            config:get("__temp.combo_trigger_type")
        ) == "REPEAT",
    }

    return self.base_bind
end

---@param bind ModBind<integer, any>
---@return string
function this:get_bind_name(bind)
    local hud_profile = op.hud_profile.get_hud_by_key(bind.bound_value.key)
    local name = hud_profile.name

    if bind.bound_value.value ~= 0 then
        local profiles = elem_profiles_to_name(hud_profile, bind.bound_value.value)
        return string.format("%s (%s)", name, profiles)
    end

    return name
end

---@return boolean
function this:is_disabled()
    return util_table.empty(config.current.mod.hud)
end

return this
