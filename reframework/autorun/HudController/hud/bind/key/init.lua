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
local bind_monitor = require("HudController.hud.bind.key.monitor")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local mod_bind_manager = require("HudController.hud.bind.key.manager")
local options = require("HudController.hud.manager.options")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

---@class ModBinds
local this = {}

---@param bind ModBind
local function action_hud(bind)
    util_table.set_nested_value(this.monitor.frame_storage, { "hud" }, {
        key = bind.bound_value.hud --[[@as integer]],
        profile = { bind.bound_value.profile },
    })
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
                util_table.set_nested_value(
                    this.monitor.frame_storage,
                    { "hud_option", bind.bound_value },
                    value and mod.enum.expected_result.TRUE or mod.enum.expected_result.FALSE
                )
            end
        end)
    end

    util_table.set_nested_value(
        this.monitor.frame_storage,
        { "hud_option", bind.bound_value },
        new_value and mod.enum.expected_result.TRUE or mod.enum.expected_result.FALSE
    )
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
                util_table.set_nested_value(
                    this.monitor.frame_storage,
                    { "mod_option", bind.bound_value },
                    value and mod.enum.expected_result.TRUE or mod.enum.expected_result.FALSE
                )
            end
        end)
    end

    util_table.set_nested_value(
        this.monitor.frame_storage,
        { "mod_option", bind.bound_value },
        new_value and mod.enum.expected_result.TRUE or mod.enum.expected_result.FALSE
    )
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
                util_table.set_nested_value(
                    this.monitor.frame_storage,
                    { "game_option", option_key },
                    value
                )
            end
        end)
    end

    util_table.set_nested_value(
        this.monitor.frame_storage,
        { "game_option", option_key },
        new_value
    )
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
