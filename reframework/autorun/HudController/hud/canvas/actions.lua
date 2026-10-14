---@class CanvasActions
---@field elem_default table<HudProfileKey, table<app.GUIHudDef.TYPE, ElemState>>

---@class (exact) ElemState
---@field rot EnabledNumber
---@field opacity EnabledNumber
---@field hide boolean
---@field scale EnabledVec2
---@field offset EnabledVec2

local e = require("HudController.util.game.enum")
local hud = require("HudController.hud.init")
local mod = require("HudController.data.mod")
local op = require("HudController.hud.manager.op.init")
local util_misc = require("HudController.util.misc.init")
local util_mod = require("HudController.util.mod.init")
local util_table = require("HudController.util.misc.table")

---@class CanvasActions
local this = {
    elem_default = {},
}

---@param action CanvasActionPos
---@param mouse_pos via.Point
local function set_offset(action, mouse_pos)
    local function _set_offset(elem, offset_x, offset_y)
        local elem_config = elem:get_current_config()

        elem_config.offset.x = offset_x
        elem_config.offset.y = offset_y
        elem_config.offset.enabled = true
        elem:set_offset(elem_config.offset)
    end

    local offset_x, offset_y = util_mod.to_offset(
        mouse_pos.x - action.value.start_pos.x,
        mouse_pos.y - action.value.start_pos.y
    )
    local n_offset_x = action.value.offset.x + offset_x
    local n_offset_y = action.value.offset.y + offset_y

    _set_offset(action.elem, n_offset_x, n_offset_y)
    if action.hudid == e.get("app.GUIHudDef.TYPE").MINIMAP then
        local elem = action.elem
        ---@cast elem Minimap
        _set_offset(elem.children.background, n_offset_x, n_offset_y)
    end
end

---@param action CanvasActionNumber
---@param mouse_wheel_delta number
local function set_scale(action, mouse_wheel_delta)
    mouse_wheel_delta = mouse_wheel_delta / 10
    local elem_config = action.elem:get_current_config()
    action.value = util_misc.wrap_number(action.value + mouse_wheel_delta, -10, 10)
    elem_config.scale.x = action.value
    elem_config.scale.y = action.value
    elem_config.scale.enabled = true
    action.elem:set_scale(elem_config.scale)
end

---@param action CanvasActionNumber
---@param mouse_wheel_delta number
local function set_rot(action, mouse_wheel_delta)
    mouse_wheel_delta = mouse_wheel_delta * 5
    local elem_config = action.elem:get_current_config()
    action.value = util_misc.wrap_number(action.value + mouse_wheel_delta, 0, 360)
    elem_config.rot.value = action.value
    elem_config.rot.enabled = true
    action.elem:set_rot(elem_config.rot)
end

---@param action CanvasActionNumber
---@param mouse_wheel_delta number
local function set_opacity(action, mouse_wheel_delta)
    mouse_wheel_delta = mouse_wheel_delta / 10
    local elem_config = action.elem:get_current_config()
    action.value = util_misc.wrap_number(action.value + mouse_wheel_delta, 0, 1)
    elem_config.opacity.value = action.value
    elem_config.opacity.enabled = true
    action.elem:set_opacity(elem_config.opacity)
end

---@param action CanvasActionBoolean
local function set_hide(action)
    action.value = not action.value
    local elem_config = action.elem:get_current_config()
    elem_config.hide = action.value
    action.elem:set_hide(action.value)
end

---@param action CanvasActionNumber
local function undo(action)
    local elem = hud.get_element(action.hudid)

    if not elem then
        op.hud_elem.add_element(e.get("app.GUIHudDef.TYPE")[action.hudid])
        elem = hud.get_element(action.hudid)
    end

    ---@cast elem HudBase

    local elem_config = elem:get_current_config()
    local elem_profile_key = elem:get_profile_key()

    local save_elem =
        util_table.get_nested_value(this.elem_default, { elem_profile_key, action.hudid }) --[[@as ElemState]]

    util_table.update(elem_config, save_elem)
    elem:set_rot(elem_config.rot)
    elem:set_opacity(elem_config.opacity)
    elem:set_hide(save_elem.hide)
    elem:set_scale(save_elem.scale)
    elem:set_offset(save_elem.offset)

    if action.hudid == e.get("app.GUIHudDef.TYPE").MINIMAP then
        ---@cast elem Minimap
        local bg = elem.children.background
        bg:set_offset(save_elem.offset)
        elem_config.children.background.offset = util_table.deep_copy(save_elem.offset)
    end
end

function this.clear()
    this.elem_default = {}
end

---@param elem HudBase
---@return boolean
function this.exist_elem_state(elem)
    local elem_profile_key = elem:get_profile_key()
    return util_table.get_nested_value(this.elem_default, { elem_profile_key, elem.hud_id }) ~= nil
end

---@param elem HudBase
function this.store_elem_state(elem)
    local elem_config = elem:get_current_config()
    local elem_profile_key = elem:get_profile_key()
    util_table.set_nested_value(this.elem_default, { elem_profile_key, elem.hud_id }, {
        hide = elem_config.hide,
        scale = util_table.deep_copy(elem_config.scale),
        offset = util_table.deep_copy(elem_config.offset),
        rot = util_table.deep_copy(elem_config.rot),
        opacity = util_table.deep_copy(elem_config.opacity),
    })
end

---@param action CanvasAction
---@param mouse_pos via.Point
---@param mouse_wheel_delta number
function this.apply(action, mouse_pos, mouse_wheel_delta)
    if action.type == mod.enum.canvas.POS then
        ---@cast action CanvasActionPos
        set_offset(action, mouse_pos)
    elseif action.type == mod.enum.canvas.SCALE then
        ---@cast action CanvasActionNumber
        set_scale(action, mouse_wheel_delta)
    elseif action.type == mod.enum.canvas.ROT then
        ---@cast action CanvasActionNumber
        set_rot(action, mouse_wheel_delta)
    elseif action.type == mod.enum.canvas.OPACITY then
        ---@cast action CanvasActionNumber
        set_opacity(action, mouse_wheel_delta)
    elseif action.type == mod.enum.canvas.HIDE then
        ---@cast action CanvasActionBoolean
        set_hide(action)
    elseif action.type == mod.enum.canvas.UNDO then
        ---@cast action CanvasActionNumber
        undo(action)
    end
end

return this
