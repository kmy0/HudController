---@class (exact) Control : HudBase
---@field get_config fun(): ControlConfig
---@field children {
--- music_left: HudChild,
--- music_right: HudChild,
--- notes: HudChild,
--- control_guide1: HudChild,
--- control_guide2: HudChild,
--- skill_name: HudChild,
--- }

---@class (exact) ControlConfig : HudBaseConfig
---@field children {
--- music_left: HudChildConfig,
--- music_right: HudChildConfig,
--- notes: HudChildConfig,
--- control_guide1: HudChildConfig,
--- control_guide2: HudChildConfig,
--- skill_name: HudChildConfig,
--- }

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Control
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- ctrl = PNL_Scale
local ctrl_args = {
    music_left = {
        {
            {
                "PNL_Pat02",
                "PNL_MusicFolder01",
            },
        },
    },
    music_right = {
        {
            {
                "PNL_Pat02",
                "PNL_MusicFolder00",
            },
        },
    },
    notes = {
        {
            {
                "PNL_Pat02",
                "PNL_SampleNotes",
            },
        },
    },
    control_guide1 = {
        {
            {
                "PNL_Pat00",
                "PNL_ControlGuide00",
            },
        },
    },
    control_guide2 = {
        {
            {
                "PNL_Pat00",
                "PNL_ControlGuide01",
            },
        },
    },
    skill_name = {
        {
            {
                "PNL_Pat01",
                "PNL_SkillName",
            },
        },
    },
}

---@param args ControlConfig
---@return Control
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Control

    o.children.music_left = hud_child:new(args.children.music_left, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.music_left)
    end)
    o.children.music_right = hud_child:new(args.children.music_right, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.music_right)
    end)
    o.children.notes = hud_child:new(args.children.notes, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.notes)
    end)
    o.children.control_guide1 = hud_child:new(args.children.control_guide1, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.control_guide1)
    end)
    o.children.control_guide2 = hud_child:new(args.children.control_guide2, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.control_guide2)
    end)
    o.children.skill_name = hud_child:new(args.children.skill_name, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.skill_name)
    end)

    return o
end

---@return ControlConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "CONTROL"), "CONTROL") --[[@as ControlConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.CONTROL

    children.music_left = hud_child.get_config("music_left")
    children.music_right = hud_child.get_config("music_right")
    children.notes = hud_child.get_config("notes")
    children.control_guide1 = hud_child.get_config("control_guide1")
    children.control_guide2 = hud_child.get_config("control_guide2")
    children.skill_name = hud_child.get_config("skill_name")

    return base
end

return this
