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

---@class (exact) GunReticleControlArguments
---@field reticle PlayObjectGetterFn[]
---@field ammo PlayObjectGetterFn[]
---@field reload PlayObjectGetterFn[]
---@field out_of_range PlayObjectGetterFn[]

local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class GunReticle
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- PNL_Scale
local control_arguments = {
    reticle = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_BowgunReticle",
                "PNL_Reticle",
            },
        },
    },
    ammo = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_BowgunReticle",
                "PNL_Ammo",
            },
        },
    },
    reload = {
        {
            play_object.control.get,
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
            play_object.control.get,
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
        return play_object.iter_args(ctrl, control_arguments.reticle)
    end)
    o.children.ammo = hud_child:new(args.children.ammo, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.ammo)
    end)
    o.children.reload = hud_child:new(args.children.reload, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.reload)
    end)
    o.children.out_of_range = hud_child:new(
        args.children.out_of_range,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.out_of_range)
        end
    )
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
