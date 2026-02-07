---@class (exact) HealthGauge : HudChild
---@field get_config fun(): HealthGaugeConfig
---@field children {
--- line1: Material,
--- line1_shadow: Material,
--- line2: Material,
--- line2_shadow: Material,
--- }

---@class (exact) HealthGaugeConfig : HudChildConfig
---@field children {
--- line1: MaterialConfig,
--- line1_shadow: MaterialConfig,
--- line2: MaterialConfig,
--- line2_shadow: MaterialConfig,
--- }

---@class (exact) HealthGaugeControlArguments
---@field line1 PlayObjectGetterFn[]
---@field line1_shadow PlayObjectGetterFn[]
---@field line2 PlayObjectGetterFn[]
---@field line2_shadow PlayObjectGetterFn[]

local data = require("HudController.data.init")
local hud_child = require("HudController.hud.def.hud_child")
local material = require("HudController.hud.def.material")
local play_object = require("HudController.hud.play_object.init")

local mod = data.mod

---@class HealthGauge
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_gaugeMode00
---@type HealthGaugeControlArguments
local control_arguments = {
    line1 = {
        {
            play_object.child.get,
            {
                "PNL_gauge00",
                "PNL_gaugeMatBase",
            },
            "mat_gauge00",
            "via.gui.Material",
        },
    },
    line1_shadow = {
        {
            play_object.child.get,
            {
                "PNL_gauge00",
                "PNL_gaugeMatBase",
            },
            "mat_gauge00_shadow",
            "via.gui.Material",
        },
    },
    line2 = {
        {
            play_object.child.get,
            {
                "PNL_gauge00",
                "PNL_gaugeMatBase",
            },
            "mat_gauge01",
            "via.gui.Material",
        },
    },
    line2_shadow = {
        {
            play_object.child.get,
            {
                "PNL_gauge00",
                "PNL_gaugeMatBase",
            },
            "mat_gauge01_shadow",
            "via.gui.Material",
        },
    },
}

---@param args HealthGaugeConfig
---@param parent Health
---@param ctrl_getter fun(self: HudChild, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): PlayObject[] | PlayObject?
---@return HealthGauge
function this:new(args, parent, ctrl_getter)
    local o = hud_child.new(self, args, parent, ctrl_getter)
    setmetatable(o, self)
    ---@cast o HealthGauge

    o.children.line1 = material:new(args.children.line1, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.line1)
    end)
    o.children.line2 = material:new(args.children.line2, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.line2)
    end)
    o.children.line1_shadow = material:new(args.children.line1_shadow, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.line1_shadow)
    end)
    o.children.line2_shadow = material:new(args.children.line2_shadow, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.line2_shadow)
    end)

    return o
end

---@return HealthGaugeConfig
function this.get_config()
    local base = hud_child.get_config("gauge") --[[@as HealthGaugeConfig]]
    local children = base.children

    children.line1 = {
        name_key = "line1",
        hide = false,
        enabled_scale = false,
        scale = { x = 1, y = 1 },
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
    children.line1_shadow = {
        name_key = "line1_shadow",
        hide = false,
        enabled_scale = false,
        scale = { x = 1, y = 1 },
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
    children.line2 = {
        name_key = "line2",
        hide = false,
        enabled_scale = false,
        scale = { x = 1, y = 1 },
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
    children.line2_shadow = {
        name_key = "line2_shadow",
        hide = false,
        enabled_scale = false,
        scale = { x = 1, y = 1 },
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
