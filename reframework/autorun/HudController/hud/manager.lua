---@class HudManager
---@field by_hudid table<app.GUIHudDef.TYPE, HudBase>
---@field by_guiid table<app.GUIID.ID, HudBase>
---@field current_hud HudProfileConfig?
---@field requested_hud HudProfileConfig?
---@field notify boolean
---@field overridden_options table<string, boolean>
---@field overridden_options_func table<string, fun(key: string, value: boolean)>
---@field combat_state_frame boolean
---@field combat_state boolean

---@class (exact) FadeCallbacks
---@field switch_profile fun()
---@field switch_profile_partial fun()
---@field finish fun()

local ace_misc = require("HudController.util.ace.misc")
local ace_player = require("HudController.util.ace.player")
local ace_porter = require("HudController.util.ace.porter")
local bind_manager = require("HudController.hud.bind")
local cache = require("HudController.util.misc.cache")
local call_queue = require("HudController.hud.call_queue")
local config = require("HudController.config")
local data = require("HudController.data")
local defaults = require("HudController.hud.defaults")
local factory = require("HudController.hud.factory")
local fade_manager = require("HudController.hud.fade")
local hud_base = require("HudController.hud.def.hud_base")
local m = require("HudController.util.ref.methods")
local s = require("HudController.util.ref.singletons")
local timer = require("HudController.util.misc.timer")

local ace_enum = data.ace.enum
local ace_map = data.ace.map
local mod = data.mod

---@class HudManager
local this = {
    by_hudid = {},
    by_guiid = {},
    overridden_options = {},
    overridden_options_func = {},
}
---@class FadeCallbacks
local fade_callbacks = {}
local timer_key = "disable_weapon_binds"
local out_of_combat_delay_key = "out_of_combat_delay"
local in_combat_delay_key = "in_combat_delay"

---@param key string
---@param value boolean
local function override_scar_option(key, value)
    if value then
        local t = { "hide_scar", "show_scar", "disable_scar" }
        for _, k in pairs(t) do
            if k ~= key then
                this.overridden_options[k] = false
            end
        end
    end
end

function fade_callbacks.switch_profile()
    defaults.with_dump(function()
        this.overridden_options = {}
        this.apply_options(this.requested_hud.options)
        this.update_elements(this.requested_hud.elements)
        this.current_hud = this.requested_hud
    end)
end

function fade_callbacks.switch_profile_partial()
    defaults.with_dump(function()
        this.overridden_options = {}
        this.apply_options(this.requested_hud.options)
        this._update_elements_partial(this.requested_hud.elements)
        this.current_hud = this.requested_hud
    end)
end

function fade_callbacks.finish()
    if this.notify and config.current.mod.enable_notification and this.current_hud.show_notification then
        ace_misc.send_message(
            string.format("%s %s", this.current_hud.name, config.lang:tr("misc.text_notification_message"))
        )
    end

    this.requested_hud = nil
    fade_manager.clear()
end

---@param elements table<string, HudBaseConfig>
function this.update_elements(elements, visible_only)
    this.by_guiid = {}

    for _, elem in pairs(this.by_hudid) do
        call_queue.queue_func(elem.hud_id, function()
            elem:reset()
        end)
    end

    this.by_hudid = {}
    for _, elem in pairs(elements) do
        this.by_hudid[elem.hud_id] = factory.new_elem(elem)

        for _, gui_id in pairs(ace_map.hudid_to_guiid[elem.hud_id]) do
            this.by_guiid[gui_id] = this.by_hudid[elem.hud_id]
        end
    end
end

---@protected
---@param elements table<string, HudBaseConfig>
function this._update_elements_partial(elements)
    this.by_guiid = {}

    for _, elem in pairs(this.by_hudid) do
        if not elements[elem.name_key] or (not elem.hide and not elem.opacity == 0) then
            call_queue.queue_func(elem.hud_id, function()
                elem:reset()
            end)
        end
    end

    this.by_hudid = {}
    for _, elem in pairs(elements) do
        if not elem.hide and (not elem.enabled_opacity or elem.opacity > 0) then
            this.by_hudid[elem.hud_id] = factory.new_elem(elem)

            for _, gui_id in pairs(ace_map.hudid_to_guiid[elem.hud_id]) do
                this.by_guiid[gui_id] = this.by_hudid[elem.hud_id]
            end
        end
    end
