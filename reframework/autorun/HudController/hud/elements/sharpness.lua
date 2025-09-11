---@class (exact) Sharpness : HudBase
---@field get_config fun(): SharpnessConfig
---@field GUI020015 app.GUI020015
---@field state integer
---@field mark_write fun(self: Sharpness, key: SharpnessProperty)
---@field mark_idle fun(self: Sharpness, key: SharpnessProperty)
---@field children {
--- anim_max: HudChild,
--- background: HudChild,
--- frame: HudChild,
--- next: HudChild,
--- edge: HudChild,
--- }

---@class (exact) SharpnessConfig : HudBaseConfig
---@field options {AUTO_SCALING_SHARPNESS: integer}
---@field state integer
---@field children {
--- anim_max: HudChildConfig,
--- background: HudChildConfig,
--- frame: HudChildConfig,
--- next: HudChildConfig,
--- edge: HudChildConfig,
--- }

---@class (exact) SharpnessChangedProperties : HudChildChangedProperties
---@field state boolean?

---@class (exact) SharpnessProperties : {[SharpnessProperty]: boolean}, HudChildProperties
---@field state boolean

---@alias SharpnessProperty HudChildProperty | "state"

---@class (exact) SharpnessControlArguments
---@field anim_max PlayObjectGetterFn[]
---@field frame PlayObjectGetterFn[]
---@field background PlayObjectGetterFn[]
---@field next PlayObjectGetterFn[]
---@field edge PlayObjectGetterFn[]

local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")
local util_game = require("HudController.util.game.init")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Sharpness
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- PNL_Scale
---@type SharpnessControlArguments
local control_arguments = {
    anim_max = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_allRotate",
                "PNL_gaugeMode00Over",
                "PNL_MaxLightMove",
                "PNL_MaxLight",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_allRotate",
                "PNL_gaugeMode01Over",
                "PNL_MaxLight",
                "PNL_MaxLightAnim",
            },
        },
    },
    frame = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_allRotate",
                "PNL_frame",
            },
        },
    },
    background = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_allRotate",
                "PNL_base",
            },
        },
    },
    next = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_allRotate",
                "PNL_gaugeMode00",
                "PNL_gaugeMode00change",
                "PNL_Next",
            },
        },
    },
    edge = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_allRotate",
                "PNL_gaugeMode00",
                "PNL_gaugeMode00change",
                "PNL_gaugeDownSoon00",
                "PNL_Edge",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_allRotate",
                "PNL_gaugeMode00",
                "PNL_gaugeMode00change",
                "PNL_gaugeDownSoon00",
                "PNL_gaugeEdgeLight",
            },
        },
    },
}

---@param args SharpnessConfig
---@return Sharpness
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Sharpness

    o.properties = util_table.merge_t(o.properties, {
        state = true,
    })
    o.children.anim_max = hud_child:new(
        args.children.anim_max,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.anim_max)
        end
    )
    o.children.frame = hud_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.frame)
    end)
    o.children.next = hud_child:new(args.children.next, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.next)
    end)
    o.children.edge = hud_child:new(args.children.edge, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.edge)
    end)
    o.children.background = hud_child:new(
        args.children.background,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.background)
        end
    )

    if args.state ~= -1 then
        o:set_state(args.state)
    else
        o.state = args.state
    end

    return o
end

---@param val integer
function this:set_state(val)
    if val ~= -1 then
        self:mark_write("state")
        self.state = val
    else
        -- no reset needed
        self.state = val
        self:mark_idle("state")
    end
end

---@return app.GUI020015
function this:get_GUI020015()
    if not self.GUI020015 then
        self.GUI020015 = util_game.get_component_any("app.GUI020015") --[[@as app.GUI020015]]
    end
    return self.GUI020015
end

---@return boolean
function this:any()
    return util_table.any(self.properties, function(key, value)
        if (key == "state" and self[key] ~= -1) or (key ~= "state" and self[key]) then
            return true
        end
        return false
    end)
end

---@protected
---@param ctrl via.gui.Control
---@return boolean
function this:_write(ctrl)
    if self.state == 0 then
        self:get_GUI020015():setGaugeModeStatus(rl(ace_enum.sharpness_state, "DEFAULT"))
    elseif self.state == 1 then
        self:get_GUI020015():setGaugeModeStatus(rl(ace_enum.sharpness_state, "SELECT"))
    end

    return hud_base._write(self, ctrl)
end

---@return SharpnessConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "SHARPNESS"), "SHARPNESS") --[[@as SharpnessConfig]]
    local children = base.children
    base.options.AUTO_SCALING_SHARPNESS = -1
    base.hud_type = mod.enum.hud_type.SHARPNESS
    base.state = -1

    children.anim_max = { name_key = "anim_max", hide = false }
    children.frame = { name_key = "frame", hide = false }
    children.background = { name_key = "background", hide = false }
    children.next = { name_key = "next_line", hide = false }
    children.edge = { name_key = "edge", hide = false }

    return base
end

return this
