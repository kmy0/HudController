---@class ModBinds
---@field option_hud OptionModBindManager
---@field option_mod OptionModBindManager
---@field option_user OptionModBindManager
---@field hud HudModBindManager
---@field option_game OptionModBindManager
---@field option_elem OptionModBindManager
---@field monitor ModBindMonitor

---@class (exact) ModBindBase : BindBase
---@field action_type BindActionType

---@class (exact) ModBind<K ,V, F> : Bind, ModBindBase
---@field bound_value {key: K, value: V, free_value: F}

---@class ModBindMonitor : BindMonitor
---@field frame_storage BindEvalRet

---@class (exact) BindEvalRet : ConditionEvalRet

local bind_monitor = require("HudController.util.game.bind.monitor")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local def = require("HudController.data.option.init")
local hud_bind_manager = require("HudController.hud.bind.key.hud_manager")
local option_bind_manager = require("HudController.hud.bind.key.option_manager")
local options = require("HudController.hud.manager.options")
local profile_switcher = require("HudController.hud.manager.profile_switcher")
local user_option = require("HudController.hud.user.option")
local util_misc = require("HudController.util.misc.init")
local util_opt = require("HudController.data.option.util")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.init"
local hud = util_misc.lazy_require("HudController.hud.init")

local mod = data.mod

---@class ModBinds
local this = {}

---@param bind ModBind<integer, integer>
local function action_hud(bind)
    local manager_name = "hud"
    local is_triggered = this.monitor:is_triggered(manager_name, bind)
    local is_hold = bind.action_type == mod.enum.action_type.SET_HOLD
    local new_value = {
        key = bind.bound_value.key,
        profile = { bind.bound_value.value },
    }

    if is_triggered and is_hold and profile_switcher.current_hud then
        local current = profile_switcher.current_hud --[[@as ModHud]]
        new_value = this.monitor:push_hold(
            manager_name,
            bind.bound_value.key,
            bind,
            new_value,
            { key = current.hud.key, profile = util_table.deep_copy(current.profile_bits) }
        )
        this.monitor:register_on_release_callback(bind.name, function()
            local value = this.monitor:remove_hold(manager_name, bind.bound_value.key, bind)
            if value ~= nil then
                util_table.set_nested_value(this.monitor.frame_storage, { "hud" }, value)
            end
        end)
    end

    util_table.set_nested_value(this.monitor.frame_storage, { "hud" }, new_value)
end

---@param bind ModBind<string, integer>
local function action_option_hud(bind)
    local manager_name = "option_hud"
    local is_triggered = this.monitor:is_triggered(manager_name, bind)
    local key = bind.bound_value.key
    local new_value = bind.bound_value.value
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

---@param bind ModBind<string, any>
local function action_option_mod(bind)
    local manager_name = "option_mod"
    local is_triggered = this.monitor:is_triggered(manager_name, bind)
    local key = bind.bound_value.key
    local new_value = util_table.deep_copy(bind.bound_value.value)
    local is_hold = bind.action_type == mod.enum.action_type.SET_HOLD

    if is_triggered and is_hold then
        local opt = def.mod.opt[key]
        local current_value = util_table.deep_copy(config:get(opt.config_key))

        this.monitor:push_hold(
            manager_name,
            key,
            bind,
            util_table.deep_copy(new_value),
            current_value
        )
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

---@param bind ModBind<string, integer>
local function action_option_game(bind)
    local manager_name = "option_game"
    local is_triggered = this.monitor:is_triggered(manager_name, bind)
    local key = bind.bound_value.key
    local new_value = bind.bound_value.value
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

---@param bind ModBind<string, any>
local function action_option_user(bind)
    local manager_name = "option_user"
    local is_triggered = this.monitor:is_triggered(manager_name, bind)
    local key = bind.bound_value.key
    local new_value = bind.bound_value.value
    local is_hold = bind.action_type == mod.enum.action_type.SET_HOLD

    if is_triggered and is_hold then
        local current_value = user_option.get_current_value(user_option.bindable[key])
        new_value = this.monitor:push_hold(manager_name, key, bind, new_value, current_value)

        this.monitor:register_on_release_callback(bind.name, function()
            local value = this.monitor:remove_hold(manager_name, key, bind)
            if value ~= nil then
                util_table.set_nested_value(
                    this.monitor.frame_storage,
                    { "user_option", key },
                    value
                )
            end
        end)
    end

    util_table.set_nested_value(this.monitor.frame_storage, { "user_option", key }, new_value)
end

---@param bind ModBind<string, any, OptionCtxPath>
local function action_option_elem(bind)
    local manager_name = "option_elem"
    local is_triggered = this.monitor:is_triggered(manager_name, bind)
    local key = bind.bound_value.key
    local new_value = util_table.deep_copy(bind.bound_value.value)
    local is_hold = bind.action_type == mod.enum.action_type.SET_HOLD

    if is_triggered and is_hold then
        local current_hud = hud.get_current().key
        local opt = def.elem.get_opt(key)
        local ctx = hud.elements.get_element_ctx(bind.bound_value.free_value)

        if not ctx then
            return
        end

        ---@diagnostic disable-next-line: no-unknown
        local current_value =
            util_table.deep_copy(util_opt.get_elem_config_value(opt, ctx.elem_config))
        new_value = this.monitor:push_hold(manager_name, key, bind, new_value, current_value)

        this.monitor:register_on_release_callback(bind.name, function()
            local value = this.monitor:remove_hold(manager_name, key, bind)

            if hud.get_current().key ~= current_hud then
                return
            end

            if value ~= nil then
                util_table.set_nested_value(this.monitor.frame_storage, { "elem_option", key }, {
                    value = value,
                    ctx_path = bind.bound_value.free_value,
                })
            end
        end)
    end

    util_table.set_nested_value(this.monitor.frame_storage, { "elem_option", key }, {
        value = new_value,
        ctx_path = bind.bound_value.free_value,
    })
end

---@return boolean
function this.init()
    local bind_key = config.current.mod.bind.key

    this.option_hud = option_bind_manager:new("option_hud", action_option_hud)
    this.option_mod = option_bind_manager:new("option_mod", action_option_mod)
    this.option_game = option_bind_manager:new("option_game", action_option_game)
    this.option_user = option_bind_manager:new("option_user", action_option_user)
    this.option_elem = option_bind_manager:new("option_elem", action_option_elem)
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

    if not this.option_user:load(bind_key.option_user) then
        bind_key.option_user = this.option_user:get_base_binds()
    end

    if not this.option_elem:load(bind_key.option_elem) then
        bind_key.option_elem = this.option_elem:get_base_binds()
    end

    if not this.hud:load(bind_key.hud) then
        bind_key.hud = this.hud:get_base_binds()
    end

    ---@diagnostic disable-next-line: assign-type-mismatch
    this.monitor = bind_monitor:new(
        this.option_mod,
        this.hud,
        this.option_hud,
        this.option_game,
        this.option_user,
        this.option_elem
    )
    this.monitor:set_max_buffer_frame(bind_key.buffer)
    return true
end

return this
