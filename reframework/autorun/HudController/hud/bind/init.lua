---@class ModBinds
---@field option_hud ModBindManager
---@field option_mod ModBindManager
---@field hud ModBindManager
---@field monitor ModBindMonitor

---@class (exact) ModBindBase : BindBase
---@field action_type BindActionType

---@class (exact) ModBind : Bind, ModBindBase

---@module "HudController.hud"
local hud
local ace_misc = require("HudController.util.ace.misc")
local bind_monitor = require("HudController.hud.bind.monitor")
local config = require("HudController.config")
local data = require("HudController.data")
local mod_bind_manager = require("HudController.hud.bind.manager")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

---@class ModBinds
local this = {}

---@enum ModBindManagerType
this.manager_names = {
    OPTION_HUD = "option_hud",
    HUD = "hud",
    OPTION_MOD = "option_mod",
}
---@enum BindActionType
this.action_type = {
    NONE = "NONE",
    TOGGLE = "TOGGLE",
    ENABLE = "ENABLE",
    DISABLE = "DISABLE",
}

---@param bind ModBind
local function action_hud(bind)
    if not hud then
        hud = require("HudController.hud")
    end

    local config_mod = config.current.mod
    local hud_config = hud.operations.get_hud_by_key(bind.bound_value --[[@as integer]])

    hud.request_hud(hud_config)
    config_mod.combo.hud = util_table.index(config_mod.hud, function(o)
        return o.key == bind.bound_value
    end) --[[@as integer]]

    config:save()
end

---@param bind ModBind
local function action_option_hud(bind)
    if not hud then
        hud = require("HudController.hud")
    end

    ---@type boolean?
    local new_value
    if bind.action_type == this.action_type.ENABLE then
        new_value = true
    elseif bind.action_type == this.action_type.DISABLE then
        new_value = false
    end

    local val = hud.overwrite_hud_option(bind.bound_value --[[@as string]], new_value)
    if val == nil then
        return
    end

    if config.current.mod.enable_notification then
        ace_misc.send_message(
            string.format(
                "%s %s %s",
                config.lang:tr("hud." .. mod.map.options_hud[bind.bound_value]),
                config.lang:tr("misc.text_override_notifcation_message"),
                val
            )
        )
    end
end

---@param bind ModBind
local function action_option_mod(bind)
    if not hud then
        hud = require("HudController.hud")
    end

    local config_mod = config.current.mod

    ---@type boolean?
    local new_value
    if bind.action_type == this.action_type.ENABLE then
        new_value = true
    elseif bind.action_type == this.action_type.DISABLE then
        new_value = false
    end

    if config_mod[bind.bound_value] == new_value then
        return
    end

    if new_value == nil then
        ---@diagnostic disable-next-line: no-unknown
        config_mod[bind.bound_value] = not config_mod[bind.bound_value]
    else
        ---@diagnostic disable-next-line: no-unknown
        config_mod[bind.bound_value] = new_value
    end

    if config.current.mod.enable_notification then
        ace_misc.send_message(
            string.format(
                "%s %s %s",
                config.lang:tr("menu.config." .. mod.map.options_mod[bind.bound_value]),
                config.lang:tr("misc.text_changed_notifcation_message"),
                config_mod[bind.bound_value]
            )
        )
    end

    config:save()
end

---@return boolean
function this.init()
    local bind_key = config.current.mod.bind.key

    this.option_hud = mod_bind_manager:new("option_hud", action_option_hud)
    this.option_mod = mod_bind_manager:new("option_mod", action_option_mod)
    this.hud = mod_bind_manager:new("hud", action_hud)

    if not this.option_hud:load(bind_key.option_hud) then
        bind_key.option_hud = this.option_hud:get_base_binds()
    end

    if not this.option_mod:load(bind_key.option_mod) then
        bind_key.option_mod = this.option_mod:get_base_binds()
    end

    if not this.hud:load(bind_key.hud) then
        bind_key.hud = this.hud:get_base_binds()
    end

    this.monitor = bind_monitor:new(this.option_mod, this.hud, this.option_hud)
    this.monitor:set_max_buffer_frame(bind_key.buffer)
    return true
end

return this
