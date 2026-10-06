---@class ModBinds
---@field option_hud OptionModBindManager
---@field option_mod OptionModBindManager
---@field option_user OptionModBindManager
---@field hud HudModBindManager
---@field option_game OptionModBindManager
---@field option_elem OptionModBindManager
---@field condition HudModBindManager
---@field monitor ModBindMonitor
---@field any_invalid boolean

---@class (exact) ModBindBase : BindBase
---@field action_type BindActionType

---@class (exact) ModBind<K ,V, F> : Bind, ModBindBase
---@field bound_value {key: K, value: V, free_value: F}

---@class ModBindMonitor : BindMonitor
---@field frame_storage BindEvalResult

---@class (exact) BindEvalResult : ConditionEvalResult
---@field condition table<string, boolean>

local bind_monitor = require("HudController.util.game.bind.monitor")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local hud_bind_manager = require("HudController.hud.bind.key.hud_manager")
local option_bind_manager = require("HudController.hud.bind.key.option_manager")
local slot = require("HudController.hud.manager.bind_actions.slot")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.manager.bind_actions.held"
local held = util_misc.lazy_require("HudController.hud.manager.bind_actions.held")

local mod = data.mod

---@class ModBinds
local this = {}

---@param bind ModBind
---@return boolean
local function is_hold(bind)
    return bind.action_type == mod.enum.action_type.SET_HOLD
end

---@param name ManagerName
---@param key string
---@param value any
local function set_frame(name, key, value)
    slot.set(this.monitor.frame_storage, name, key, value)
end

---@param manager_name ManagerName
---@param key any
---@param bind ModBind
---@param value any
local function register_hold(manager_name, key, bind, value)
    local id = this.monitor:get_bind_key(bind)
    if not held.push_hold(manager_name, key, id, value) then
        return
    end

    this.monitor:register_on_release_callback(bind.name, function()
        local value = held.release_hold(manager_name, key, id)
        if value ~= nil then
            set_frame(manager_name, key, value)
        end
    end)
end

---@param manager_name ManagerName
---@param make_key (fun(bind: ModBind): any)?
---@param make_value (fun(bind: ModBind): any)?
---@return fun(bind: ModBind<string, any>)
local function make_option_action(manager_name, make_key, make_value)
    return function(bind)
        local key = make_key and make_key(bind) or bind.bound_value.key
        local value = make_value and make_value(bind)
            or util_table.deep_copy(bind.bound_value.value)

        if is_hold(bind) then
            if this.monitor:is_triggered(manager_name, bind) then
                register_hold(manager_name, key, bind, value)
            end
        end

        set_frame(manager_name, key, value)
    end
end

local action_option_hud = make_option_action("option_hud")
local action_option_mod = make_option_action("option_mod")
local action_option_game = make_option_action("option_game")
local action_option_user = make_option_action("option_user")
local action_option_elem = make_option_action("option_elem", nil, function(bind)
    return {
        ---@diagnostic disable-next-line: no-unknown
        value = util_table.deep_copy(bind.bound_value.value),
        ctx_path = bind.bound_value.free_value,
    }
end)

---@param bind ModBind<integer, integer>
local function action_hud(bind)
    local manager_name = "hud"
    local new_value = {
        key = bind.bound_value.key,
        profile = { bind.bound_value.value },
    }

    if is_hold(bind) and this.monitor:is_triggered(manager_name, bind) then
        register_hold(manager_name, manager_name, bind, new_value)
    end

    set_frame(manager_name, manager_name, new_value)
end

---@param bind ModBind
local function action_condition(bind)
    ---@diagnostic disable-next-line: param-type-mismatch
    set_frame("condition", bind.name, true)
end

---@return boolean
function this.check_invalid()
    for _, m in pairs(this.monitor.managers) do
        for _, b in pairs(m.manager.binds) do
            if b.invalid then
                this.any_invalid = true
                return true
            end
        end
    end

    this.any_invalid = false
    return false
end

---@return boolean
function this.init()
    local bind_key = config.current.mod.bind.key

    this.option_hud = option_bind_manager:new("option_hud", action_option_hud)
    this.option_mod = option_bind_manager:new("option_mod", action_option_mod)
    this.option_game = option_bind_manager:new("option_game", action_option_game)
    this.option_user = option_bind_manager:new("option_user", action_option_user)
    this.option_elem = option_bind_manager:new("option_elem", action_option_elem)
    this.condition = hud_bind_manager:new("condition", action_condition)
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

    if not this.condition:load(bind_key.condition) then
        bind_key.condition = this.condition:get_base_binds()
    end

    ---@diagnostic disable-next-line: assign-type-mismatch
    this.monitor = bind_monitor:new(
        this.option_mod,
        this.hud,
        this.option_hud,
        this.option_game,
        this.option_user,
        this.option_elem,
        this.condition
    )
    this.monitor:set_max_buffer_frame(bind_key.buffer)
    this.monitor.on_clear = function()
        held.release_all_holds()
    end

    this.check_invalid()
    return true
end

return this
