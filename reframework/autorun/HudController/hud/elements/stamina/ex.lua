---@class (exact) StaminaEx : HudChild
---@field get_config fun(): StaminaExConfig
---@field hide_pulse boolean
---@field children {
--- bar1: StaminaExBar,
--- bar2: StaminaExBar,
--- pulse: HudChild,
--- }

---@class (exact) StaminaExConfig : HudChildConfig
---@field hide_pulse boolean
---@field children {
--- bar1: StaminaExBarConfig,
--- bar2: StaminaExBarConfig,
--- pulse: HudChildConfig,
--- }

---@class (exact) StaminaExBar : HudChild
---@field children {
--- frame: Material,
--- background: Scale9,
--- light_end: HudChild,
--- glow: HudChild,
--- }

---@class (exact) StaminaExBarConfig : HudChildConfig
---@field children {
--- frame: MaterialConfig,
--- background: Scale9Config,
--- light_end: HudChildConfig,
--- glow: HudChildConfig,
--- }

---@class (exact) StaminaExControlArguments
---@field ex PlayObjectGetterFn[]
---@field bar1 PlayObjectGetterFn[]
---@field bar2 PlayObjectGetterFn[]
---@field frame_pnl PlayObjectGetterFn[]
---@field frame_mat PlayObjectGetterFn[]
---@field background PlayObjectGetterFn[]
---@field glow PlayObjectGetterFn[]
---@field light_end PlayObjectGetterFn[]

local hud_child = require("HudController.hud.def.hud_child")
local material = require("HudController.hud.def.material")
local play_object = require("HudController.hud.play_object.init")
local scale9 = require("HudController.hud.def.scale9")
local util_table = require("HudController.util.misc.table")
local play_object_defaults = require("HudController.hud.defaults.init").play_object
local data = require("HudController.data.init")

local mod = data.mod

---@class StaminaEx
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_gaugeMode00
---@type StaminaExControlArguments
local control_arguments = {
    ex = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_EXStamina",
                "PNL_EXStaminaPos",
            },
        },
    },
    bar1 = {
        {
            play_object.control.get,
            {
                "PNL_EXStamina00",
            },
        },
    },
    bar2 = {
        {
            play_object.control.get,
            {
                "PNL_EXStamina01",
            },
        },
    },
    frame_pnl = {
        {
            play_object.control.get,
            {
                "PNL_EXSFrame",
            },
        },
    },
    frame_mat = {
        {
            play_object.child.all_type,
            "mat_base",
            "via.gui.Material",
        },
    },
    background = {
        {
            play_object.child.get,
            {},
            "s9g_base",
            "via.gui.Scale9GridV2",
        },
    },
    glow = {
        {
            play_object.child.all_type,
            "s9g_gauge",
            "via.gui.Scale9Grid",
        },
        {
            play_object.child.get,
            {
                "PNL_EXSGauge",
            },
            "rect_gauge",
            "via.gui.Rect",
        },
    },
    light_end = {
        {
            play_object.control.get,
            {
                "PNL_EXSGauge",
                "PNL_glight",
            },
        },
    },
}

---@param args StaminaExConfig
---@param parent Stamina
---@return StaminaEx
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.ex)
    end)
    setmetatable(o, self)
    ---@cast o StaminaEx

    for i = 1, 2 do
        local key = "bar" .. i
        ---@diagnostic disable-next-line: no-unknown
        o.children[key] = hud_child:new(args.children[key], o, function(_, _, _, ctrl)
            return play_object.iter_args(ctrl, control_arguments[key])
        end) --[[@as StaminaExBar]]

        local children_o = (o.children[key]).children
        local children_args = (args.children[key] --[[@as StaminaExBarConfig]]).children

        children_o.frame = material:new(
            children_args.frame,
            o.children[key],
            function(_, _, _, ctrl)
                local frame = play_object.iter_args(ctrl, control_arguments.frame_pnl)
                if frame[1] then
                    return play_object.iter_args(frame[1], control_arguments.frame_mat)
                end
            end
        )
        children_o.background = scale9:new(
            children_args.background,
            o.children[key],
            function(_, _, _, ctrl)
                local frame = play_object.iter_args(ctrl, control_arguments.frame_pnl)
                if frame[1] then
                    return play_object.iter_args(frame[1], control_arguments.background)
                end
            end
        )
        children_o.light_end = hud_child:new(
            children_args.light_end,
            o.children[key],
            function(_, _, _, ctrl)
                return play_object.iter_args(ctrl, control_arguments.light_end)
            end
        )
        children_o.glow = hud_child:new(children_args.glow, o.children[key], function(_, _, _, ctrl)
            return play_object.iter_args(ctrl, control_arguments.glow)
        end)
    end

    o.children.pulse = hud_child:new(args.children.pulse, o, function(_, _, _, ctrl)
        return util_table.array_merge_t(
            play_object.iter_args(ctrl, control_arguments.bar1),
            play_object.iter_args(ctrl, control_arguments.bar2)
        )
    end, function(s, ctrl)
        play_object_defaults:check(ctrl)
        if s.play_state then
            ctrl:set_PlayState("DEFAULT")
        end
        return true
    end, nil, true)

    o:set_hide_pulse(args.hide_pulse)
    return o
end

---@param val boolean
function this:set_hide_pulse(val)
    self.hide_pulse = val
    if self.hide_pulse then
        self.children.pulse:set_play_state("dummy")
    else
        self.children.pulse:set_play_state()
    end
end

---@return StaminaExConfig
function this.get_config()
    local base = hud_child.get_config("extra_bar") --[[@as StaminaExConfig]]
    local children = base.children

    base.hide_pulse = false

    children.bar1 = hud_child.get_config("bar1") --[[@as StaminaExBarConfig]]
    children.bar2 = hud_child.get_config("bar2") --[[@as StaminaExBarConfig]]
    children.bar1.children.frame =
        { name_key = "frame", hide = false, hud_sub_type = mod.enum.hud_sub_type.MATERIAL }
    children.bar2.children.frame =
        { name_key = "frame", hide = false, hud_sub_type = mod.enum.hud_sub_type.MATERIAL }
    children.bar1.children.light_end = { name_key = "light_end", hide = false }
    children.bar2.children.light_end = { name_key = "light_end", hide = false }
    children.bar1.children.background =
        { name_key = "background", hide = false, hud_sub_type = mod.enum.hud_sub_type.SCALE9 }
    children.bar2.children.background =
        { name_key = "background", hide = false, hud_sub_type = mod.enum.hud_sub_type.SCALE9 }
    children.bar1.children.glow = { name_key = "glow", hide = false }
    children.bar2.children.glow = { name_key = "glow", hide = false }
    children.pulse = { name_key = "__pulse", play_state = "" }

    return base
end

return this
