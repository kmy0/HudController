---@class (exact) Health : VitalBase
---@field get_config fun(): HealthConfig
---@field GUI020003 app.GUI020003?
---@field children {
--- skill_list: SkillList,
--- anim_danger: HudChild,
--- anim_low_health: HudChild,
--- red_health: HudChild,
--- incoming_health: HudChild,
--- gauge: HealthGauge,
--- skill_line: HudChild,
--- light_start: HudChild,
--- max_fall: HudChild,
--- }

---@class (exact) MaxFall : HudChild
---@field children {
--- timer: HudChild,
--- point: HudChild,
--- }

---@class (exact) MaxFallConfig : HudChildConfig
---@field children {
--- timer: HudChildConfig,
--- point: HudChildConfig,
--- }

---@class (exact) SkillList : HudChild
---@field children {icon : HudChild, timer: HudChild}

---@class (exact) HealthGauge : HudChild
---@field children {
--- line1: Material,
--- line1_shadow: Material,
--- line2: Material,
--- line2_shadow: Material,
--- }

---@class (exact) SkillListConfig : HudChildConfig
---@field children {icon: HudChildConfig, timer: HudChildConfig}

---@class (exact) HealthConfig : VitalConfig
---@field options {
--- AUTO_SCALING_FITNESS: integer,
--- ALERT_EFFECT: integer,
--- }
---@field children {
--- skill_list: SkillListConfig,
--- anim_danger: HudChildConfig,
--- anim_low_health: HudChildConfig,
--- red_health: HudChildConfig,
--- incoming_health: HudChildConfig,
--- gauge: VitalGaugeConfig,
--- skill_line: HudChildConfig,
--- light_start: HudChildConfig,
--- max_fall: MaxFallConfig,
--- }

local call_queue = require("HudController.hud.call_queue")
local data = require("HudController.data")
local frame_cache = require("HudController.util.misc.frame_cache")
local game_data = require("HudController.util.game.data")
local hud_child = require("HudController.hud.def.hud_child")
local material = require("HudController.hud.def.material")
local play_object = require("HudController.hud.play_object")
local util_game = require("HudController.util.game")
local util_misc = require("HudController.util.misc")
local util_table = require("HudController.util.misc.table")
local vital_base = require("HudController.hud.def.vital_base")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

-- ctrl = PNL_Scale
local ctrl_args = {
    skill_list = {
        {
            {
                "PNL_Pat00",
                "PNL_StateIcons",
            },
        },
    },
    -- ctrl = PNL_StateIcons
    ["skill_list.icon"] = {
        {
            {},
            "PNL_STIcon",
        },
    },
    ["skill_list.virus"] = {
        {
            {
                "PNL_Virus",
            },
        },
    },
    ["skill_list.timer"] = {
        {
            {
                "PNL_timerLong",
            },
        },
        {
            {
                "PNL_timerNum",
            },
        },
    },
    anim_low_health = {
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gaugeRatioAnim0",
            },
        },
    },
    red_health = {
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gaugeEtc",
                "PNL_gaugeRedIn",
            },
        },
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gauge00",
                "PNL_damage",
            },
        },
    },
    incoming_health = {
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gaugeEtc",
                "PNL_gaugeHealIn",
            },
        },
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_MaxEnd",
            },
        },
    },
    light_start = {
        {
            {
                "PNL_Pat00",
                "PNL_Healing01",
                "PNL_healing01Anim",
            },
        },
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode01",
                "PNL_gaugeEasyMax",
                "PNL_essyMax01",
            },
        },
        {
            {
                "PNL_Pat00",
                "PNL_gaugeEffectBack00",
            },
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
            "mat_gauge00_shadow",
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
    ["gauge.line2_shadow"] = {
        {
            {
                "PNL_gauge00",
                "PNL_gaugeMatBase",
            },
            "mat_gauge01_shadow",
            "via.gui.Material",
        },
    },
    skill_line = {
        {
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gauge00",
                "PNL_skillLine",
            },
        },
    },
    max_fall = {
        {
            {
                "PNL_Pat00",
                "PNL_StepMAX",
                "PNL_MaxFall",
            },
        },
    },
    ["max_fall.timer"] = {
        {
            {
                "PNL_MaxFallTextAnim",
            },
        },
    },
    ["max_fall.point"] = {
        {
            {
                "PNL_stepMaxFallPoint",
            },
        },
    },
}

---@param ctrl via.gui.Control
local function get_icons(ctrl)
    return play_object.iter_args(play_object.control.all, ctrl, ctrl_args["skill_list.icon"])
end

---@class Health
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = vital_base })

