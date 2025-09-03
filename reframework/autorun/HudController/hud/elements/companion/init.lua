---@class (exact) Companion : HudBase
---@field get_config fun(): CompanionConfig
---@field children {
--- player1: CompanionPlayer,
--- player2: CompanionPlayer,
--- player3: CompanionPlayer,
--- player4: CompanionPlayer,
--- }

---@class (exact) CompanionConfig : HudBaseConfig
---@field options {AUTO_SCALING_FELLOW_FITNESS: integer}
---@field children {
--- player1: CompanionPlayerConfig,
--- player2: CompanionPlayerConfig,
--- player3: CompanionPlayerConfig,
--- player4: CompanionPlayerConfig,
--- }

---@class (exact) CompanionControlArguments
---@field player1 PlayObjectGetterFn[]
---@field player2 PlayObjectGetterFn[]
---@field player3 PlayObjectGetterFn[]
---@field player4 PlayObjectGetterFn[]

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local play_object = require("HudController.hud.play_object")
local player = require("HudController.hud.elements.companion.player")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Companion
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- PNL_Scale
---@type CompanionControlArguments
local control_arguments = {
    player1 = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_player20",
            },
        },
    },
    player2 = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_player30",
            },
        },
    },
    player3 = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_player40",
            },
        },
    },
    player4 = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_player50",
            },
        },
    },
}

---@param args CompanionConfig
---@return Companion
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Companion

    o.children.player1 = player:new(args.children.player1, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.player1)
    end)
    o.children.player2 = player:new(args.children.player2, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.player2)
    end)
    o.children.player3 = player:new(args.children.player3, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.player3)
    end)
    o.children.player4 = player:new(args.children.player4, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.player4)
    end)

    return o
end

---@return CompanionConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "COMPANION"), "COMPANION") --[[@as CompanionConfig]]
    local children = base.children
    base.hud_type = mod.enum.hud_type.COMPANION
    base.options.AUTO_SCALING_FELLOW_FITNESS = -1

    children.player1 = player.get_config("player1")
    children.player2 = player.get_config("player2")
    children.player3 = player.get_config("player3")
    children.player4 = player.get_config("player4")

    return base
end

return this
