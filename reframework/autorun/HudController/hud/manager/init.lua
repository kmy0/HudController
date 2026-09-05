---@class HudManager
---@field overridden_options TableProxy<string, boolean> --FIXME: DEPRECATED
---@field is_cleared boolean
---@field disable_condition_binds Timer

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

    local request = bind_condition.update(profile_switcher.current_hud)
    if not request then
        return
    end

    if not request.hud and request.profile then --TODO: refactor
        local target_key = profile_switcher.requested_hud and profile_switcher.requested_hud.profile
            or profile_switcher.current_hud.profile
        if target_key == request.profile then
            return
        end

        profile_switcher.request_hud_with_profiles(
            profile_switcher.current_hud.hud or profile_switcher.requested_hud.hud,
            request.profile
        )
    elseif not request.profile and request.hud then
        local target_key = profile_switcher.requested_hud and profile_switcher.requested_hud.hud.key
            or profile_switcher.current_hud.hud.key
        if target_key == request.hud.key then
            return
        end

        config_mod.combo.hud = util_table.index(config_mod.hud, function(o)
            return o.key == request.hud.key
        end) --[[@as integer]]
        profile_switcher.request_hud_with_default(request.hud)
    else
        local target_key_a = profile_switcher.requested_hud
                and profile_switcher.requested_hud.hud.key
            or profile_switcher.current_hud.hud.key
        local target_key_b = profile_switcher.requested_hud
                and profile_switcher.requested_hud.profile
            or profile_switcher.current_hud.profile

        if target_key_a == request.hud.key and target_key_b == request.profile then
            return
        end

        config_mod.combo.hud = util_table.index(config_mod.hud, function(o)
            return o.key == request.hud.key
        end) --[[@as integer]]
        profile_switcher.request_hud_with_profiles(request.hud, request.profile)
    end
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
