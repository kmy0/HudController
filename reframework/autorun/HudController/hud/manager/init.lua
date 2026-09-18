---@class HudManager
---@field overridden_options TableProxy<string, boolean> --FIXME: DEPRECATED
---@field is_cleared boolean
---@field disable_condition_binds Timer
---@field force_update boolean
---@field condition_options table<string, table<string, any>>

local ace_misc = require("HudController.util.ace.misc")
local bind_condition = require("HudController.hud.bind.condition.init")
local bind_manager = require("HudController.hud.bind.key.init")
local cache = require("HudController.util.misc.cache")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local defaults = require("HudController.hud.defaults.init")
local elements = require("HudController.hud.manager.elements")
local factory = require("HudController.hud.factory")
local fade_manager = require("HudController.hud.fade.init")
local options = require("HudController.hud.manager.options")
local profile_switcher = require("HudController.hud.manager.profile_switcher")
local timer = require("HudController.util.misc.timer")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

---@class HudManager
local this = {
    is_cleared = true,
    overridden_options = options.overridden_options, --FIXME: DEPRECATED
    disable_condition_binds = timer:new(0),
    force_update = false,
    condition_options = {},
    condition_option_handlers = {
        hud_option = {
            apply = function(key, value)
                value = value == mod.enum.expected_result.TRUE and true or false
                options.overwrite_hud_option(key, value)
            end,
            remove = function(_, _) end,
        },
        mod_option = {
            apply = function(key, value)
                value = value == mod.enum.expected_result.TRUE and true or false
                ---@diagnostic disable-next-line: no-unknown
                config.current.mod[key] = value
            end,
            remove = function() end,
        },
        game_option = {
            apply = function(key, value)
                options.apply_option(key, value)
            end,
            remove = function() end,
        },
    },
}

local function verify_elements()
    local config_mod = config.current.mod
    for i = 1, #config_mod.hud do
        config_mod.hud[i] = factory.verify_hud(config_mod.hud[i])
        local hud = config_mod.hud[i]
        hud.elements = factory.verify_elements(hud.elements or {})
    end
end

---@param request ConditionEvalRet
---@param clear boolean?
local function update_condition_options(request, clear)
    for name, handler in pairs(this.condition_option_handlers) do
        local current = request[name] or {} --[[@as table<string, any>]]
        local previous = this.condition_options[name] or {}

        if handler.remove then
            for key, value in pairs(previous) do
                if clear or current[key] == nil then
                    handler.remove(key, value)
                end
            end
        end

        for key, value in pairs(current) do
            handler.apply(key, value)
        end

        this.condition_options[name] = current
    end
end

---@return boolean is_held
local function update_key_binds(config_mod)
    bind_manager.monitor:monitor()

    if bind_manager.monitor:is_triggered("hud") and config_mod.disable_condition_binds_timed then
        if config_mod.disable_condition_binds_held then
            bind_manager.monitor:register_on_release_callback(
                bind_manager.monitor:get_held_key_names("hud"),
                function()
                    this.disable_condition_binds:restart()
                end
            )
        else
            this.disable_condition_binds:restart()
        end
    end

    local is_held = config_mod.enable_condition_binds
        and config_mod.disable_condition_binds_held
        and bind_manager.monitor:is_held("hud")

    if not config_mod.disable_condition_binds_timed and not is_held then
        this.disable_condition_binds:abort()
    end

    return is_held
end

function this.request_update()
    this.force_update = true
end

---@param profile_key integer
---@return boolean
function this.is_profile_selected(elem_key, profile_key)
    return profile_switcher.current_hud.profile[elem_key] == profile_key
end

function this.update()
    local config_mod = config.current.mod

    if not config_mod.enabled or not mod.is_ok() then
        if not this.is_cleared then
            this.clear()
        end

        return
    end

    this.is_cleared = false

    if not profile_switcher.current_hud and not profile_switcher.requested_hud then
        local hud_config = config_mod.hud[config_mod.combo.hud]
        if hud_config then
            profile_switcher.request_hud_with_default(hud_config)
        end
    end

    fade_manager.update()
    if mod.pause or config_mod.canvas.draw then
        return
    end

    this.disable_condition_binds:update_args({ timeout = config_mod.disable_condition_binds_time })

    local is_held = config_mod.enable_key_binds and update_key_binds(config_mod)

    if
        not config_mod.enable_condition_binds
        or this.disable_condition_binds:active()
        or is_held
    then
        if config_mod.bind.condition.highlight_pass and config.gui.current.gui.main.is_opened then
            bind_condition.update_conditions_only()
        end

        return
    end

    local request = bind_condition.update(profile_switcher.current_hud, this.force_update)
    if not request then
        return
    end

    update_condition_options(request)

    if not request.hud then
        return
    end

    local force_update = this.force_update
    local target = profile_switcher.requested_hud or profile_switcher.current_hud --[[@as ModHud]]
    local target_hud = target.hud
    local target_profile = target.profile

    local requested_hud = util_table.find_value(config.current.mod.hud, function(_, value)
        return value.key == request.hud.key
    end)
    local requested_profile = request.hud.profile

    if requested_hud and requested_profile then
        if
            target_hud.key == requested_hud.key
            and target_profile == requested_profile
            and not force_update
        then
            return
        end

        config_mod.combo.hud = util_table.index(config_mod.hud, function(o)
            return o.key == requested_hud.key
        end) --[[@as integer]]

        profile_switcher.request_hud_with_profiles(requested_hud, requested_profile, force_update)
    elseif requested_hud then
        if target_hud.key == requested_hud.key and not force_update then
            return
        end

        config_mod.combo.hud = util_table.index(config_mod.hud, function(o)
            return o.key == requested_hud.key
        end) --[[@as integer]]

        profile_switcher.request_hud_with_default(requested_hud, force_update)
    elseif requested_profile then
        if target_profile == requested_profile and not force_update then
            return
        end

        profile_switcher.request_hud_with_profiles(target_hud, requested_profile, force_update)
    end

    this.force_update = false
end

function this.clear()
    if not data.mod.initialized then
        return
    end

    fade_manager.abort()

    if not ace_misc.is_title_request() then
        elements.reset_elements()
    end

    elements.clear()
    options.clear()
    bind_condition.reset()
    profile_switcher.clear()

    cache.clear_all()
    this.is_cleared = true
    this.force_update = false
    this.condition_options = {}
end

function this.init()
    defaults.play_object:init()
    defaults.option:init()
    bind_manager.init()
    verify_elements()
    return true
end

function this.reinit()
    bind_manager.init()
    verify_elements()
end

return this
