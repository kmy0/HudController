---@class (exact) Target : HudBase
---@field get_config fun(): TargetConfig
---@field children {
--- key: HudChild,
--- pin: HudChild,
--- background: HudChild,
--- life_line: HudChild,
--- }

---@class (exact) TargetConfig : HudBaseConfig
---@field children {
--- key: HudChildConfig,
--- pin: HudChildConfig,
--- background: HudChildConfig,
--- life_line: HudChildConfig,
--- }

---@class (exact) TargetControlArguments
---@field key PlayObjectGetterFn[]
---@field pin PlayObjectGetterFn[]
---@field background PlayObjectGetterFn[]
---@field life_line PlayObjectGetterFn[]

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Target
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- PNL_Scale
---@type TargetControlArguments
local control_arguments = {
    key = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_ref_Key_S00",
            },
        },
    },
    background = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_Base",
            },
        },
    },
    pin = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_ref_pin00",
            },
        },
    },
    life_line = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_graph",
            },
        },
    },
}

---@param args TargetConfig
---@return Target
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)

    ---@cast o Target
    o.children.pin = hud_child:new(args.children.pin, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.pin)
    end)
    o.children.key = hud_child:new(args.children.key, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.key)
    end)
    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.background)
    end)
    o.children.life_line = hud_child:new(args.children.life_line, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.life_line)
    end)
    return o
end

---@return TargetConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "TARGET"), "TARGET") --[[@as TargetConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.TARGET

    children.key = { name_key = "keybind", hide = false }
    children.pin = { name_key = "pin", hide = false }
    children.background = { name_key = "background", hide = false }
    children.life_line = { name_key = "life_line", hide = false }

    return base
end

return this
