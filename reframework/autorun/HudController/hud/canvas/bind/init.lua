---@class CanvasBinds
---@field actions ModBindManager
---@field monitor CanvasBindMonitor

local bind_manager = require("HudController.hud.bind.manager")
local e = require("HudController.util.game.enum")
local mod = require("HudController.data.mod")
local monitor = require("HudController.hud.canvas.bind.monitor")

---@class CanvasBinds
local this = {}

---@param bind ModBind
local function action(bind)
    if this.monitor.action then
        return
    end

    this.monitor.action = bind.bound_value
    this.monitor.action_type = bind.action_type
    this.monitor:register_on_release_callback(bind.name, function()
        this.monitor.action = nil
    end)
end

---@return boolean
function this.init()
    this.monitor = monitor:new()
    this.monitor:set_max_buffer_frame(1)

    this.actions = bind_manager:new("actions", action)
    this.monitor:add_manager(this.actions)

    this.actions:load({
        {
            name = "L_CLICK",
            name_display = "L_CLICK",
            device = "KEYBOARD",
            keys = { e.get("ace.ACE_MKB_KEY.INDEX").L_CLICK },
            bound_value = mod.enum.canvas.POS,
            action_type = "NONE",
        },
        {
            name = "R_CLICK",
            name_display = "R_CLICK",
            device = "KEYBOARD",
            keys = { e.get("ace.ACE_MKB_KEY.INDEX").R_CLICK },
            bound_value = mod.enum.canvas.HIDE,
            action_type = "TOGGLE",
        },
        {
            name = "L_CTRL",
            name_display = "L_CTRL",
            device = "KEYBOARD",
            keys = { e.get("ace.ACE_MKB_KEY.INDEX").L_CTRL },
            bound_value = mod.enum.canvas.SCALE,
            action_type = "NONE",
        },
        {
            name = "L_ALT",
            name_display = "L_ALT",
            device = "KEYBOARD",
            keys = { e.get("ace.ACE_MKB_KEY.INDEX").L_ALT },
            bound_value = mod.enum.canvas.OPACITY,
            action_type = "NONE",
        },
        {
            name = "L_SHIFT",
            name_display = "L_SHIFT",
            device = "KEYBOARD",
            keys = { e.get("ace.ACE_MKB_KEY.INDEX").L_SHIFT },
            bound_value = mod.enum.canvas.ROT,
            action_type = "NONE",
        },
        {
            name = "BACK_SPACE",
            name_display = "BACK_SPACE",
            device = "KEYBOARD",
            keys = { e.get("ace.ACE_MKB_KEY.INDEX").BACK_SPACE },
            bound_value = mod.enum.canvas.UNDO,
            action_type = "TOGGLE",
        },
    })

    return true
end

return this
