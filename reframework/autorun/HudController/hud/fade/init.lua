---@class FadeManager
---@field current_fade {hud_key: integer, type: FadeType}?
---@field faders table<app.GUIHudDef.TYPE, Fader[]>
---@field to_restore table<app.GUIHudDef.TYPE, boolean>
---@field callback fun()?
---@field step_mod number

local e = require("HudController.util.game.enum")
local fader = require("HudController.hud.fade.fader")
local play_object = require("HudController.hud.play_object.init")
local util_table = require("HudController.util.misc.table")

---@class FadeManager
local this = {
    faders = {},
    to_restore = {},
    step_mod = 1,
}
---@enum FadeType
this.type = {
    fade_out = 1,
    fade_in = 2,
    fade_partial = 3,
}
---@enum FadeDisableType
this.fade_disable_type = {
    DISABLE = 1,
    DISABLE_OPACITY = 2,
}

---@param ctrl via.gui.Control
---@return number
local function get_opacity(ctrl)
    local color = ctrl:get_ColorScale()
    return color.w
end

---@param ctrl via.gui.Control
local function reset_opacity(ctrl)
    local color = ctrl:get_ColorScale()
    color.w = 1
    ctrl:set_ColorScale(color)
end

---@param hud_config HudProfileConfig
---@param hud_id app.GUIHudDef.TYPE
---@return integer
local function get_hud_opacity(hud_config, hud_id)
    local hud_name = e.get("app.GUIHudDef.TYPE")[hud_id]
    local hud_elem_config = hud_config.elements[hud_name]

    if hud_elem_config then
        if hud_elem_config.hide then
            this.to_restore[hud_id] = true
            return 0
        elseif hud_elem_config.enabled_opacity then
            return hud_elem_config.opacity
        end
    end

    return 1
end

---@param hud_config HudProfileConfig
---@param hud_id app.GUIHudDef.TYPE
---@param ctrl via.gui.Control
---@return integer
local function get_hud_from_opacity_partial(hud_config, hud_id, ctrl)
    local hud_name = e.get("app.GUIHudDef.TYPE")[hud_id]
    local hud_elem_config = hud_config.elements[hud_name]

    if hud_elem_config and hud_elem_config.hide then
        this.to_restore[hud_id] = true
        return 0
    end

    return get_opacity(ctrl)
end

---@param hud_config HudProfileConfig
---@param type FadeType
---@param callback fun()?
---@param fader_disable table<app.GUIHudDef.TYPE, FadeDisableType>?
---@param fader_callbacks table<app.GUIHudDef.TYPE, fun(fader: Fader)>?
local function fade(hud_config, type, callback, fader_disable, fader_callbacks)
    if this.is_active() then
        this.step_mod = this.step_mod + 1
    end

    local elements = play_object.control.get_all_hud_control()
    this.faders = {}
    this.current_fade = { hud_key = hud_config.key, type = type }
    this.callback = callback
    fader_disable = fader_disable or {}
    fader_callbacks = fader_callbacks or {}

    for hud_id, ctrls in pairs(elements) do
        if fader_disable[hud_id] == this.fade_disable_type.DISABLE then
            goto continue
        end

        for _, ctrl in pairs(ctrls) do
            local fader_obj = fader:new(
                hud_id,
                get_opacity(ctrl),
                type == this.type.fade_in and get_hud_opacity(hud_config, hud_id) or 0,
                type == this.type.fade_in and hud_config.fade_in or hud_config.fade_out,
                ctrl,
                fader_callbacks[hud_id]
            )
            fader_obj.step = fader_obj.step * this.step_mod
            util_table.insert_nested_value(this.faders, { hud_id }, fader_obj)
        end

        ::continue::
    end
end

---@param hud_config HudProfileConfig
---@param callback fun()?
---@param fader_disable table<app.GUIHudDef.TYPE, FadeDisableType>?
---@param fader_callbacks table<app.GUIHudDef.TYPE, fun(fader: Fader)>?
function this.fade_in(hud_config, callback, fader_disable, fader_callbacks)
    fade(hud_config, this.type.fade_in, callback, fader_disable, fader_callbacks)
end

---@param hud_config HudProfileConfig
---@param callback fun()?
---@param fader_disable table<app.GUIHudDef.TYPE, FadeDisableType>?
---@param fader_callbacks table<app.GUIHudDef.TYPE, fun(fader: Fader)>?
function this.fade_out(hud_config, callback, fader_disable, fader_callbacks)
    fade(hud_config, this.type.fade_out, callback, fader_disable, fader_callbacks)
end

---@param from_hud_config HudProfileConfig
---@param to_hud_config HudProfileConfig
---@param callback fun()?
---@param fader_disable table<app.GUIHudDef.TYPE, FadeDisableType>?
---@param fader_callbacks table<app.GUIHudDef.TYPE, fun(fader: Fader)>?
function this.fade_partial(from_hud_config, to_hud_config, callback, fader_disable, fader_callbacks)
    if this.is_active() then
        this.step_mod = this.step_mod + 1
    end

    local elements = play_object.control.get_all_hud_control()
    this.faders = {}
    this.current_fade = { hud_key = to_hud_config.key, type = this.type.fade_partial }
    this.callback = callback
    fader_disable = fader_disable or {}
    fader_callbacks = fader_callbacks or {}

    for hud_id, ctrls in pairs(elements) do
        if fader_disable[hud_id] == this.fade_disable_type.DISABLE then
            goto continue
        end

        for _, ctrl in pairs(ctrls) do
            local from = get_hud_from_opacity_partial(from_hud_config, hud_id, ctrl)
            local to = get_hud_opacity(to_hud_config, hud_id)
            ---@type number
            local time

            if from == to then
                goto continue
            elseif to > from then
                time = to_hud_config.fade_in
            else
                time = from_hud_config.fade_out
            end

            ---@type Fader?
            local fader_next
            if fader_disable[hud_id] == this.fade_disable_type.DISABLE_OPACITY then
                time = time / 2
                fader_next = fader:new(hud_id, 0, to, time, ctrl)
                to = 0
                fader_next.step = fader_next.step * this.step_mod
            end

            local fader_obj =
                fader:new(hud_id, from, to, time, ctrl, fader_callbacks[hud_id], fader_next)
            fader_obj.step = fader_obj.step * this.step_mod
            util_table.insert_nested_value(this.faders, { hud_id }, fader_obj)
            ::continue::
        end
        ::continue::
    end
end

function this.abort()
    this.clear(true)

    local elements = play_object.control.get_all_hud_control()
    this.faders = {}
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
    this.current_fade = nil
    this.callback = nil
end

---@param type FadeType?
---@return boolean
function this.is_active(type)
    if not type then
        return this.current_fade ~= nil
    end

    if this.current_fade then
        return this.current_fade.type == type
    end

    return false
end

---@param hud_id app.GUIHudDef.TYPE
---@return boolean
function this.is_active_element(hud_id)
    if not this.faders[hud_id] then
        return false
    end

    return util_table.any(this.faders[hud_id], function(_, f)
        return not f:is_done_no_next()
    end)
end

function this.update()
    for hud_id, faders in pairs(this.faders) do
        for i, f in pairs(faders) do
            if f:update() then
                faders[i] = nil
            end
        end

        if util_table.empty(faders) then
            this.faders[hud_id] = nil
        end
    end

    if util_table.empty(this.faders) and this.callback then
        local f = this.callback

        ---@diagnostic disable-next-line: need-check-nil
        f()

        -- if callback was not swapped to new one
        if f == this.callback then
            this.callback = nil
        end
    end
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