end

function this.reset_elements()
    for _, elem in pairs(this.by_hudid) do
        elem:reset()
    end
end

---@param option_name string
---@param option_value integer
function this.apply_option(option_name, option_value)
    hud_base.apply_option(option_name, option_value)
end

---@param options table<string, integer>
function this.apply_options(options)
    for option, value in pairs(options) do
        this.apply_option(option, value)
    end
end

---@param new_hud HudProfileConfig
---@param force boolean?
function this.request_hud(new_hud, force)
    if
        not force
        and this.current_hud
        and this.current_hud.key == new_hud.key
        and not fade_manager.is_active(fade_manager.type.fade_out)
    then
        return
    end

    this.notify = true
    this.requested_hud = new_hud

    if
        config.current.mod.enable_fade
        and (new_hud.fade_in > 0 or (this.current_hud and this.current_hud.fade_out > 0))
    then
        if fade_manager.is_active(fade_manager.type.fade_out) and fade_manager.current_fade.hud_key == new_hud.key then
            this.notify = false
            fade_manager.fade_in(this.current_hud, fade_callbacks.finish)
        elseif
            this.current_hud
            and new_hud.fade_opacity
            and (not new_hud.fade_opacity_both or this.current_hud.fade_opacity)
        then
            fade_callbacks.switch_profile_partial()
            fade_manager.fade_partial(this.current_hud, this.requested_hud, function()
                this.update_elements(this.current_hud.elements)
                fade_callbacks.finish()
            end)
        elseif this.current_hud then
            if fade_manager.is_active(fade_manager.type.fade_out) then
                fade_manager.clear()
            end

            fade_manager.fade_out(this.current_hud, function()
                fade_callbacks.switch_profile()
                fade_manager.fade_in(this.requested_hud, fade_callbacks.finish)
            end)
        else
            fade_callbacks.switch_profile()
            fade_callbacks.finish()
        end
    else
        fade_callbacks.switch_profile()
        fade_callbacks.finish()
    end
end

function this.update_weapon_bind_state()
    local is_combat = ace_player.is_combat()

    if is_combat == nil then
        return
    end

    local config_mod = config.current.mod
    local bind_weapon = config_mod.bind.weapon
    local in_quest = bind_weapon.quest_in_combat and s.get("app.MissionManager"):get_QuestDirector():isPlayingQuest()
    local is_riding = bind_weapon.ride_ignore_combat and ace_porter.is_master_riding()
    local is_village = ace_player.is_in_village()

    if not in_quest and not is_village then
        if this.combat_state_frame and not is_combat and this.combat_state then
            timer.new(out_of_combat_delay_key, bind_weapon.out_of_combat_delay, nil)
        elseif not this.combat_state_frame and is_combat and not this.combat_state then
            timer.new(in_combat_delay_key, bind_weapon.in_combat_delay, nil)
        end

        if not is_combat and timer.remaining_key(in_combat_delay_key) > 0 then
            timer.reset_key(in_combat_delay_key)
        elseif is_combat and timer.remaining_key(out_of_combat_delay_key) > 0 then
            timer.reset_key(out_of_combat_delay_key)
        end

        if
            timer.check(in_combat_delay_key, bind_weapon.in_combat_delay, nil, true)
            and timer.check(out_of_combat_delay_key, bind_weapon.out_of_combat_delay, nil, true)
        then
            if is_riding and is_combat and not this.combat_state then
                this.combat_state = false
            else
                this.combat_state = is_combat
            end
        end
    elseif is_village then
        this.combat_state = false
        timer.reset_key(in_combat_delay_key)
        timer.reset_key(out_of_combat_delay_key)
    elseif in_quest then
        this.combat_state = true
        timer.reset_key(in_combat_delay_key)
        timer.reset_key(out_of_combat_delay_key)
    end

    this.combat_state_frame = is_combat

    local t = bind_weapon[ace_misc.is_multiplayer() and "multiplayer" or "singleplayer"] --[[@as table<string, WeaponBindConfig>]]
    ---@type WeaponBindConfig
    local weapon_config

    if t["GLOBAL"].enabled then
        weapon_config = t["GLOBAL"]
    else
        local weapon_type = ace_player.get_weapon_type()
        local weapon_name = ace_enum.weapon[weapon_type]

        if not weapon_name then
            return
        end

        weapon_config = t[weapon_name]
        if not weapon_config.enabled then
            if not t["MELEE"].enabled and not t["RANGED"].enabled then
                return
            end

            if m.isGunnerWeapon(weapon_type) then
                weapon_config = t["RANGED"]
            else
                weapon_config = t["MELEE"]
            end
        end
    end

    if weapon_config.enabled then
        local state_config = weapon_config[is_village and "camp" or (this.combat_state and "combat_in" or "combat_out")] --[[@as WeaponBindConfigData]]
        local hud_config = config_mod.hud[state_config.combo]

        if
            state_config.hud_key ~= hud_config.key
            or (hud_config.key == this.current_hud.key and not this.requested_hud)
            or (this.requested_hud and hud_config.key == this.requested_hud.key)
        then
            return
        end

        config_mod.combo.hud = state_config.combo
        this.request_hud(hud_config)
        config.save_global()
    end
