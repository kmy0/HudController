---@class (exact) Whistle : HudChild
---@field get_config fun(): WhistleConfig
---@field children {
--- background: HudChild,
--- resonance: HudChild,
--- melody: HudChild,
--- notice: HudChild,
---}

---@class (exact) WhistleConfig : HudChildConfig
---@field children {
--- background: HudChildConfig,
--- resonance: HudChildConfig,
--- melody: HudChildConfig,
--- notice: HudChildConfig,
--- }

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

---@class Whistle
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- ctrl = PNL_All
local ctrl_args = {
    background = {
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_UnderBase",
            },
        },
    },
    resonance = {
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_Resonance",
            },
        },
    },
    melody = {
        {
            {
                "PNL_Scale1",
                "PNL_Pat00",
                "PNL_Melody",
            },
        },
    },
    notice = {
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_Score",
                "PNL_Notice",
            },
        },
    },
}

---@param args WhistleConfig
---@param parent HudBase
---@return Whistle
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        if gui_id ~= rl(ace_enum.gui_id, "UI020030") then
            return {}
        end

        return ctrl
    end)
    setmetatable(o, self)
    ---@cast o Whistle

    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.background)
    end)
    o.children.resonance = hud_child:new(args.children.resonance, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.resonance)
    end)
    o.children.melody = hud_child:new(args.children.melody, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.melody)
    end)
    o.children.notice = hud_child:new(args.children.notice, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.notice)
    end)

    return o
end

---@return WhistleConfig
function this.get_config()
    local base = hud_child.get_config("WHISTLE") --[[@as WhistleConfig]]
    local children = base.children

    children.background = {
        name_key = "background",
        hide = false,
    }
    children.resonance = hud_child.get_config("resonance")
    children.melody = hud_child.get_config("melody")
    children.notice = hud_child.get_config("notice")

    return base
end

return this
