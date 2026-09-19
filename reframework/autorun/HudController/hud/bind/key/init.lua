---@class ModBinds
---@field option_hud ModBindManager
---@field option_mod ModBindManager
---@field hud ModBindManager
---@field option_game ModBindManager
---@field monitor ModBindMonitor

---@class (exact) ModBindBase : BindBase
---@field action_type BindActionType

---@class (exact) ModBind : Bind, ModBindBase

local util_misc = require("HudController.util.misc.init")
---@module "HudController.hud.init"
local hud = util_misc.lazy_require("HudController.hud.init")
local ace = require("HudController.data.ace")
local ace_misc = require("HudController.util.ace.misc")
local bind_monitor = require("HudController.hud.bind.key.monitor")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local mod_bind_manager = require("HudController.hud.bind.key.manager")
local options = require("HudController.hud.manager.options")
local state = require("HudController.gui.state")
---@module "HudController.hud.manager.op.init"
local op = util_misc.lazy_require("HudController.hud.manager.op.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

---@class ModBinds
local this = {}

---@param bind ModBind
local function action_hud(bind)
    local config_mod = config.current.mod
    local hud_config = op.hud_profile.get_hud_by_key(bind.bound_value.hud --[[@as integer]])
    state.input = nil

    hud.force_request_hud_with_profiles(hud_config, { bind.bound_value.profile })
    config_mod.combo.hud = util_table.index(config_mod.hud, function(o)
        return o.key == bind.bound_value.hud
    end) --[[@as integer]]
end

---@param bind ModBind
local function action_option_hud(bind)
    local manager_name = "option_hud"
    local is_triggered = this.monitor:is_triggered(manager_name, bind)
    local is_hold = bind.action_type == mod.enum.action_type.ENABLE_HOLD
        or bind.action_type == mod.enum.action_type.DISABLE_HOLD
        or bind.action_type == mod.enum.action_type.TOGGLE_HOLD
    local hud_profile = hud.get_current() --[[@as ModProfileConfig]]
    local current_value = hud_profile[bind.bound_value] --[[@as boolean]]
    ---@type boolean?
    local new_value

    if
        bind.action_type == mod.enum.action_type.ENABLE
        or bind.action_type == mod.enum.action_type.ENABLE_HOLD
    then
        new_value = true
    elseif
        bind.action_type == mod.enum.action_type.DISABLE
        or bind.action_type == mod.enum.action_type.DISABLE_HOLD
    then
        new_value = false
    elseif
        bind.action_type == mod.enum.action_type.TOGGLE
        or bind.action_type == mod.enum.action_type.TOGGLE_HOLD
    then
        if is_triggered then
            new_value = not current_value
            this.monitor:set_action_value(manager_name, bind, new_value)
        else
            new_value = this.monitor:get_action_value(manager_name, bind)
        end
    end

    if new_value == nil then
        return
    end

    if is_triggered and is_hold then
        new_value =
            this.monitor:push_hold(manager_name, bind.bound_value, bind, new_value, current_value)
        this.monitor:register_on_release_callback(bind.name, function()
            local value = this.monitor:remove_hold(manager_name, bind.bound_value, bind)

            if value ~= nil then
                hud.overwrite_hud_option(bind.bound_value --[[@as string]], value)
            end
        end)
    end

    local val = hud.overwrite_hud_option(bind.bound_value --[[@as string]], new_value)
    if val == nil then
        return
    end

    if config.current.mod.enable_notification and is_triggered then
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
    local manager_name = "option_mod"
    local is_triggered = this.monitor:is_triggered(manager_name, bind)
    local config_mod = config.current.mod

    local is_hold = bind.action_type == mod.enum.action_type.ENABLE_HOLD
        or bind.action_type == mod.enum.action_type.DISABLE_HOLD
        or bind.action_type == mod.enum.action_type.TOGGLE_HOLD

    local current_value = config_mod[bind.bound_value] --[[@as boolean]]

    ---@type boolean?
    local new_value

    if
        bind.action_type == mod.enum.action_type.ENABLE
        or bind.action_type == mod.enum.action_type.ENABLE_HOLD
    then
        new_value = true
    elseif
        bind.action_type == mod.enum.action_type.DISABLE
        or bind.action_type == mod.enum.action_type.DISABLE_HOLD
    then
        new_value = false
    elseif
        bind.action_type == mod.enum.action_type.TOGGLE
        or bind.action_type == mod.enum.action_type.TOGGLE_HOLD
    then
        if is_triggered then
            new_value = not current_value

            this.monitor:set_action_value(manager_name, bind, new_value)
        else
            new_value = this.monitor:get_action_value(manager_name, bind)
        end
    end

    if new_value == nil then
        return
    end

    if is_triggered and is_hold then
        new_value =
            this.monitor:push_hold(manager_name, bind.bound_value, bind, new_value, current_value)

        this.monitor:register_on_release_callback(bind.name, function()
            local value = this.monitor:remove_hold(manager_name, bind.bound_value, bind)

            if value ~= nil then
                ---@diagnostic disable-next-line: no-unknown
                config_mod[bind.bound_value] = value
            end
        end)
    end

    ---@diagnostic disable-next-line: no-unknown
    config_mod[bind.bound_value] = new_value

    if config.current.mod.enable_notification and is_triggered then
        ace_misc.send_message(
            string.format(
                "%s %s %s",
                config.lang:tr("menu.config." .. mod.map.options_mod[bind.bound_value]),
                config.lang:tr("misc.text_changed_notifcation_message"),
                new_value
            )
        )
    end
end

---@param bind ModBind
local function action_option_game(bind)
    local manager_name = "option_game"
    local is_triggered = this.monitor:is_triggered(manager_name, bind)
    local option_key = bind.bound_value.option_key --[[@as string]]
    local new_value = bind.bound_value.value --[[@as integer]]
    local is_hold = bind.action_type == mod.enum.action_type.TOGGLE_HOLD

    if is_triggered and is_hold then
        local current_value = options.get_option(option_key)
        new_value = this.monitor:push_hold(manager_name, option_key, bind, new_value, current_value)
        this.monitor:register_on_release_callback(bind.name, function()
            local value = this.monitor:remove_hold(manager_name, option_key, bind)
            if value ~= nil then
                options.apply_option(option_key, value)
            end
        end)
    end

    options.apply_option(option_key, new_value)
    if config.current.mod.enable_notification and is_triggered then
        ace_misc.send_message(
            string.format(
                "%s %s %s",
                ace.map.option[option_key].name_local,
                config.lang:tr("misc.text_changed_notifcation_message"),
                options.get_option_setting_name(option_key, new_value)
            )
        )
    end
end

---@return boolean
function this.init()
    local bind_key = config.current.mod.bind.key

    this.option_hud = mod_bind_manager:new("option_hud", action_option_hud)
    this.option_mod = mod_bind_manager:new("option_mod", action_option_mod)
    this.option_game = mod_bind_manager:new("option_game", action_option_game)
    this.hud = mod_bind_manager:new("hud", action_hud)

    if not this.option_hud:load(bind_key.option_hud) then
        bind_key.option_hud = this.option_hud:get_base_binds()
    end

    if not this.option_mod:load(bind_key.option_mod) then
        bind_key.option_mod = this.option_mod:get_base_binds()
    end

    if not this.option_game:load(bind_key.option_game) then
        bind_key.option_game = this.option_game:get_base_binds()
    end

    if not this.hud:load(bind_key.hud) then
        bind_key.hud = this.hud:get_base_binds()
    end

    this.monitor = bind_monitor:new(this.option_mod, this.hud, this.option_hud, this.option_game)
    this.monitor:set_max_buffer_frame(bind_key.buffer)
    return true
end

return this
