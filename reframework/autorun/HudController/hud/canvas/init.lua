---@class Canvas
---@field action CanvasAction?
---@field bind_monitor CanvasBindMonitor
---@field initialized boolean

---@class (exact) CanvasAction
---@field type CanvasActionEnum
---@field value any
---@field hudid app.GUIHudDef.TYPE
---@field elem HudBase

---@class (exact) CanvasActionNumber : CanvasAction
---@field type CanvasActionEnum.OPACITY | CanvasActionEnum.SCALE | CanvasActionEnum.ROT
---@field value number

---@class (exact) CanvasActionBoolean : CanvasAction
---@field type CanvasActionEnum.HIDE
---@field value boolean

---@class (exact) CanvasActionPos : CanvasAction
---@field type CanvasActionEnum.POS
---@field value {offset: {x: number, y: number}, start_pos: {x: number, y: number}}

local ace_misc = require("HudController.util.ace.misc")
local action = require("HudController.hud.canvas.actions")
local bind_monitor = require("HudController.hud.canvas.bind.init")
local canvas_draw = require("HudController.hud.canvas.draw")
local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local hud = require("HudController.hud.init")
local mod = require("HudController.data.mod")

---@class Canvas
local this = { initialized = false }
---@type CanvasActionEnum?
local prev_frame

---@return boolean
local function init()
    local hud_config = hud.get_current()

    if not hud_config then
        hud.operations.new()
        hud_config = hud.get_current()
    end

    if not hud_config then
        return false
    end

    ---@cast hud_config HudProfileConfig
    for name_key, _ in pairs(hud_config.elements) do
        local hudbase = hud.get_element(name_key) --[[@as HudBase]]
        action.store_elem_state(hudbase)
    end

    return true
end

function this.clear()
    canvas_draw.clear()
    action.clear()
    this.action = nil
    this.initialized = false
end

function this.draw()
    if not this.initialized then
        if not init() then
            return
        end

        this.initialized = true
    end

    local this_frame = bind_monitor.monitor:monitor()
    if this.action and this.action.type ~= this_frame then
        this.action = nil
        config:save()
    end

    local kb = ace_misc.get_kb()
    local mouse_pos = kb:get_MousePos()
    local wheel_delta = kb:get_MouseWheelDelta()
    local elem = canvas_draw.draw(mouse_pos, wheel_delta, this.action)

    if this_frame and elem and not this.action and not prev_frame then
        local hudbase = hud.get_element(elem)
        if not hudbase then
            hud.operations.add_element(e.get("app.GUIHudDef.TYPE")[elem])
            hudbase = hud.get_element(elem) --[[@as HudBase]]
        end

        ---@type {x: number, y: number} | number | boolean
        local value
        if this_frame == mod.enum.canvas.POS then
            value = {
                start_pos = { x = mouse_pos.x, y = mouse_pos.y },
                offset = {
                    x = hudbase.offset and hudbase.offset.x or 0,
                    y = hudbase.offset and hudbase.offset.y or 0,
                },
            }
        elseif this_frame == mod.enum.canvas.OPACITY then
            value = hudbase.opacity or 1.0
        elseif this_frame == mod.enum.canvas.SCALE then
            value = hudbase.scale and hudbase.scale.x or 1.0
        elseif this_frame == mod.enum.canvas.ROT then
            value = hudbase.rot and hudbase.rot.z or 0.0
        elseif this_frame == mod.enum.canvas.HIDE then
            value = hudbase.hide and true or false
        elseif this_frame == mod.enum.canvas.UNDO then
            value = elem
        end

        if not action.elem_default[hudbase.hud_id] then
            action.store_elem_state(hudbase)
        end

        this.action = {
            type = this_frame,
            value = value,
            hudid = elem,
            elem = hudbase,
        }
    end

    if this.action then
        action.apply(this.action, mouse_pos, wheel_delta)
    end

    prev_frame = this_frame
end

---@return boolean
function this.init()
    bind_monitor.init()
    return true
end

return this
