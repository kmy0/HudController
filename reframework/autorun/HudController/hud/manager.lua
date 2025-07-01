---@class HudManager
---@field by_hudid table<app.GUIHudDef.TYPE, HudBase>
---@field by_guiid table<app.GUIID.ID, HudBase>
---@field current_hud HudProfileConfig?
---@field requested_hud HudProfileConfig?
---@field notify boolean
---@field overridden_options table<string, boolean>

---@class (exact) FadeCallbacks
---@field switch_profile fun()
---@field finish fun()

local ace_misc = require("HudController.util.ace.misc")
local ace_player = require("HudController.util.ace.player")
local bind_manager = require("HudController.hud.bind")
local call_queue = require("HudController.hud.call_queue")
local config = require("HudController.config")
local data = require("HudController.data")
local factory = require("HudController.hud.factory")
local fade_manager = require("HudController.hud.fade")
local hud_base = require("HudController.hud.def.hud_base")
local hud_opt_default = require("HudController.hud.option_default")
local play_object = require("HudController.hud.play_object")
local timer = require("HudController.util.misc.timer")

local ace_enum = data.ace.enum
local ace_map = data.ace.map
local mod = data.mod

---@class HudManager
local this = {
    by_hudid = {},
    by_guiid = {},
    overridden_options = {},
}
---@class FadeCallbacks
local fade_callbacks = {}
local timer_key = "disable_weapon_binds"

function fade_callbacks.switch_profile()
    this.overridden_options = {}
    this.apply_options(this.requested_hud.options)
    this.update_elements(this.requested_hud.elements)
    this.current_hud = this.requested_hud
end

function fade_callbacks.finish()
    if this.notify and config.current.mod.enable_notification and this.current_hud.show_notification then
        ace_misc.send_message(
            string.format("%s %s", this.current_hud.name, config.lang.tr("misc.text_notification_message"))
        )
    end

    this.requested_hud = nil
    fade_manager.clear()
end

---@param elements table<string, HudBaseConfig>
function this.update_elements(elements)
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
function this.request_hud(new_hud)
    if
        this.current_hud
        and this.current_hud.key == new_hud.key
        and not fade_manager.is_active(fade_manager.type.fade_out)
    then
        return
    end

    this.notify = true
    this.requested_hud = new_hud

    if config.current.mod.enable_fade then
        if fade_manager.is_active(fade_manager.type.fade_out) and fade_manager.current_fade.hud_key == new_hud.key then
            this.notify = false
            fade_manager.fade_in(this.current_hud, fade_callbacks.finish)
        elseif
            this.current_hud
            and new_hud.fade_opacity
            and (not new_hud.fade_opacity_both or this.current_hud.fade_opacity)
        then
            fade_callbacks.switch_profile()
            fade_manager.fade_partial(this.current_hud, this.requested_hud, fade_callbacks.finish)
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

    local t = config.current.mod.bind.weapon[ace_misc.is_multiplayer() and "multiplayer" or "singleplayer"] --[[@as table<string, WeaponBindConfig>]]
    ---@type WeaponBindConfig
    local weapon_config

    if t["GLOBAL"].enabled then
        weapon_config = t["GLOBAL"]
    else
        local weapon_name = ace_enum.weapon[ace_player.get_master_weapon_type()]

        if not weapon_name then
            return
        end

        weapon_config = t[weapon_name]
    end

    local state_config = weapon_config[is_combat and "combat_in" or "combat_out"] --[[@as WeaponBindConfigData]]
    if weapon_config.enabled then
        local hud_config = config.current.mod.hud[state_config.combo]

        if
            state_config.hud_key ~= hud_config.key
            or (hud_config.key == this.current_hud.key and not this.requested_hud)
            or (this.requested_hud and hud_config.key == this.requested_hud.key)
        then
            return
        end

        config.current.mod.combo_hud = state_config.combo
        this.request_hud(hud_config)
        config.save()
    end
end

function this.update()
    if not config.current.mod.enabled or not mod.is_ok() then
        this.clear()
        return
    end

    if not this.current_hud and not this.requested_hud then
        local hud_config = config.current.mod.hud[config.current.mod.combo_hud]
        if hud_config then
            this.request_hud(hud_config)
        end
    end

    fade_manager.update()

    if config.current.mod.enable_key_binds then
        bind_manager.option_manager:monitor()

        if bind_manager.hud_manager:monitor() then
            timer.restart_key(timer_key)
        end
    end

    if config.current.mod.enable_weapon_binds and timer.check(timer_key, config.bind_timeout, nil, true) then
        this.update_weapon_bind_state()
    end
end

function this.clear()
    fade_manager.abort()

    this.by_guiid = {}
    this.reset_elements()
    this.by_hudid = {}
    this.overridden_options = {}

    this.current_hud = nil
    this.requested_hud = nil
end

---@return boolean
function this.init()
    hud_opt_default.init()
    play_object.default.init()
    bind_manager.init()

    for i = 1, #config.current.mod.hud do
        config.current.mod.hud[i] = factory.verify_hud(config.current.mod.hud[i])
        local hud = config.current.mod.hud[i]
        hud.elements = factory.verify_elements(hud.elements or {})
    end

    return true
end

return this
