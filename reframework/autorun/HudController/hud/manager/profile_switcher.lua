---@class (exact) ModHud
---@field hud ModProfileConfig
---@field profile integer
---@field profile_changed table<string, {from: HudBaseConfigProfile, to: HudBaseConfigProfile}>

---@class ProfileSwitcher
---@field current_hud ModHud?
---@field requested_hud ModHud?
---@field notify boolean

local ace_misc = require("HudController.util.ace.misc")
local config = require("HudController.config.init")
local defaults = require("HudController.hud.defaults.init")
local elements = require("HudController.hud.manager.elements")
local fade_manager = require("HudController.hud.fade.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")
---@module "HudController.hud.manager.options"
local options = util_misc.lazy_require("HudController.hud.manager.options")
---@module "HudController.hud.hook.init"
local hook = util_misc.lazy_require("HudController.hud.hook.init")
---@module "HudController.hud.manager.operations"
local operations = util_misc.lazy_require("HudController.hud.manager.operations")

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

---@param hud_config ModProfileConfig
---@return integer
local function make_profile_bit(hud_config)
    ---@type table<integer, boolean>
    local profiles = {}
    for _, elem in pairs(hud_config.elements) do
        profiles[elem.current_profile] = true
    end

    return util_misc.pack_bits(util_table.keys(profiles))
end

local function switch_profile()
    defaults.play_object:with_dump(function()
        defaults.option:with_dump(function()
            options.clear()
            hook.hook_options(this.requested_hud.hud)
            options.apply_option_many(this.requested_hud.hud.options)
            elements.update_elements(this.requested_hud.hud.elements)
            this.current_hud = this.requested_hud
        end)
    end)
end

local function switch_profile_partial()
    defaults.play_object:with_dump(function()
        defaults.option:with_dump(function()
            options.clear()
            hook.hook_options(this.requested_hud.hud)
            options.apply_option_many(this.requested_hud.hud.options)
            elements.update_elements_partial(this.requested_hud.hud.elements)
            this.current_hud = this.requested_hud
        end)
    end)
end

local function finish()
    if
        this.notify
        and config.current.mod.enable_notification
        and this.current_hud.hud.show_notification
    then
        ace_misc.send_message(
            string.format(
                "%s %s",
                this.current_hud.hud.name,
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
    ---@type table<string, {from: HudBaseConfigProfile, to: HudBaseConfigProfile}>
    local profile_changed = {}
    for _, elem in pairs(new_hud.elements) do
        if elem.current_profile ~= elem.default_profile then
            profile_changed[elem.name_key] = {
                from = elem.profile[operations.get_elem_profile_key(elem.current_profile)],
                to = elem.profile[operations.get_elem_profile_key(elem.default_profile)],
            }
        end

        elem.current_profile = elem.default_profile
        elem.current_profile_gui = elem.default_profile
    end

    local profile_bit = make_profile_bit(new_hud)
    this.request_hud(
        { hud = new_hud, profile = profile_bit, profile_changed = profile_changed },
        force
    )
end

---@param new_hud ModProfileConfig
---@param profile_bit integer
---@param force boolean?
function this.request_hud_with_profiles(new_hud, profile_bit, force)
    ---@type table<string, {from: HudBaseConfigProfile, to: HudBaseConfigProfile}>
    local profile_changed = {}
    local profiles = util_misc.unpack_bits(profile_bit)
    ---@type table<integer, integer>
    local order = {}
    for i, p in ipairs(new_hud.profile) do
        order[p.key] = i
    end

    table.sort(profiles, function(a, b)
        return order[a] < order[b]
    end)

    for _, elem in pairs(new_hud.elements) do
        ---@type integer
        local new_profile
        local current_profile = elem.current_profile
        for _, p in ipairs(profiles) do
            local key = operations.get_elem_profile_key(p)
            local profile = elem.profile[key]
            if profile and profile.enabled then
                new_profile = p
                break
            end
        end

        if not new_profile then
            new_profile = elem.default_profile
        end

        if new_profile ~= current_profile then
            profile_changed[elem.name_key] = {
                from = elem.profile[operations.get_elem_profile_key(current_profile)],
                to = elem.profile[operations.get_elem_profile_key(new_profile)],
            }
        end

        elem.current_profile = new_profile
        elem.current_profile_gui = new_profile
    end

    this.request_hud(
        { hud = new_hud, profile = profile_bit, profile_changed = profile_changed },
        force
    )
end

---@param new_hud ModHud
---@param force boolean?
function this.request_hud(new_hud, force)
    if
        not force
        and this.current_hud
        and this.current_hud.hud.key == new_hud.hud.key
        and this.current_hud.hud.profile == new_hud.profile
        and not fade_manager.is_active(fade_manager.type.fade_out)
    then
        return
    end

    this.notify = true
    this.requested_hud = new_hud

    if
        config.current.mod.enable_fade
        and (new_hud.hud.fade_in > 0 or (this.current_hud and this.current_hud.hud.fade_out > 0))
    then
        if
            fade_manager.is_active(fade_manager.type.fade_out)
            and fade_manager.current_fade.hud_key == new_hud.hud.key
        then
            this.notify = false
            fade_manager.fade_in(
                this.current_hud.hud,
                finish,
                make_disable_fade_args(this.current_hud.hud)
            )
        elseif
            this.current_hud
            and new_hud.hud.fade_opacity
            and (not new_hud.hud.fade_opacity_both or this.current_hud.hud.fade_opacity)
        then
            local current_hud = this.current_hud.hud
            ---@cast current_hud ModProfileConfig

            switch_profile_partial()
            fade_manager.fade_partial(current_hud, new_hud.hud, function()
                elements.update_elements(this.current_hud.hud.elements)
                finish()
            end, make_disable_fade_args(new_hud.hud), make_disable_fade_opacity_args(
                new_hud.hud
            ))
        elseif this.current_hud then
            if fade_manager.is_active(fade_manager.type.fade_out) then
                fade_manager.clear()
            end

            fade_manager.fade_out(this.current_hud.hud, function()
                switch_profile()
                fade_manager.fade_in(
                    this.requested_hud.hud,
                    finish,
                    make_disable_fade_args(this.requested_hud.hud)
                )
            end, make_disable_fade_args(this.current_hud.hud))
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
