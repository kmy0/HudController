---@class (exact) BowReticle : HudBase
---@field get_config fun(): BowReticleConfig
---@field children {
--- reticle_main: HudChild,
--- reticle_lockon: HudChild,
--- phials: HudChild,
--- out_of_range: HudChild,
--- lockon: HudChild,
--- }

---@class (exact) BowReticleConfig : HudBaseConfig
---@field children {
--- reticle_main: HudChildConfig,
--- reticle_lockon: HudChildConfig,
--- phials: HudChildConfig,
--- out_of_range: HudChildConfig,
--- lockon: HudChildConfig,
--- }

---@class (exact) BowReticleControlArguments
---@field reticle_main PlayObjectGetterFn[]
---@field reticle_lockon PlayObjectGetterFn[]
---@field phials PlayObjectGetterFn[]
---@field out_of_range PlayObjectGetterFn[]
---@field lockon PlayObjectGetterFn[]

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class BowReticle
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- PNL_Scale
---@type BowReticleControlArguments
local control_arguments = {
    reticle_main = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_ReticleMain",
            },
        },
    },
    reticle_lockon = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_ReticleLockOn",
            },
        },
    },
    phials = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_Ammo",
            },
        },
    },
    lockon = {
        {
            play_object.control.get,
            {
                "PNL_Pat01",
            },
        },
    },
    out_of_range = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_AddText",
                "PNL_OutOfRange",
            },
        },
    },
}

---@param args BowReticleConfig
---@return BowReticle
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o BowReticle

    o.children.reticle_main = hud_child:new(
        args.children.reticle_main,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.reticle_main)
        end
    )
    o.children.reticle_lockon = hud_child:new(
        args.children.reticle_lockon,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.reticle_lockon)
        end
    )
    o.children.lockon = hud_child:new(args.children.lockon, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.lockon)
    end)
    o.children.phials = hud_child:new(args.children.phials, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.phials)
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

---@return BowReticleConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "BOW_RETICLE"), "BOW_RETICLE") --[[@as BowReticleConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.BOW_RETICLE

    children.reticle_main = hud_child.get_config("reticle_main")
    children.reticle_lockon = hud_child.get_config("reticle_lockon")
    children.phials = hud_child.get_config("phial")
    children.out_of_range = hud_child.get_config("out_of_range")
    children.lockon = hud_child.get_config("lockon")

    return base
end
return this
