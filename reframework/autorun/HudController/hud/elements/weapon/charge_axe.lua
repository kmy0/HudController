---@class (exact) ChargeAxe : HudChild
---@field get_config fun(): ChargeAxeConfig
---@field children {
--- sword: HudChild,
--- shield: HudChild,
--- axe: HudChild,
--- phials: HudChild,
--- background: HudChild,
--- frame: HudChild,
---}

---@class (exact) ChargeAxeConfig : HudChildConfig
---@field children {
--- sword: HudChildConfig,
--- shield: HudChildConfig,
--- axe: HudChildConfig,
--- phials: HudChildConfig,
--- background: HudChildConfig,
--- frame: HudChildConfig,
--- }

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

---@class ChargeAxe
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- ctrl = PNL_Scale
local ctrl_args = {
    background = {
        {
            {
                "PNL_Pat00",
                "PNL_UnderBase",
            },
        },
    },
    axe = {
        {
            {
                "PNL_Pat00",
                "PNL_Axe",
            },
        },
    },
    shield = {
        {
            {
                "PNL_Pat00",
                "PNL_Shield",
            },
        },
    },
    sword = {
        {
            {
                "PNL_Pat00",
                "PNL_Blade",
            },
        },
    },
    frame = {
        {
            {
                "PNL_Pat00",
                "PNL_Frame",
            },
        },
    },
    phials = {
        {
            {
                "PNL_Pat00",
                "PNL_Bottles",
            },
        },
    },
}

---@param args ChargeAxeConfig
---@param parent HudBase
---@return ChargeAxe
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        if gui_id ~= rl(ace_enum.gui_id, "UI020034") then
            return {}
        end

        return ctrl
    end)
    setmetatable(o, self)
    ---@cast o ChargeAxe

    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.background)
    end)
    o.children.axe = hud_child:new(args.children.axe, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.axe)
    end)
    o.children.shield = hud_child:new(args.children.shield, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.shield)
    end)
    o.children.sword = hud_child:new(args.children.sword, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.sword)
    end)
    o.children.frame = hud_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.frame)
    end)
    o.children.phials = hud_child:new(args.children.phials, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.phials)
    end)

    return o
end

---@return ChargeAxeConfig
function this.get_config()
    local base = hud_child.get_config("CHARGE_AXE") --[[@as ChargeAxeConfig]]
    local children = base.children

    children.background = {
        name_key = "background",
        hide = false,
    }
    children.frame = {
        name_key = "frame",
        hide = false,
    }
    children.sword = hud_child.get_config("sword")
    children.shield = hud_child.get_config("shield")
    children.axe = hud_child.get_config("axe")
    children.phials = hud_child.get_config("phials")

    return base
end

return this
