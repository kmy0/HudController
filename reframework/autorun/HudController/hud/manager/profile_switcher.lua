---@class ProfileSwitcher
---@field current_hud ModProfileConfig?
---@field requested_hud ModProfileConfig?
---@field notify boolean

local ace_misc = require("HudController.util.ace.misc")
local config = require("HudController.config.init")
local defaults = require("HudController.hud.defaults.init")
local elements = require("HudController.hud.manager.elements")
local fade_manager = require("HudController.hud.fade.init")
local util_misc = require("HudController.util.misc.init")
---@module "HudController.hud.manager.options"
local options = util_misc.lazy_require("HudController.hud.manager.options")
---@module "HudController.hud.hook.init"
local hook = util_misc.lazy_require("HudController.hud.hook.init")

---@class ProfileSwitcher
local this = {
    notify = true,
}

---@param hud_config ModProfileConfig
---@return table<app.GUIHudDef.TYPE, FadeDisableType>
local function make_disable_fade_args(hud_config)
    ---@type table<app.GUIHudDef.TYPE, FadeDisableType>
    local ret = {}
    for _, elem in pairs(hud_config.elements) do
        if elem.disable_fade then
            ret[elem.hud_id] = fade_manager.fade_disable_type.DISABLE
        elseif elem.disable_fade_opacity then
            ret[elem.hud_id] = fade_manager.fade_disable_type.DISABLE_OPACITY
        end
    end
    return ret
end

---@param hud_config ModProfileConfig
---@return table<app.GUIHudDef.TYPE, fun(fader: Fader)>
local function make_disable_fade_opacity_args(hud_config)
    ---@type table<app.GUIHudDef.TYPE, fun(fader: Fader)>
    local ret = {}
    for _, elem in pairs(hud_config.elements) do
        if elem.disable_fade_opacity then
            ret[elem.hud_id] = function(_)
                elements.add_element(elem)
            end
        end
    end
    return ret
end

local function switch_profile()
    defaults.play_object:with_dump(function()
        defaults.option:with_dump(function()
            options.clear()
            hook.hook_options(this.requested_hud)
            options.apply_option_many(this.requested_hud.options)
            elements.update_elements(this.requested_hud.elements)
            this.current_hud = this.requested_hud
        end)
    end)
end

local function switch_profile_partial()
    defaults.play_object:with_dump(function()
        defaults.option:with_dump(function()
            options.clear()
            hook.hook_options(this.requested_hud)
            options.apply_option_many(this.requested_hud.options)
            elements.update_elements_partial(this.requested_hud.elements)
            this.current_hud = this.requested_hud
        end)
    end)
end

local function finish()
    if
        this.notify
        and config.current.mod.enable_notification
        and this.current_hud.show_notification
    then
        ace_misc.send_message(
            string.format(
                "%s %s",
                this.current_hud.name,
                config.lang:tr("misc.text_notification_message")
            )
        )
    end

    this.requested_hud = nil
    fade_manager.clear()
end

---@param new_hud ModProfileConfig
---@param force boolean?
function this.request_hud_with_default(new_hud, force)
    for _, elem in pairs(new_hud.elements) do
        elem.current_profile = elem.default_profile
        elem.current_profile_gui = elem.default_profile
    end

    this.request_hud(new_hud, force)
end

---@param new_hud ModProfileConfig
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
        if
            fade_manager.is_active(fade_manager.type.fade_out)
            and fade_manager.current_fade.hud_key == new_hud.key
        then
            this.notify = false
            fade_manager.fade_in(this.current_hud, finish, make_disable_fade_args(this.current_hud))
        elseif
            this.current_hud
            and new_hud.fade_opacity
            and (not new_hud.fade_opacity_both or this.current_hud.fade_opacity)
        then
            local current_hud = this.current_hud
            ---@cast current_hud ModProfileConfig

            switch_profile_partial()
            fade_manager.fade_partial(current_hud, new_hud, function()
                elements.update_elements(this.current_hud.elements)
                finish()
            end, make_disable_fade_args(new_hud), make_disable_fade_opacity_args(
                new_hud
            ))
        elseif this.current_hud then
            if fade_manager.is_active(fade_manager.type.fade_out) then
                fade_manager.clear()
            end

            fade_manager.fade_out(this.current_hud, function()
                switch_profile()
                fade_manager.fade_in(
                    this.requested_hud,
                    finish,
                    make_disable_fade_args(this.requested_hud)
                )
            end, make_disable_fade_args(this.current_hud))
        else
            switch_profile()
            finish()
        end
    else
        switch_profile()
        finish()
    end
end

function this.clear()
    this.current_hud = nil
    this.requested_hud = nil
end

return this
