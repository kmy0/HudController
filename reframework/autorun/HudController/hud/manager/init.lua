---@class HudManager
---@field overridden_options TableProxy<string, boolean> --FIXME: DEPRECATED
---@field is_cleared boolean
---@field disable_condition_binds Timer
---@field force_update boolean

local ace_misc = require("HudController.util.ace.misc")
local bind_condition = require("HudController.hud.bind_condition.init")
local bind_manager = require("HudController.hud.bind.init")
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
}

local function verify_elements()
    local config_mod = config.current.mod
    for i = 1, #config_mod.hud do
        config_mod.hud[i] = factory.verify_hud(config_mod.hud[i])
        local hud = config_mod.hud[i]
        hud.elements = factory.verify_elements(hud.elements or {})
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

    local force_update = this.force_update
    local target = profile_switcher.requested_hud or profile_switcher.current_hud --[[@as ModHud]]
    local target_hud = target.hud
    local target_profile = target.profile

    local requested_hud = request.hud
    local requested_profile = request.profile

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
