---@class (exact) StaminaGauge : HudChild
---@field get_config fun(): StaminaGaugeConfig
---@field children {line1: Material, line1_shadow: Material, line2: Material, line3: Scale9}

---@class (exact) StaminaGaugeConfig : HudChildConfig
---@field children {
--- line1: MaterialConfig,
--- line1_shadow: MaterialConfig,
--- line2: MaterialConfig,
--- line3: Scale9Config,
--- }

---@class (exact) StaminaGaugeControlArguments
---@field line1 PlayObjectGetterFn[]
---@field line1_shadow PlayObjectGetterFn[]
---@field line2 PlayObjectGetterFn[]
---@field line3 PlayObjectGetterFn[]
---@field gauge PlayObjectGetterFn[]

local data = require("HudController.data")
local hud_child = require("HudController.hud.def.hud_child")
local material = require("HudController.hud.def.material")
local play_object = require("HudController.hud.play_object")
local scale9 = require("HudController.hud.def.scale9")

local mod = data.mod

---@class StaminaGauge
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_gaugeMode00
---@type StaminaGaugeControlArguments
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
            "mat_gauge02",
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
    line3 = {
        {
            play_object.child.get,
            {
                "PNL_gauge00",
                "PNL_gaugeMatBase",
            },
            "s9g_gaugeMain",
            "via.gui.Scale9Grid",
        },
    },
    gauge = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
            },
        },
    },
}

---@param args StaminaGaugeConfig
---@param parent Stamina
---@return StaminaGauge
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.gauge)
    end)
    setmetatable(o, self)
    ---@cast o StaminaGauge

    o.children.line1 = material:new(args.children.line1, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.line1)
    end)
    o.children.line2 = material:new(args.children.line2, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.line2)
    end)
    o.children.line1_shadow = material:new(
        args.children.line1_shadow,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.line1_shadow)
        end
    )
    o.children.line3 = scale9:new(args.children.line3, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.line3)
    end)

    return o
end

---@return StaminaGaugeConfig
function this.get_config()
    local base = hud_child.get_config("gauge") --[[@as StaminaGaugeConfig]]
    local children = base.children

    children.line1 = {
        name_key = "line1",
        hide = false,
        enabled_scale = false,
        scale = { x = 1, y = 1 },
        enabled_size_y = false,
        size_y = 1,
        enabled_offset = false,
        offset = { x = 0, y = 0 },
        enabled_var0 = false,
        var0 = { name_key = "material_size_x_scale", value = 1 },
        enabled_var1 = false,
        var1 = { name_key = "material_size_y_scale", value = 1 },
        enabled_var2 = false,
        var2 = { name_key = "material_anim_speed_scale", value = 1 },
        enabled_var3 = false,
        var3 = { name_key = "material_level_max_scale", value = 1 },
        hud_sub_type = mod.enum.hud_sub_type.MATERIAL,
    }
    children.line1_shadow = {
        name_key = "line1_shadow",
        hide = false,
        enabled_scale = false,
        scale = { x = 1, y = 1 },
        enabled_size_y = false,
        size_y = 1,
        enabled_offset = false,
        offset = { x = 0, y = 0 },
        enabled_var0 = false,
        var0 = { name_key = "material_size_x_scale", value = 1 },
        enabled_var1 = false,
        var1 = { name_key = "material_size_y_scale", value = 1 },
        enabled_var2 = false,
        var2 = { name_key = "material_anim_speed_scale", value = 1 },
        enabled_var3 = false,
        var3 = { name_key = "material_level_max_scale", value = 1 },
        hud_sub_type = mod.enum.hud_sub_type.MATERIAL,
    }
    children.line2 = {
        name_key = "line2",
        hide = false,
        enabled_scale = false,
        scale = { x = 1, y = 1 },
        enabled_size_y = false,
        size_y = 1,
        enabled_offset = false,
        offset = { x = 0, y = 0 },
        enabled_var0 = false,
        var0 = { name_key = "material_size_x_scale", value = 1 },
        enabled_var1 = false,
        var1 = { name_key = "material_size_y_scale", value = 1 },
        enabled_var2 = false,
        var2 = { name_key = "material_anim_speed_scale", value = 1 },
        enabled_var3 = false,
        var3 = { name_key = "material_level_max_scale", value = 1 },
        hud_sub_type = mod.enum.hud_sub_type.MATERIAL,
    }
    children.line3 = {
        name_key = "line3",
        hud_sub_type = mod.enum.hud_sub_type.SCALE9,
        hide = false,
        enabled_scale = false,
        scale = { x = 1, y = 1 },
        enabled_size_y = false,
        size_y = 1,
        enabled_color = false,
        color = 0,
        enabled_alpha_channel = false,
        alpha_channel = "None",
        enabled_offset = false,
        offset = { x = 0, y = 0 },
    }

    return base
end

return this
