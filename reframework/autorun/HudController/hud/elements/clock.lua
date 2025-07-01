---@class (exact) Clock : HudBase
---@field get_config fun(): ClockConfig
---@field children {text: HudChild, background: HudChild, frame: HudChild}

---@class (exact) ClockConfig : HudBaseConfig
---@field children {
--- text: HudChildConfig,
--- frame: HudChildConfig,
--- background: HudChildConfig,
--- }

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Clock
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- ctrl = PNL_Scale
local ctrl_args = {
    text = {
        {
            {
                "PNL_Pat01",
                "PNL_EnvName",
            },
        },
        {
            {
                "PNL_Pat01",
                "PNL_TimeName",
            },
        },
    },
    background = {
        {
            {
                "PNL_Pat01",
                "PNL_Base",
            },
        },
    },
    frame = {
        {
            {
                "PNL_Pat01",
                "PNL_Frame",
            },
        },
    },
}

---@param args ClockConfig
---@return Clock
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Clock

    o.children.text = hud_child:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.text)
    end)
    o.children.frame = hud_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.frame)
    end)
    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.background)
    end)

    return o
end

---@return ClockConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "CLOCK"), "CLOCK") --[[@as ClockConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.CLOCK

    children.text = { name_key = "text", hide = false }
    children.background = { name_key = "background", hide = false }
    children.frame = { name_key = "frame", hide = false }

    return base
end

return this
