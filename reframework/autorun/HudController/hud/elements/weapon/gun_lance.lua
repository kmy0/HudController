---@class (exact) GunLance : HudChild
---@field get_config fun(): GunLanceConfig
---@field children {
--- ammo: HudChild,
--- pile: HudChild,
--- gauge: HudChild,
--- background: HudChild,
--- frame: HudChild,
---}

---@class (exact) GunLanceConfig : HudChildConfig
---@field children {
--- background: HudChildConfig,
--- frame: HudChildConfig,
--- ammo: HudChildConfig,
--- pile: HudChildConfig,
--- gauge: HudChildConfig,
--- }

---@class (exact) GunLanceControlArguments
---@field background PlayObjectGetterFn[]
---@field frame PlayObjectGetterFn[]
---@field ammo PlayObjectGetterFn[]
---@field pile PlayObjectGetterFn[]
---@field gauge PlayObjectGetterFn[]

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

---@class GunLance
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_Scale
---@type GunLanceControlArguments
local control_arguments = {
    background = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_UnderBase",
            },
        },
    },
    frame = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_frame",
            },
        },
    },
    ammo = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_ammoSet",
            },
        },
    },
    pile = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_pile",
            },
        },
    },
    gauge = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_gaugeFire",
            },
        },
    },
}

---@param args GunLanceConfig
---@param parent HudBase
---@return GunLance
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        if gui_id ~= rl(ace_enum.gui_id, "UI020024") then
            return {}
        end

        return ctrl
    end)
    setmetatable(o, self)
    ---@cast o GunLance

    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.background)
    end)
    o.children.frame = hud_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.frame)
    end)
    o.children.ammo = hud_child:new(args.children.ammo, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.ammo)
    end)
    o.children.pile = hud_child:new(args.children.pile, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.pile)
    end)
    o.children.gauge = hud_child:new(args.children.gauge, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.gauge)
    end)
    return o
end

---@return GunLanceConfig
function this.get_config()
    local base = hud_child.get_config("GUN_LANCE") --[[@as GunLanceConfig]]
    local children = base.children

    children.background = {
        name_key = "background",
        hide = false,
    }
    children.ammo = hud_child.get_config("ammo")
    children.pile = hud_child.get_config("pile")
    children.gauge = hud_child.get_config("gauge")
    children.frame = {
        name_key = "frame",
        hide = false,
    }

    return base
end

return this
