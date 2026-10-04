---@class HudManager
---@field is_cleared boolean
---@field disable_condition_binds Timer
---@field force_update boolean

local ace_misc = require("HudController.util.ace.misc")
local bind_actions = require("HudController.hud.manager.bind_actions")
local bind_condition = require("HudController.hud.bind.condition.init")
local bind_manager = require("HudController.hud.bind.key.init")
local cache = require("HudController.util.misc.cache")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local defaults = require("HudController.hud.defaults.init")
local elements = require("HudController.hud.manager.elements")
local fade_manager = require("HudController.hud.fade.init")
local options = require("HudController.hud.manager.options")
local profile_switcher = require("HudController.hud.manager.profile_switcher")
local timer = require("HudController.util.misc.timer")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.manager.op.init"
local op = util_misc.lazy_require("HudController.hud.manager.op.init")

local mod = data.mod

---@class HudManager
local this = {
    is_cleared = true,
    disable_condition_binds = timer:new(0),
    force_update = false,
}

---@return boolean is_held
---@return BindEvalResult
local function update_key_binds()
    local config_mod = config.current.mod
    bind_manager.monitor:monitor()

    if bind_manager.monitor:is_triggered("hud") and config_mod.disable_condition_binds_time > 0 then
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

    if config_mod.disable_condition_binds_time == 0 and not is_held then
        this.disable_condition_binds:abort()
    end

    return is_held, bind_manager.monitor.frame_storage
end

---@return ConditionEvalResult?
local function update_requests()
    local config_mod = config.current.mod
    local is_held = false
    ---@type BindEvalResult?
    local key_requests

    if config_mod.enable_key_binds then
        is_held, key_requests = update_key_binds()
    end

    if key_requests and util_table.empty(key_requests) then
        key_requests = nil
    end

    if
        not config_mod.enable_condition_binds
        or this.disable_condition_binds:active()
        or is_held
    then
        if
            config_mod.bind.condition.highlight_pass_rule and config.gui.current.gui.main.is_opened
        then
            bind_condition.eval_rules()
        end

        return key_requests
    end

    local cond_requests = bind_condition.update(profile_switcher.current_hud, this.force_update)
    if not cond_requests then
        return key_requests
    end

    if key_requests and cond_requests then
        return bind_actions.merge_requests(key_requests, cond_requests)
    end

    return cond_requests
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

    local requests = update_requests()
    if not requests then
        return
    end

    bind_actions.apply_requests(requests)

    if not requests.hud then
        return
    end

    local force_update = this.force_update
    local target = profile_switcher.requested_hud or profile_switcher.current_hud --[[@as ModHud]]
    local requested_profile = requests.hud.profile
    local profile_matches = not requested_profile
        or util_table.equal(target.profile_bits, requested_profile)

    local requested_index = util_table.index(config_mod.hud, function(hud)
        return hud.key == requests.hud.key
    end)

    if requested_index then
        local requested_hud = config_mod.hud[requested_index]

        if target.hud.key == requested_hud.key and profile_matches and not force_update then
            return
        end

        config_mod.combo.hud = requested_index

        if requested_profile then
            profile_switcher.request_hud_with_profiles(
                requested_hud,
                requested_profile,
                force_update
            )
        else
            profile_switcher.request_hud_with_default(requested_hud, force_update)
        end
    elseif requested_profile then
        if profile_matches and not force_update then
            return
        end

        profile_switcher.request_hud_with_profiles(target.hud, requested_profile, force_update)
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
    bind_actions.clear()
end

function this.init()
    defaults.play_object:init()
    defaults.option:init()

    op.user.verify_options()

    op.user.merge_mod_user_settings()
    op.hud_profile.verify_elements()

    bind_manager.init()
    op.bind.verify_binds()

    return true
end

return this
