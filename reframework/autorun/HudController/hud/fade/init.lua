---@class FadeManager
---@field faders FaderGroup?
---@field to_restore table<app.GUIHudDef.TYPE, boolean>
---@field on_finish fun()?
---@field step_mod number

local e = require("HudController.util.game.enum")
local fader = require("HudController.hud.fade.fader")
local fader_group = require("HudController.hud.fade.fader_group")
local play_object = require("HudController.hud.play_object.init")
local util_misc = require("HudController.util.misc.init")
---@module "HudController.hud.manager.elements"
local elements = util_misc.lazy_require("HudController.hud.manager.elements")

---@class FadeManager
local this = {
    to_restore = {},
    step_mod = 1,
}
---@enum FadeDisableType
this.disable_type = {
    NONE = 0,
    DISABLE = 1,
    DISABLE_OPACITY = 2,
}

---@param ctrl via.gui.Control
---@return integer opacity
---@return boolean need_restore
local function get_opacity(ctrl)
    if not ctrl:get_ActualVisible() then
        return 0, true
    end

    local gui = ctrl:get_Component()
    if not gui:get_Enabled() then
        return 0, true
    end

    local color = ctrl:get_ColorScale()
    return color.w, false
end

---@param ctrl via.gui.Control
local function reset_opacity(ctrl)
    local color = ctrl:get_ColorScale()
    color.w = 1
    ctrl:set_ColorScale(color)
end

---@param mod_hud ModHud
---@param hud_id app.GUIHudDef.TYPE
---@return HudBaseConfig
local function get_element_fade_config(mod_hud, hud_id)
    local hud_name = e.get("app.GUIHudDef.TYPE")[hud_id]
    local elem = mod_hud.hud.elements[hud_name]
    return mod_hud.profile_to[hud_name] or elem and elements.get_element_profile(elem)
end

function this.abort()
    this.clear(true)

    local elements = play_object.control.get_all_hud_control()
    this.faders = nil
    this.to_restore = {}
    for _, ctrls in pairs(elements) do
        for _, ctrl in pairs(ctrls) do
            reset_opacity(ctrl)
        end
    end
end

---@param abort boolean?
function this.clear(abort)
    if abort then
        this.to_restore = {}
    end

    this.step_mod = 1
    this.on_finish = nil
end

---@return boolean
function this.is_active()
    return this.faders ~= nil
end

---@param hud_id app.GUIHudDef.TYPE
---@return boolean
function this.is_active_element(hud_id)
    return this.faders ~= nil and this.faders:is_active(hud_id)
end

---@param hud_id app.GUIHudDef.TYPE
---@param ctrl via.gui.Control[]
---@param target_opacity number
---@param duration number | {fade_in: number, fade_out: number}
---@param optional_args FaderOptionalArgs?
---@return Fader
function this.make_fader(hud_id, ctrl, target_opacity, duration, optional_args)
    optional_args = optional_args or {}

    local need_restore = false
    local from = 0
    local to = target_opacity

    for _, c in pairs(ctrl) do
        local _from, _need_restore = get_opacity(c)
        from = math.max(from, _from)
        need_restore = need_restore or _need_restore
    end

    if need_restore then
        this.to_restore[hud_id] = true
    end

    if type(duration) == "table" then
        duration = to > from and duration.fade_in or duration.fade_out
    end

    return fader:new(hud_id, ctrl, from, to, duration, optional_args)
end

---@param hud_id app.GUIHudDef.TYPE
---@return Fader?
function this.get_fader(hud_id)
    return this.faders and this.faders:get_fader(hud_id)
end

---@param faders table<app.GUIHudDef.TYPE, Fader>
---@param on_finish fun()?
function this.request_fade(faders, on_finish)
    if this.is_active() then
        this.step_mod = this.step_mod + 1
    end

    this.faders = fader_group:new(faders)
    if this.is_active() then
        this.faders:accelerate(this.step_mod)
    end

    this.on_finish = on_finish
end

function this.update()
    if this.faders and this.faders:update() then
        this.faders = nil
    end

    if not this.faders and this.on_finish then
        local f = this.on_finish --[[@as fun()]]

        f()

        -- if callback was not swapped to new one
        if f == this.on_finish then
            this.on_finish = nil
        end
    end
end

---@param mod_hud ModHud
---@param hud_id app.GUIHudDef.TYPE
---@return integer opacity
function this.get_hud_opacity(mod_hud, hud_id)
    local elem = get_element_fade_config(mod_hud, hud_id)
    if elem then
        if elem.hide then
            return 0
        elseif elem.enabled_opacity then
            return elem.opacity
        end
    end

    return 1
end

---@param a ModHud
---@param b ModHud
---@param hud_id app.GUIHudDef.TYPE
---@return FadeDisableType
function this.get_elem_fade_disable(a, b, hud_id)
    local a_elem = get_element_fade_config(a, hud_id)
    local b_elem = get_element_fade_config(b, hud_id)

    if (a_elem and a_elem.disable_fade) or (b_elem and b_elem.disable_fade) then
        return this.disable_type.DISABLE
    end

    if (a_elem and a_elem.disable_fade_opacity) or (b_elem and b_elem.disable_fade_opacity) then
        return this.disable_type.DISABLE_OPACITY
    end

    return this.disable_type.NONE
end

---@param hud_id app.GUIHudDef.TYPE
---@param ctrl via.gui.Control
function this.restore_opacity(hud_id, ctrl)
    if this.to_restore[hud_id] then
        reset_opacity(ctrl)
        this.to_restore[hud_id] = nil
    end
end

return this
