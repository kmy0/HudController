---@class (exact) Clock : HudBase
---@field hide_map_visible boolean
---@field get_config fun(): ClockConfig
---@field reset fun(self: Clock, key: ClockWriteKey)
---@field mark_write fun(self: Clock, key: ClockProperty)
---@field mark_idle fun(self: Clock, key: ClockProperty)
---@field children {text: HudChild, background: HudChild, frame: HudChild}

---@class (exact) ClockConfig : HudBaseConfig
---@field hide_map_visible boolean
---@field children {
--- text: HudChildConfig,
--- frame: HudChildConfig,
--- background: HudChildConfig,
--- }

---@alias ClockProperty HudChildProperty | "hide_map_visible"
---@alias ClockWriteKey HudChildWriteKey | ClockProperty

---@class (exact) ClockControlArguments
---@field text PlayObjectGetterFn[]
---@field frame PlayObjectGetterFn[]
---@field background PlayObjectGetterFn[]

local ace_misc = require("HudController.util.ace.misc")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

---@class Clock
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- ctrl = PNL_Scale
---@type ClockControlArguments
local control_arguments = {
    text = {
        {
            play_object.control.get,
            {
                "PNL_Pat01",
                "PNL_EnvName",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_Pat01",
                "PNL_TimeName",
            },
        },
    },
    background = {
        {
            play_object.control.get,
            {
                "PNL_Pat01",
                "PNL_Base",
            },
        },
    },
    frame = {
        {
            play_object.control.get,
            {
                "PNL_Pat01",
                "PNL_Frame",
            },
        },
    },
}

---@param args ClockConfig
---@return Clock
function this:new(args)
    local o = hud_base.new(self, args)
    o.properties = util_table.merge_t(o.properties, {
        hide_map_visible = true,
    })
    setmetatable(o, self)
    ---@cast o Clock

    o.children.text = hud_child:new(args.children.text, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text)
    end)
    o.children.frame = hud_child:new(args.children.frame, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.frame)
    end)
    o.children.background = hud_child:new(args.children.background, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.background)
    end)

    if args.hide_map_visible then
        o:set_hide_map_visible(args.hide_map_visible)
    end

    return o
end

---@protected
---@param ctrl via.gui.Control
---@return boolean
function this:_write(ctrl)
    if self.hide_map_visible then
        if ace_misc.is_map_open() then
            ctrl:set_ForceInvisible(true)
            return false
        else
            ctrl:set_ForceInvisible(false)
        end
    end

    return hud_base._write(self, ctrl)
end

---@param ctrl via.gui.Control
---@param key ClockWriteKey
function this:reset_ctrl(ctrl, key)
    if self.hide_map_visible and (not key or key == "hide_map_visible") then
        ctrl:set_ForceInvisible(false)
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    hud_child.reset_ctrl(self, ctrl, key)
end

---@param hide boolean
function this:set_hide_map_visible(hide)
    self:reset("hide_map_visible")

    if self.hide_map_visible and not hide then
        self:mark_idle("hide_map_visible")
    elseif not self.hide_map_visible and hide then
        self:mark_write("hide_map_visible")
    end
    self.hide_map_visible = hide
end

---@return ClockConfig
function this.get_config()
    local base = hud_base.get_config(e.get("app.GUIHudDef.TYPE").CLOCK, "CLOCK") --[[@as ClockConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.CLOCK
    base.hide_map_visible = false

    children.text = { name_key = "text", hide = false }
    children.background = { name_key = "background", hide = false }
    children.frame = { name_key = "frame", hide = false }

    return base
end

return this
