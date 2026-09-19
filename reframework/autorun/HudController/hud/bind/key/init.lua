---@class ModBinds
---@field option_hud OptionModBindManager
---@field option_mod OptionModBindManager
---@field hud HudModBindManager
---@field option_game OptionModBindManager
---@field monitor ModBindMonitor

---@class (exact) ModBindBase : BindBase
---@field action_type BindActionType

---@class (exact) ModBind : Bind, ModBindBase

---@class ModBindMonitor : BindMonitor
---@field frame_storage BindEvalRet

---@class (exact) BindEvalRet : ConditionEvalRet

local util_misc = require("HudController.util.misc.init")
---@module "HudController.hud.init"
local hud = util_misc.lazy_require("HudController.hud.init")
local bind_monitor = require("HudController.util.game.bind.monitor")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local hud_bind_manager = require("HudController.hud.bind.key.hud_manager")
local option_bind_manager = require("HudController.hud.bind.key.option_manager")
local options = require("HudController.hud.manager.options")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

---@class ModBinds
local this = {}

---@param bind ModBind
local function action_hud(bind)
    util_table.set_nested_value(this.monitor.frame_storage, { "hud" }, {
        key = bind.bound_value.key --[[@as integer]],
        profile = { bind.bound_value.value },
    })
end

---@param bind ModBind
local function action_option_hud(bind)
    local manager_name = "option_hud"
    local is_triggered = this.monitor:is_triggered(manager_name, bind)
    local key = bind.bound_value.key --[[@as string]]
    local new_value = bind.bound_value.value --[[@as integer]]
    local is_hold = bind.action_type == mod.enum.action_type.SET_HOLD

    if is_triggered and is_hold then
        local hud_profile = hud.get_current() --[[@as ModProfileConfig]]
        local current_value = hud_profile[key] and 1 or 0
        new_value = this.monitor:push_hold(manager_name, key, bind, new_value, current_value)
        this.monitor:register_on_release_callback(bind.name, function()
            local value = this.monitor:remove_hold(manager_name, key, bind)
            if value ~= nil then
                util_table.set_nested_value(
                    this.monitor.frame_storage,
                    { "hud_option", key },
                    value
                )
            end
        end)
    end

    util_table.set_nested_value(this.monitor.frame_storage, { "hud_option", key }, new_value)
end

---@param bind ModBind
local function action_option_mod(bind)
    local manager_name = "option_mod"
    local is_triggered = this.monitor:is_triggered(manager_name, bind)
    local key = bind.bound_value.key --[[@as string]]
    local new_value = bind.bound_value.value --[[@as integer]]
    local is_hold = bind.action_type == mod.enum.action_type.SET_HOLD

    if is_triggered and is_hold then
        local config_mod = config.current.mod
        local current_value = config_mod[key] and 1 or 0
        new_value = this.monitor:push_hold(manager_name, key, bind, new_value, current_value)
        this.monitor:register_on_release_callback(bind.name, function()
            local value = this.monitor:remove_hold(manager_name, key, bind)
            if value ~= nil then
                util_table.set_nested_value(
                    this.monitor.frame_storage,
                    { "mod_option", key },
                    value
                )
            end
        end)
    end

    util_table.set_nested_value(this.monitor.frame_storage, { "mod_option", key }, new_value)
end

---@param bind ModBind
local function action_option_game(bind)
    local manager_name = "option_game"
    local is_triggered = this.monitor:is_triggered(manager_name, bind)
    local key = bind.bound_value.key --[[@as string]]
    local new_value = bind.bound_value.value --[[@as integer]]
    local is_hold = bind.action_type == mod.enum.action_type.SET_HOLD

    if is_triggered and is_hold then
        local current_value = options.get_option(key)
        new_value = this.monitor:push_hold(manager_name, key, bind, new_value, current_value)
        this.monitor:register_on_release_callback(bind.name, function()
            local value = this.monitor:remove_hold(manager_name, key, bind)
            if value ~= nil then
                util_table.set_nested_value(
                    this.monitor.frame_storage,
                    { "game_option", key },
                    value
                )
            end
        end)
    end

    util_table.set_nested_value(this.monitor.frame_storage, { "game_option", key }, new_value)
end

---@return boolean
function this.init()
    local bind_key = config.current.mod.bind.key

    this.option_hud = option_bind_manager:new("option_hud", action_option_hud)
    this.option_mod = option_bind_manager:new("option_mod", action_option_mod)
    this.option_game = option_bind_manager:new("option_game", action_option_game)
    this.hud = hud_bind_manager:new("hud", action_hud)

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

    ---@diagnostic disable-next-line: assign-type-mismatch
    this.monitor = bind_monitor:new(this.option_mod, this.hud, this.option_hud, this.option_game)
    this.monitor:set_max_buffer_frame(bind_key.buffer)
    return true
end

return this
