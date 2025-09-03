---@class (exact) Health : HudBase
---@field get_config fun(): HealthConfig
---@field GUI020003 app.GUI020003?
---@field children {
--- background: HudChild,
--- frame: HudChild,
--- frame_max: HudChild,
--- light_end: HudChild,
--- light_start: HudChild,
--- gauge: HealthGauge,
--- skill_list: HealthSkillList,
--- anim_danger: HudChild,
--- anim_low_health: HudChild,
--- red_health: HudChild,
--- incoming_health: HudChild,
--- gauge: HealthGauge,
--- skill_line: HudChild,
--- light_start: HudChild,
--- max_fall: HealthMaxFall,
--- }

---@class (exact) HealthConfig : HudBaseConfig
---@field options {
--- AUTO_SCALING_FITNESS: integer,
--- ALERT_EFFECT: integer,
--- }
---@field children {
--- background: HudChildConfig,
--- frame: HudChildConfig,
--- frame_max: HudChildConfig,
--- light_end: HudChildConfig,
--- light_start: HudChildConfig,
--- line1: MaterialConfig,
--- line1_shadow: MaterialConfig,
--- line2: MaterialConfig,
--- line2_shadow: MaterialConfig,
--- skill_list: HealthSkillListConfig,
--- anim_danger: HudChildConfig,
--- anim_low_health: HudChildConfig,
--- red_health: HudChildConfig,
--- incoming_health: HudChildConfig,
--- gauge: HealthGaugeConfig,
--- skill_line: HudChildConfig,
--- light_start: HudChildConfig,
--- max_fall: HealthMaxFallConfig,
--- }

---@class (exact) HealthControlArguments
---@field background PlayObjectGetterFn[]
---@field frame PlayObjectGetterFn[]
---@field frame_max PlayObjectGetterFn[]
---@field light_end PlayObjectGetterFn[]
---@field light_start PlayObjectGetterFn[]
---@field gauge PlayObjectGetterFn[]
---@field skill_line PlayObjectGetterFn[]
---@field max_fall PlayObjectGetterFn[]
---@field skill_list PlayObjectGetterFn[]
---@field anim_low_health PlayObjectGetterFn[]
---@field red_health PlayObjectGetterFn[]
---@field incoming_health PlayObjectGetterFn[]

local call_queue = require("HudController.hud.call_queue")
local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local gauge = require("HudController.hud.elements.health.gauge")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local max_fall = require("HudController.hud.elements.health.max_fall")
local play_object = require("HudController.hud.play_object")
local skill_list = require("HudController.hud.elements.health.skill_list")
local util_game = require("HudController.util.game")
local util_misc = require("HudController.util.misc")

local mod = data.mod
local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

---@class Health
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- PNL_Scale
---@type HealthControlArguments
local control_arguments = {
    background = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gaugeBase00",
            },
        },
    },
    frame = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_frame",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_StepMAX",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_StepBase",
            },
        },
        {
            play_object.child.get,
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
            play_object.control.get,
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
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gauge00",
                "PNL_lightAnim",
            },
        },
        {
            play_object.child.get,
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gaugeBase00",
            },
            "tex_base02",
            "via.gui.Texture",
        },
        {
            play_object.child.get,
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
            play_object.child.get,
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
    light_start = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_gaugeMode01",
                "PNL_gaugeEasyMax",
                "PNL_essyMax01",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_Healing01",
                "PNL_healing01Anim",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_gaugeMode01",
                "PNL_gaugeEasyMax",
                "PNL_essyMax01",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_gaugeEffectBack00",
            },
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
    skill_line = {
        {
            play_object.control.get,
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
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_StepMAX",
                "PNL_MaxFall",
            },
        },
    },
    skill_list = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_StateIcons",
            },
        },
    },

    anim_low_health = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gaugeRatioAnim0",
            },
        },
    },
    red_health = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gaugeEtc",
                "PNL_gaugeRedIn",
            },
        },
        {
            play_object.control.get,
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
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gaugeEtc",
                "PNL_gaugeHealIn",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_MaxEnd",
            },
        },
    },
}

---@param args HealthConfig
---@param default_overwrite HudBaseDefaultOverwrite?
---@return Health
function this:new(args, default_overwrite)
    local o = hud_base.new(self, args, nil, default_overwrite)
    setmetatable(o, self)
    ---@cast o Health

    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.background)
    end)
    o.children.frame = hud_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.frame)
    end)
    o.children.frame_max = hud_child:new(args.children.frame_max, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.frame_max)
    end)
    o.children.light_end = hud_child:new(args.children.light_end, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.light_end)
    end)
    o.children.light_start = hud_child:new(args.children.light_start, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.light_start)
    end)
    o.children.skill_list = skill_list:new(args.children.skill_list, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.skill_list)
    end)
    o.children.skill_line = hud_child:new(args.children.skill_line, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.skill_line)
    end)
    o.children.anim_low_health = hud_child:new(args.children.anim_low_health, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.anim_low_health)
    end)
    o.children.red_health = hud_child:new(args.children.red_health, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.red_health)
    end)
    o.children.incoming_health = hud_child:new(args.children.incoming_health, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.incoming_health)
    end)
    o.children.max_fall = max_fall:new(args.children.max_fall, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.max_fall)
    end)
    o.children.gauge = gauge:new(args.children.gauge, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.gauge)
    end)

    return o
end

---@param key HudBaseWriteKey
function this:reset(key)
    hud_base.reset(self, key)

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
    local base = hud_base.get_config(rl(ace_enum.hud, "HEALTH"), "HEALTH") --[[@as HealthConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.HEALTH
    base.options.AUTO_SCALING_FITNESS = -1
    base.options.ALERT_EFFECT = -1

    children.max_fall = max_fall.get_config()
    children.skill_list = skill_list.get_config()
    children.gauge = gauge.get_config()
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
    children.background = {
        name_key = "background",
        hide = false,
    }
    children.frame = {
        name_key = "frame",
        hide = false,
    }
    children.frame_max = {
        name_key = "frame_max",
        hide = false,
    }
    children.light_start = {
        name_key = "light_start",
        hide = false,
    }
    children.light_end = {
        name_key = "light_end",
        hide = false,
    }

    return base
end

return this
