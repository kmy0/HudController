---@class (exact) VitalBase : HudBase
---@field get_config fun(hud_id: app.GUIHudDef.TYPE, name_key: string): HudBaseConfig
---@field children {
--- background: HudChild,
--- frame: HudChild,
--- frame_max: HudChild,
--- light_end: HudChild,
--- light_start: HudChild,
--- gauge: HudChild}

---@class (exact) VitalConfig : HudBaseConfig
---@field children {
--- background: HudChildConfig,
--- frame: HudChildConfig,
--- frame_max: HudChildConfig,
--- light_end: HudChildConfig,
--- light_start: HudChildConfig,
--- }

---@class (exact) VitalGaugeConfig : HudChildConfig
---@field children {
--- line1: MaterialConfig,
--- line1_shadow: MaterialConfig,
--- line2: MaterialConfig,
--- line2_shadow: MaterialConfig,
--- }

local data = require("HudController.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

---@class VitalBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- ctrl = PNL_Scale
local ctrl_args = {
    background = {
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gaugeBase00",
            },
        },
    },
    frame = {
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_frame",
            },
        },
        {
            {
                "PNL_Pat00",
                "PNL_StepMAX",
            },
        },
        {
            {
                "PNL_Pat00",
                "PNL_StepBase",
            },
        },
    },
    frame2 = {
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gaugeMaxLimit00",
                "PNL_gaugeMaxLimitBase00",
            },
            "tex_frameMax",
            "via.gui.Texture",
        },
    },
    frame_max = {
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gaugeMaxLimit00",
                "PNL_gaugeMaxLimitBase00",
            },
        },
    },
    light_end = {
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gauge00",
                "PNL_lightAnim",
            },
        },
    },
    light_start = {
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode01",
                "PNL_gaugeEasyMax",
                "PNL_essyMax01",
            },
        },
    },
    light_end_shadow = {
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gaugeBase00",
            },
            "tex_base02",
            "via.gui.Texture",
        },
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_MaxEnd",
                "PNL_MaxEndAnim",
                "PNL_frameMaxEnd",
                "PNL_gaugeMaxEndBase00",
            },
            "tex_frameMax",
            "via.gui.Texture",
        },
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_MaxEnd",
                "PNL_MaxEndAnim",
                "PNL_frameMaxEnd",
                "PNL_gaugeMaxEndBase00",
            },
            "tex_frameMax1",
            "via.gui.Texture",
        },
    },
}

---@param args VitalConfig
---@param default_overwrite HudBaseDefaultOverwrite?
---@return VitalBase
function this:new(args, default_overwrite)
    local o = hud_base.new(self, args, nil, default_overwrite)
    setmetatable(o, self)
    ---@cast o VitalBase

    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.background)
    end)
    o.children.frame = hud_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        return util_table.array_merge_t(
            play_object.iter_args(play_object.control.get, ctrl, ctrl_args.frame),
            play_object.iter_args(play_object.child.get, ctrl, ctrl_args.frame2)
        )
    end)
    o.children.frame_max = hud_child:new(args.children.frame_max, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.frame_max)
    end)
    o.children.light_end = hud_child:new(args.children.light_end, o, function(s, hudbase, gui_id, ctrl)
        return util_table.array_merge_t(
            play_object.iter_args(play_object.control.get, ctrl, ctrl_args.light_end),
            play_object.iter_args(play_object.child.get, ctrl, ctrl_args.light_end_shadow)
        )
    end)
    o.children.light_start = hud_child:new(args.children.light_start, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.light_start)
    end)

    return o
end

---@param hud_id app.GUIHudDef.TYPE
---@param name_key string
---@return VitalConfig
function this.get_config(hud_id, name_key)
    local base = hud_base.get_config(hud_id, name_key)
    base.children = {
        background = {
            name_key = "background",
            hide = false,
        },
        frame = {
            name_key = "frame",
            hide = false,
        },
        frame_max = {
            name_key = "frame_max",
            hide = false,
        },
        light_start = {
            name_key = "light_start",
            hide = false,
        },
        light_end = {
            name_key = "light_end",
            hide = false,
        },
    }
    base.hud_type = mod.enum.hud_type.VITAL
    return base
end

return this
