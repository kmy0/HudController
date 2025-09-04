---@class (exact) CompanionPlayerGauge : HudChild
---@field get_config fun(): CompanionPlayerGaugeConfig
---@field children {
--- frame: HudChild,
--- light_end: HudChild,
--- light_start: HudChild,
--- line: Material,
--- line_shadow: Material,
--- }

---@class (exact) CompanionPlayerGaugeConfig : HudChildConfig
---@field children {
--- frame: HudChildConfig,
--- light_end: HudChildConfig,
--- light_start:HudChildConfig,
--- line: MaterialConfig,
--- line_shadow: MaterialConfig,
--- }

---@class (exact) CompanionPlayerGaugeControlArguments
---@field frame PlayObjectGetterFn[]
---@field light_end PlayObjectGetterFn[]
---@field light_start PlayObjectGetterFn[]
---@field line PlayObjectGetterFn[]
---@field line_shadow PlayObjectGetterFn[]
---@field gauge PlayObjectGetterFn[]

local data = require("HudController.data")
local hud_child = require("HudController.hud.def.hud_child")
local material = require("HudController.hud.def.material")
local play_object = require("HudController.hud.play_object")

local mod = data.mod

---@class CompanionPlayerGauge
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_hp00
---@type CompanionPlayerGaugeControlArguments
local control_arguments = {
    frame = {
        {
            play_object.control.get,
            {
                "PNL_gaugeMode00",
                "PNL_bese",
            },
        },
    },
    light_end = {
        {
            play_object.control.get,
            {
                "PNL_gaugeMode00",
                "PNL_gauge00",
                "PNL_light00",
            },
        },
    },
    light_start = {
        {
            play_object.control.get,
            {
                "PNL_gaugeMode01",
            },
        },
    },
    line = {
        {
            play_object.child.get,
            {
                "PNL_gaugeMode00",
                "PNL_gauge00",
            },
            "mat_gauge00",
            "via.gui.Material",
        },
    },
    line_shadow = {
        {
            play_object.child.get,
            {
                "PNL_gaugeMode00",
                "PNL_gauge00",
            },
            "mat_gauge01",
            "via.gui.Material",
        },
    },
    gauge = {
        {
            play_object.control.get,
            {
                "PNL_playerSet00",
                "PNL_hp00",
            },
        },
    },
}

---@param args CompanionPlayerGaugeConfig
---@param parent CompanionPlayer
---@return CompanionPlayerGauge
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.gauge)
    end)
    setmetatable(o, self)
    ---@cast o CompanionPlayerGauge

    o.children.frame = hud_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.frame)
    end)
    o.children.light_end = hud_child:new(args.children.light_end, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.light_end)
    end)
    o.children.light_start = hud_child:new(args.children.light_start, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.light_start)
    end)
    o.children.line = material:new(args.children.line, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.line)
    end)
    o.children.line_shadow = material:new(args.children.line_shadow, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.line_shadow)
    end)

    return o
end

---@return CompanionPlayerGaugeConfig
function this.get_config()
    local base = hud_child.get_config("gauge") --[[@as CompanionPlayerGaugeConfig]]
    local children = base.children

    children.frame = {
        name_key = "frame",
        hide = false,
    }
    children.light_end = {
        name_key = "light_end",
        hide = false,
    }
    children.light_start = {
        name_key = "light_start",
        hide = false,
    }
    children.line = {
        name_key = "line",
        hide = false,
        enabled_scale = false,
        scale = { x = 1, y = 1 },
        enabled_offset = false,
        offset = { x = 0, y = 0 },
        enabled_size_y = false,
        size_y = 1,
        enabled_var0 = false,
        var0 = { name_key = "material_width_scale", value = 1 },
        enabled_var1 = false,
        var1 = { name_key = "material_anim_speed_scale", value = 1 },
        enabled_var2 = false,
        var2 = { name_key = "material_side_mag_scale", value = 1 },
        hud_sub_type = mod.enum.hud_sub_type.MATERIAL,
    }
    children.line_shadow = {
        name_key = "line_shadow",
        hide = false,
        enabled_scale = false,
        scale = { x = 1, y = 1 },
        enabled_offset = false,
        offset = { x = 0, y = 0 },
        enabled_size_y = false,
        size_y = 1,
        enabled_var0 = false,
        var0 = { name_key = "material_width_scale", value = 1 },
        enabled_var1 = false,
        var1 = { name_key = "material_anim_speed_scale", value = 1 },
        enabled_var2 = false,
        var2 = { name_key = "material_side_mag_scale", value = 1 },
        hud_sub_type = mod.enum.hud_sub_type.MATERIAL,
    }

    return base
end

return this
