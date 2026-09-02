---@class (exact) ModHud
---@field hud ModProfileConfig
---@field profile table<string, integer>
---@field profile_bits integer[]
---@field profile_to table<string, HudBaseConfigProfile>

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
local e = require("HudController.util.game.enum")
local play_object = require("HudController.hud.play_object.init")

---@class ProfileSwitcher
local this = {
    notify = true,
}

---@param update_elements boolean?
local function switch_profile(update_elements)
    update_elements = update_elements == nil or update_elements

    defaults.play_object:with_dump(function()
        defaults.option:with_dump(function()
            local hud = this.requested_hud.hud
            options.clear()
            hook.hook_options(hud)
            options.apply_option_many(hud.options)

            if update_elements then
                elements.update_elements(hud.elements)
            end

            this.current_hud = this.requested_hud
        end)
    end)
end

local function try_add_element(hud_config, hud_id)
    local hud_name = e.get("app.GUIHudDef.TYPE")[hud_id]
    local elem = hud_config.elements[hud_name]
    if elem then
        defaults.play_object:with_dump(function()
            defaults.option:with_dump(function()
                elements.add_element(elem)
            end)
        end)
    else
        elements.remove_element(hud_id)
    end
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

    elements.cleanup(this.current_hud.hud.elements)
    this.requested_hud = nil
    fade_manager.clear()
end

---@param new_hud ModProfileConfig
---@param force boolean?
function this.request_hud_with_default(new_hud, force)
    ---@type table<string, HudBaseConfigProfile>
    local profile_to = {}
    ---@type table<string, integer>
    local profile = {}
    for _, elem in pairs(new_hud.elements) do
        if elem.current_profile ~= elem.default_profile then
            profile_to[elem.name_key] =
                elem.profile[operations.get_elem_profile_key(elem.default_profile)]
        end

        elem.current_profile = elem.default_profile
        elem.current_profile_gui = elem.default_profile
        profile[elem.name_key] = elem.default_profile
    end

    this.request_hud({
        hud = new_hud,
        profile = profile,
        profile_to = profile_to,
        profile_bits = { 0 },
    }, force)
end

---@param new_hud ModProfileConfig
---@param profile_bits integer[]
---@param force boolean?
function this.request_hud_with_profiles(new_hud, profile_bits, force)
    ---@type table<integer, integer>
    local profile_order = {}
    for index, profile_config in ipairs(new_hud.profile) do
        profile_order[profile_config.key] = index
    end

    ---@type table<string, HudBaseConfigProfile>
    local changed_profiles = {}
    ---@type integer[][]
    local sorted_profile_bits = {}
    ---@type table<string, integer>
    local active_profiles = {}

    for _, packed_bits in ipairs(profile_bits) do
        local unpacked_bits = util_misc.unpack_bits(packed_bits)

        table.sort(unpacked_bits, function(a, b)
            return profile_order[a] > profile_order[b]
        end)

        table.insert(sorted_profile_bits, unpacked_bits)
    end

    local function get_new_profile(element)
        for _, trigger_profiles in ipairs(sorted_profile_bits) do
            for _, profile_id in ipairs(trigger_profiles) do
                local profile_key = operations.get_elem_profile_key(profile_id)
                local profile_config = element.profile[profile_key]

                if profile_config and profile_config.enabled then
                    return profile_id
                end
            end
        end
    end

    for _, element in pairs(new_hud.elements) do
        local profile_id = get_new_profile(element)
        if not profile_id then
            profile_id = element.default_profile
        end

        local profile_key = operations.get_elem_profile_key(profile_id)
        changed_profiles[element.name_key] = element.profile[profile_key]
        active_profiles[element.name_key] = profile_id
        element.current_profile = profile_id
    end

    this.request_hud({
        hud = new_hud,
        profile = active_profiles,
        profile_to = changed_profiles,
        profile_bits = profile_bits,
    }, force)
end

---@param a ModHud?
---@param b ModHud?
---@return boolean
local function is_same_hud(a, b)
    return a and b and a.hud.key == b.hud.key and util_table.equal(a.profile, b.profile) or false
end

---@param new_hud ModHud
---@return boolean
local function should_ignore_request(new_hud)
    if this.requested_hud then
        return is_same_hud(this.requested_hud, new_hud)
    end

    return is_same_hud(this.current_hud, new_hud)
end

---@param new_hud ModHud
---@return boolean
local function should_fade(new_hud)
    if not config.current.mod.enable_fade or not this.current_hud then
        return false
    end

    return this.current_hud.hud.fade_out > 0 or new_hud.hud.fade_in > 0
end