---@param args HealthConfig
---@return Health
function this:new(args)
    local o = vital_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Health

    o.children.light_start = hud_child:new(args.children.light_start, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.light_start)
    end)
    o.children.skill_list = hud_child:new(args.children.skill_list, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.skill_list)
    end) --[[@as SkillList]]
    o.children.skill_list.children.icon = hud_child:new(
        args.children.skill_list.children.icon,
        o.children.skill_list,
        function(s, hudbase, gui_id, ctrl)
            return util_table.array_merge_t(
                play_object.iter_args(play_object.control.get, ctrl, ctrl_args["skill_list.virus"]),
                get_icons(ctrl)
            )
        end
    )
    o.children.skill_list.children.timer = hud_child:new(
        args.children.skill_list.children.timer,
        o.children.skill_list,
        function(s, hudbase, gui_id, ctrl)
            local ret = {}
            local icons = get_icons(ctrl)
            for _, icon in pairs(icons) do
                ---@cast icon via.gui.Control
                util_table.array_merge_t(
                    ret,
                    play_object.iter_args(play_object.control.get, icon, ctrl_args["skill_list.timer"])
                )
            end

            return ret
        end
    )

    o.children.skill_line = hud_child:new(args.children.skill_line, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.skill_line)
    end)
    o.children.anim_low_health = hud_child:new(args.children.anim_low_health, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.anim_low_health)
    end)
    o.children.red_health = hud_child:new(args.children.red_health, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.red_health)
    end)
    o.children.incoming_health = hud_child:new(args.children.incoming_health, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.incoming_health)
    end)

    o.children.max_fall = hud_child:new(args.children.max_fall, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.max_fall)
    end)
    o.children.max_fall.children.timer = hud_child:new(
        args.children.max_fall.children.timer,
        o.children.max_fall,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args["max_fall.timer"])
        end
    )
    o.children.max_fall.children.point = hud_child:new(
        args.children.max_fall.children.point,
        o.children.max_fall,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args["max_fall.point"])
        end
    )

    o.children.gauge = hud_child:new(args.children.gauge, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.gauge)
    end) --[[@as HealthGauge]]
    o.children.gauge.children.line1 = material:new(
        args.children.gauge.children.line1,
        o.children.gauge,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.child.get, ctrl, ctrl_args["gauge.line1"])
        end
    )
    o.children.gauge.children.line2 = material:new(
        args.children.gauge.children.line2,
        o.children.gauge,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.child.get, ctrl, ctrl_args["gauge.line2"])
        end
    )
    o.children.gauge.children.line1_shadow = material:new(
        args.children.gauge.children.line1_shadow,
        o.children.gauge,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.child.get, ctrl, ctrl_args["gauge.line1_shadow"])
        end
    )
    o.children.gauge.children.line2_shadow = material:new(
        args.children.gauge.children.line2_shadow,
        o.children.gauge,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.child.get, ctrl, ctrl_args["gauge.line2_shadow"])
        end
    )

    return o
end

---@param key HudBaseWriteKey
function this:reset(key)
    vital_base.reset(self, key)

    -- health gauge does not update till next health change
    call_queue.queue_func(self.hud_id, function()
        local hudbase = self:get_GUI020003()
        local amount = hudbase._GaugeAmount
        if amount then
            local current_value = amount:getValue()
            util_misc.try(function()
                amount:setValue(current_value - 1)
            end)
        end
    end)
end

---@return app.GUI020003
function this:get_GUI020003()
    if not self.GUI020003 then
        self.GUI020003 = util_game.get_component_any("app.GUI020003")
    end

    return self.GUI020003
end

---@return HealthConfig
function this.get_config()
    local base = vital_base.get_config(rl(ace_enum.hud, "HEALTH"), "HEALTH") --[[@as HealthConfig]]
    local children = base.children
    base.hud_type = mod.enum.hud_type.HEALTH
    base.options.AUTO_SCALING_FITNESS = -1
    base.options.ALERT_EFFECT = -1

    children.max_fall = hud_child.get_config("max_fall") --[[@as MaxFallConfig]]
    children.max_fall.children = {
        timer = hud_child.get_config("timer"),
        point = {
            name_key = "point",
            hide = false,
        },
    }

    children.skill_list = hud_child.get_config("skill_list") --[[@as SkillListConfig]]
    children.skill_list.children = {
        icon = {
            name_key = "icon",
            enabled_rot = false,
            rot = 0,
        },
        timer = {
            name_key = "timer",
            hide = false,
        },
    }

    children.gauge = hud_child.get_config("gauge") --[[@as VitalGaugeConfig]]
    children.gauge.children = {
        line1 = {
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
        },
        line1_shadow = {
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
        },
        line2 = {
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
        },
        line2_shadow = {
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
        },
    }
    children.anim_low_health = {
        name_key = "anim_low_health",
        hide = false,
    }
    children.red_health = {
        name_key = "red_health",
        hide = false,
    }
    children.incoming_health = {
        name_key = "incoming_health",
        hide = false,
    }
    children.skill_line = {
        name_key = "skill_line",
        hide = false,
    }

    return base
end

get_icons = frame_cache.memoize(get_icons)

return this