end

function this.update()
    local config_mod = config.current.mod
    if not config_mod.enabled or not mod.is_ok() then
        this.clear()
        return
    end

    if not this.current_hud and not this.requested_hud then
        local hud_config = config_mod.hud[config_mod.combo.hud]
        if hud_config then
            this.request_hud(hud_config)
        end
    end

    fade_manager.update()

    if mod.pause then
        return
    end

    local is_held = false
    if config_mod.enable_key_binds then
        bind_manager.monitor:monitor()

        if bind_manager.monitor:is_triggered("hud") and config_mod.disable_weapon_binds_timed then
            if config_mod.disable_weapon_binds_held then
                bind_manager.monitor:register_on_release_callback(
                    bind_manager.monitor:get_held_key_names("hud"),
                    function()
                        timer.restart_key(timer_key)
                    end
                )
            else
                timer.restart_key(timer_key)
            end
        end

        if config_mod.enable_weapon_binds and config_mod.disable_weapon_binds_held then
            is_held = bind_manager.monitor:is_held("hud")
        end

        if not config_mod.disable_weapon_binds_timed and (not config_mod.disable_weapon_binds_held or not is_held) then
            timer.reset_key(timer_key)
        end
    end

    if
        config_mod.enable_weapon_binds
        and timer.check(timer_key, config_mod.disable_weapon_binds_time, nil, true)
        and (not config_mod.disable_weapon_binds_held or not is_held)
    then
        this.update_weapon_bind_state()
    end
end

function this.clear()
    if not data.mod.initialized then
        return
    end

    fade_manager.abort()

    this.by_guiid = {}
    this.reset_elements()
    this.by_hudid = {}
    this.overridden_options = {}
    this.combat_state_frame = false
    this.combat_state = false

    this.current_hud = nil
    this.requested_hud = nil

    cache.clear_all()
end

---@return boolean
function this.init()
    defaults.init()
    this.reinit()

    return true
end

function this.reinit()
    bind_manager.init()

    local config_mod = config.current.mod
    for i = 1, #config_mod.hud do
        config_mod.hud[i] = factory.verify_hud(config_mod.hud[i])
        local hud = config_mod.hud[i]
        hud.elements = factory.verify_elements(hud.elements or {})
    end
end

this.overridden_options_func["hide_scar"] = override_scar_option
this.overridden_options_func["show_scar"] = override_scar_option
this.overridden_options_func["disable_scar"] = override_scar_option

return this
