---@class FadeManager
---@field current_fade {hud_key: integer, type: FadeType}?
---@field faders table<app.GUIHudDef.TYPE, Fader[]>
---@field to_restore table<app.GUIHudDef.TYPE, boolean>
---@field callback fun()?
---@field step_mod number

local ace_misc = require("HudController.util.ace.misc")
local data = require("HudController.data")
local fader = require("HudController.hud.fade.fader")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local ace_map = data.ace.map

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
local function get_new_opacity(hud_config, hud_id)
    local hud_name = ace_enum.hud[hud_id]
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

---@param hud_id app.GUIHudDef.TYPE
---@return via.gui.Control[]
local function get_element(hud_id)
    ---@type via.gui.Control[]
    local ret = {}
    local hudman = ace_misc.get_hud_manager()
    for _, gui_id in pairs(ace_map.hudid_to_guiid[hud_id]) do
        local disp_ctrl = hudman:findDisplayControl(gui_id)
        if not disp_ctrl then
            goto continue
        end

        table.insert(ret, disp_ctrl._TargetControl)
        ::continue::
    end

    return ret
end

---@return table<app.GUIHudDef.TYPE, via.gui.Control[]>
local function get_all_elements()
    ---@type table<app.GUIHudDef.TYPE, via.gui.Control[]>
    local ret = {}
    for hud_id, _ in pairs(ace_enum.hud) do
        local elements = get_element(hud_id)
        if not util_table.empty(elements) then
            ret[hud_id] = elements
        end
    end

    return ret
end

---@param hud_config HudProfileConfig
---@param type FadeType
---@param callback fun()?
local function fade(hud_config, type, callback)
    if this.is_active() then
        this.step_mod = this.step_mod + 1
    end

    local elements = get_all_elements()
    this.faders = {}
    this.current_fade = { hud_key = hud_config.key, type = type }
    this.callback = callback

    for hud_id, ctrls in pairs(elements) do
        for _, ctrl in pairs(ctrls) do
            local fader_obj = fader:new(
                hud_id,
                get_opacity(ctrl),
                type == this.type.fade_in and get_new_opacity(hud_config, hud_id) or 0,
                type == this.type.fade_in and hud_config.fade_in or hud_config.fade_out,
                ctrl
            )
            fader_obj.step = fader_obj.step * this.step_mod
            util_table.insert_nested_value(this.faders, { hud_id }, fader_obj)
        end
    end
end

---@param hud_config HudProfileConfig
---@param callback fun()?
function this.fade_in(hud_config, callback)
    fade(hud_config, this.type.fade_in, callback)
end

---@param hud_config HudProfileConfig
---@param callback fun()?
function this.fade_out(hud_config, callback)
    fade(hud_config, this.type.fade_out, callback)
end

---@param from_hud_config HudProfileConfig
---@param to_hud_config HudProfileConfig
---@param callback fun()?
function this.fade_partial(from_hud_config, to_hud_config, callback)
    if this.is_active() then
        this.step_mod = this.step_mod + 1
    end

    local elements = get_all_elements()
    this.faders = {}
    this.current_fade = { hud_key = to_hud_config.key, type = this.type.fade_partial }
    this.callback = callback

    for hud_id, ctrls in pairs(elements) do
        for _, ctrl in pairs(ctrls) do
            local from = get_opacity(ctrl)
            local to = get_new_opacity(to_hud_config, hud_id)
            ---@type number
            local time

            if from == to then
                goto continue
            elseif to > from then
                time = to_hud_config.fade_in
            else
                time = from_hud_config.fade_out
            end

            local fader_obj = fader:new(hud_id, from, to, time, ctrl)
            fader_obj.step = fader_obj.step * this.step_mod
            util_table.insert_nested_value(this.faders, { hud_id }, fader_obj)
            ::continue::
        end
    end
end

function this.abort()
    this.clear(true)

    if not util_table.empty(this.faders) or not util_table.empty(this.to_restore) then
        local elements = get_all_elements()
        this.faders = {}
        this.to_restore = {}
        for _, ctrls in pairs(elements) do
            for _, ctrl in pairs(ctrls) do
                reset_opacity(ctrl)
            end
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