---@param fader Fader?
---@param current ModHud
---@param requested ModHud
---@return boolean
local function can_continue_fade_in(fader, current, requested)
    return fader ~= nil
        --[[ only continue from the first stage, not an already started second-stage fade in ]]
        and fader:get_level() == 1
        --[[ disable opacity fades cannot be continued ]]
        and not fader.free_value
        --[[
            normal full fades can continue while they are fading out
            partial fades only have one level and fade directly to the target opacity,
            so free_value2 marks them as a partial fade that can also be continued
        ]]
        and (fader:is_fade_out() or fader.free_value2)
        --[[ only continue when returning to the same profile, e.g. a -> b -> a, not a -> b -> c ]]
        and is_same_hud(current, requested)
end

---@param hud_id app.GUIHudDef.TYPE
---@param ctrls via.gui.Control[]
---@param disable_fade FadeDisableType
---@return Fader
local function make_elem_fader(hud_id, ctrls, disable_fade)
    local current = this.current_hud --[[@as ModHud]]
    local requested = this.requested_hud --[[@as ModHud]]
    local fade_opacity = requested.hud.fade_opacity
    local disable_opacity = disable_fade == fade_manager.disable_type.DISABLE_OPACITY
    local active_fader = fade_manager.get_fader(hud_id)
    local can_continue = can_continue_fade_in(active_fader, current, requested)

    if not fade_opacity or disable_opacity then
        if can_continue then
            return fade_manager.make_fader(
                hud_id,
                ctrls,
                fade_manager.get_hud_opacity(requested, hud_id),
                requested.hud.fade_in,
                {
                    on_finish = function(_)
                        try_add_element(requested.hud, hud_id)
                    end,
                }
            )
        end

        ---@type number | {fade_in: number, fade_out: number}
        local duration = current.hud.fade_out
        if disable_opacity then
            duration =
                { fade_in = requested.hud.fade_in / 2, fade_out = requested.hud.fade_out / 2 }
        end

        return fade_manager.make_fader(hud_id, ctrls, 0, duration, {
            on_finish = function(s)
                duration = requested.hud.fade_in
                if disable_opacity then
                    duration = requested.hud.fade_in / 2
                end

                s.next = fade_manager.make_fader(
                    hud_id,
                    ctrls,
                    fade_manager.get_hud_opacity(requested, hud_id),
                    duration,
                    {
                        on_start = function(_)
                            try_add_element(requested.hud, hud_id)
                        end,
                        free_value = disable_opacity,
                    }
                )
            end,
            free_value = disable_opacity,
            -- partial fades have only 1 level, while this fade has 2
            -- it cannot be synchronized, so it is sped up to finish at the same time
            synchronized = not (fade_opacity and disable_opacity),
        })
    end

    return fade_manager.make_fader(
        hud_id,
        ctrls,
        fade_manager.get_hud_opacity(requested, hud_id),
        { fade_in = requested.hud.fade_in, fade_out = requested.hud.fade_out },
        {
            on_start = function(_)
                try_add_element(requested.hud, hud_id)
            end,
            free_value2 = fade_opacity,
        }
    )
end

---@param no_fade app.GUIHudDef.TYPE[]
local function finish_fade_switch(no_fade)
    for _, hud_id in ipairs(no_fade) do
        try_add_element(this.requested_hud.hud, hud_id)
    end

    switch_profile(false)
    finish()
end

---@param new_hud ModHud
---@param force boolean?
function this.request_hud(new_hud, force)
    if not force and should_ignore_request(new_hud) then
        return
    end

    this.notify = not this.current_hud or this.current_hud.hud.key ~= new_hud.hud.key
    this.requested_hud = new_hud

    if not should_fade(new_hud) then
        switch_profile()
        finish()
        return
    end

    local all_elements = play_object.control.get_all_hud_control()
    ---@type table<app.GUIHudDef.TYPE, Fader>
    local faders = {}
    ---@type app.GUIHudDef.TYPE[]
    local no_fade = {}
    for hud_id, ctrls in pairs(all_elements) do
        local disable_fade =
            fade_manager.get_elem_fade_disable(this.current_hud, this.requested_hud, hud_id)
        if disable_fade == fade_manager.disable_type.DISABLE then
            table.insert(no_fade, hud_id)
        else
            faders[hud_id] = make_elem_fader(hud_id, ctrls, disable_fade)
        end
    end

    if util_table.empty(faders) then
        switch_profile()
        finish()
        return
    end

    fade_manager.request_fade(faders, function()
        finish_fade_switch(no_fade)
    end)
end

function this.clear()
    this.current_hud = nil
    this.requested_hud = nil
end

return this
