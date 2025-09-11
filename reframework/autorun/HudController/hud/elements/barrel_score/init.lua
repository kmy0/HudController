---@class (exact) BarrelScore : HudBase
---@field get_config fun(): BarrelScoreConfig
---@field children {
--- points1: BarrelScorePoints,
--- points2: BarrelScorePoints,
--- name: BarrelScoreName,
--- }

---@class (exact) BarrelScoreConfig : HudBaseConfig
---@field children {
--- points1: BarrelScorePointsConfig,
--- points2: BarrelScorePointsConfig,
--- name: BarrelScoreNameConfig,
--- }

---@class (exact) BarrelScoreControlArguments
---@field points1 PlayObjectGetterFn[]
---@field points2 PlayObjectGetterFn[]

local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local name = require("HudController.hud.elements.barrel_score.name")
local play_object = require("HudController.hud.play_object.init")
local points = require("HudController.hud.elements.barrel_score.points")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class BarrelScore
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- PNL_Scale
---@type BarrelScoreControlArguments
local control_arguments = {
    points1 = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_First",
            },
        },
    },
    points2 = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_Second",
            },
        },
    },
}

---@param args BarrelScoreConfig
---@return BarrelScore
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)

    ---@cast o BarrelScore
    o.children.name = name:new(args.children.name, o)
    o.children.points1 = points:new(args.children.points1, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.points1)
    end)
    o.children.points2 = points:new(args.children.points2, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.points2)
    end)

    return o
end

---@return BarrelScoreConfig
function this.get_config()
    local base =
        hud_base.get_config(rl(ace_enum.hud, "BARREL_BOWLING_SCORE"), "BARREL_BOWLING_SCORE") --[[@as BarrelScoreConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.BARREL_BOWLING_SCORE

    children.name = name.get_config()
    children.points1 = points.get_config("points1")
    children.points2 = points.get_config("points2")

    return base
end

return this
