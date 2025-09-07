---@class (exact) Stamina : HudBase
---@field get_config fun(): StaminaConfig
---@field GUI020004 app.GUI020004?
---@field children {
--- gauge: StaminaGauge,
--- background: HudChild,
--- frame: HudChild,
--- frame_max: HudChild,
--- light_end: HudChild,
--- light_start: HudChild,
--- }

---@class (exact) StaminaConfig : HudBaseConfig
---@field options {AUTO_SCALING_STAMINA: integer}
---@field children {
--- gauge: StaminaGaugeConfig,
--- background: HudChildConfig,
--- frame: HudChildConfig,
--- frame_max: HudChildConfig,
--- light_end: HudChildConfig,
--- light_start: HudChildConfig,
--- }

---@class (exact) StaminaControlArguments
---@field background PlayObjectGetterFn[]
---@field frame PlayObjectGetterFn[]
---@field frame_max PlayObjectGetterFn[]
---@field light_end PlayObjectGetterFn[]
---@field light_start PlayObjectGetterFn[]

local call_queue = require("HudController.hud.call_queue")
local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local gauge = require("HudController.hud.elements.stamina.gauge")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local util_game = require("HudController.util.game")
local util_misc = require("HudController.util.misc")

local mod = data.mod
local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

-- PNL_Scale
---@type StaminaControlArguments
local control_arguments = {
    light_end = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gauge01",
            },
        },
        {
            play_object.child.get,
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
            play_object.child.get,
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
            play_object.child.get,
            {
                "PNL_Pat00",
                "PNL_gaugeMode00",
                "PNL_gaugeBase00",
            },
            "tex_base02",
            "via.gui.Texture",
        },
    },
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
                "PNL_gaugeMode01",
                "PNL_gaugeEasyMax",
                "PNL_essyMax01",
            },
        },
    },
}

---@class Stamina
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args StaminaConfig
---@return Stamina
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Stamina

    o.children.light_end = hud_child:new(
        args.children.light_end,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.light_end)
        end
    )
    o.children.gauge = gauge:new(args.children.gauge, o)
    o.children.background = hud_child:new(
        args.children.background,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.background)
        end
    )
    o.children.frame = hud_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.frame)
    end)
    o.children.frame_max = hud_child:new(
        args.children.frame_max,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.frame_max)
        end
    )
    o.children.light_start = hud_child:new(
        args.children.light_start,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.light_start)
        end
    )

    return o
end

---@param key HudBaseWriteKey
function this:reset(key)
    hud_base.reset(self, key)

    -- stamina gauge does not update till next health change
    call_queue.queue_func(self.hud_id, function()
        local hudbase = self:get_GUI020004()
        local amount = hudbase._GaugeAmount
        local current_value = hudbase._CurrentGaugeAmountValue

        if amount and current_value then
            util_misc.try(function()
                amount:setValue(current_value - 1)
            end)
            call_queue.queue_func(self.hud_id, function()
                util_misc.try(function()
                    amount:setValue(current_value)
                end)
            end)
        end
    end)
end

---@return app.GUI020004
function this:get_GUI020004()
    if not self.GUI020004 then
        self.GUI020004 = util_game.get_component_any("app.GUI020004")
    end

    return self.GUI020004
end

---@return StaminaConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "STAMINA"), "STAMINA") --[[@as StaminaConfig]]
    local children = base.children
    base.options.AUTO_SCALING_STAMINA = -1
    base.hud_type = mod.enum.hud_type.STAMINA

    children.gauge = gauge.get_config()
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
