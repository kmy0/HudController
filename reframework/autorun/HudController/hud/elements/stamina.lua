---@class (exact) Stamina : VitalBase
---@field get_config fun(): StaminaConfig
---@field children {gauge: StaminaGauge, light_end: HudChild}

---@class (exact) StaminaGauge : HudChild
---@field children {line1: Material, line1_shadow: Material, line2: Material, line3: Scale9}

---@class (exact) StaminaConfig : VitalConfig
---@field options {AUTO_SCALING_STAMINA: integer}
---@field children {gauge: StaminaGaugeConfig, light_end: HudChildConfig}

---@class (exact) StaminaGaugeConfig : HudChildConfig
---@field children {
--- line1: MaterialConfig,
--- line1_shadow: MaterialConfig,
--- line2: MaterialConfig,
--- line3: Scale9Config,
--- }

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_child = require("HudController.hud.def.hud_child")
local material = require("HudController.hud.def.material")
local play_object = require("HudController.hud.play_object")
local scale9 = require("HudController.hud.def.scale9")
local util_player = require("HudController.util.ace.player")
local util_table = require("HudController.util.misc.table")
local vital_base = require("HudController.hud.def.vital_base")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

-- ctrl = PNL_Scale
local ctrl_args = {
    light_end = {
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gauge01",
            },
        },
    },
    light_end_all = {
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_MaxEnd",
                "PNL_MaxEndAnim",
                "PNL_frameMaxEnd",
                "PNL_gaugeMaxEndBase01",
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
                "PNL_gaugeMaxEndBase01",
            },
            "tex_frameMax1",
            "via.gui.Texture",
        },
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gaugeBase00",
            },
            "tex_base02",
            "via.gui.Texture",
        },
    },
    gauge = {
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
            },
        },
    },
    -- ctrl = PNL_gaugeMode00
    ["gauge.line1"] = {
        {
            {
                "PNL_gauge00",
                "PNL_gaugeMatBase",
            },
            "mat_gauge00",
            "via.gui.Material",
        },
    },
    ["gauge.line1_shadow"] = {
        {
            {
                "PNL_gauge00",
                "PNL_gaugeMatBase",
            },
            "mat_gauge02",
            "via.gui.Material",
        },
    },
    ["gauge.line2"] = {
        {
            {
                "PNL_gauge00",
                "PNL_gaugeMatBase",
            },
            "mat_gauge01",
            "via.gui.Material",
        },
    },
    ["gauge.line3"] = {
        {
            {
                "PNL_gauge00",
                "PNL_gaugeMatBase",
            },
            "s9g_gaugeMain",
            "via.gui.Scale9Grid",
        },
    },
}

---@class Stamina
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = vital_base })

---@param args StaminaConfig
---@return Stamina
function this:new(args)
    local o = vital_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Stamina

    o.children.light_end = hud_child:new(args.children.light_end, o, function(s, hudbase, gui_id, ctrl)
        return util_table.array_merge_t(
            play_object.iter_args(play_object.control.get, ctrl, ctrl_args.light_end),
            play_object.iter_args(play_object.child.get, ctrl, ctrl_args.light_end_all)
        )
    end)
    o.children.gauge = hud_child:new(args.children.gauge, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.gauge)
    end) --[[@as StaminaGauge]]
    o.children.gauge.children.line1 = material:new(
        args.children.gauge.children.line1,
        o.children.gauge,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.child.get, ctrl, ctrl_args["gauge.line1"])
        end
    )
    o.children.gauge.children.line1_shadow = material:new(
        args.children.gauge.children.line1_shadow,
        o.children.gauge,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.child.get, ctrl, ctrl_args["gauge.line1_shadow"])
        end
    )
    o.children.gauge.children.line2 = material:new(
        args.children.gauge.children.line2,
        o.children.gauge,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.child.get, ctrl, ctrl_args["gauge.line2"])
        end
    )
    o.children.gauge.children.line3 = scale9:new(
        args.children.gauge.children.line3,
        o.children.gauge,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.child.get, ctrl, ctrl_args["gauge.line3"])
        end
    )
    return o
end

---@param key HudBaseWriteKey
function this:reset(key)
    vital_base.reset(self, key)

    local master_player = util_player:get_master_char()
    if master_player then
        local stamina = master_player:get_HunterStamina()
        if not stamina then
            return
        end

        local current_stamina = stamina:get_Stamina()
        stamina:setStamina(current_stamina - 2)
    end
end

---@return StaminaConfig
function this.get_config()
    local base = vital_base.get_config(rl(ace_enum.hud, "STAMINA"), "STAMINA") --[[@as StaminaConfig]]
    local children = base.children
    base.hud_type = mod.enum.hud_type.STAMINA
    base.options.AUTO_SCALING_STAMINA = -1

    children.gauge = hud_child.get_config("gauge") --[[@as StaminaGaugeConfig]]
    children.gauge.children = {
        line1 = {
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
        },
        line1_shadow = {
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
        },
        line2 = {
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
        },
        line3 = {
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
        },
    }
    return base
end

return this
