---@class (exact) GunReticle : HudBase
---@field get_config fun(): GunReticleConfig
---@field children {
--- reticle: HudChild,
--- ammo: HudChild,
--- reload: HudChild,
--- out_of_range: HudChild,
--- }

---@class (exact) GunReticleConfig : HudBaseConfig
---@field children {
--- reticle: HudChildConfig,
--- ammo: HudChildConfig,
--- reload: HudChildConfig,
--- out_of_range: HudChildConfig,
--- }

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class GunReticle
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- ctrl = PNL_Scale
local ctrl_args = {
    reticle = {
        {
            {
                "PNL_Pat00",
                "PNL_BowgunReticle",
                "PNL_Reticle",
            },
        },
    },
    ammo = {
        {
            {
                "PNL_Pat00",
                "PNL_BowgunReticle",
                "PNL_Ammo",
            },
        },
    },
    reload = {
        {
            {
                "PNL_Pat00",
                "PNL_BowgunReticle",
                "PNL_AddText",
                "PNL_Reload",
            },
        },
    },
    out_of_range = {
        {
            {
                "PNL_Pat00",
                "PNL_BowgunReticle",
                "PNL_AddText",
                "PNL_OutOfRange",
            },
        },
    },
}

---@param args GunReticleConfig
---@return GunReticle
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o GunReticle

    o.children.reticle = hud_child:new(args.children.reticle, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.reticle)
    end)
    o.children.ammo = hud_child:new(args.children.ammo, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.ammo)
    end)
    o.children.reload = hud_child:new(args.children.reload, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.reload)
    end)
    o.children.out_of_range = hud_child:new(args.children.out_of_range, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.out_of_range)
    end)
    return o
end

---@return GunReticleConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "GUN_RETICLE"), "GUN_RETICLE") --[[@as GunReticleConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.GUN_RETICLE

    children.reticle = hud_child.get_config("reticle")
    children.ammo = hud_child.get_config("ammo")
    children.out_of_range = hud_child.get_config("out_of_range")
    children.reload = hud_child.get_config("reload")

    return base
end
return this
