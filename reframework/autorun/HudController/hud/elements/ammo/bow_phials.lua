---@class (exact) AmmoBowPhial : HudChild
---@field get_config fun(): AmmoBowPhialConfig
---@field children {
--- light: HudChild,
--- arrow: CtrlChild,
--- phial: HudChild,
--- }

---@class (exact) AmmoBowPhialConfig : HudChildConfig
---@field children {
--- light: HudChildConfig,
--- arrow: CtrlChildConfig,
--- phial: HudChildConfig,
--- }

---@class (exact) AmmoBowPhialControlArguments
---@field light PlayObjectGetterFn[]
---@field arrow PlayObjectGetterFn[]
---@field phial PlayObjectGetterFn[]
---@field bow_phials PlayObjectGetterFn[]

local ctrl_child = require("HudController.hud.def.ctrl_child")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")

---@class AmmoBowPhial
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_BowBottlePlus
---@type AmmoBowPhialControlArguments
local control_arguments = {
    arrow = {
        {
            play_object.child.get,
            {
                "PNL_BowBottleAnim",
            },
            "tex_arrow",
            "via.gui.Texture",
        },
    },
    light = {
        {
            play_object.control.get,
            {
                "PNL_light",
            },
        },
    },
    phial = {
        {
            play_object.control.get,
            {
                "PNL_BowBottleAnim",
                "PNL_icon00",
            },
        },
    },
    bow_phials = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_energy",
                "PNL_ENGaugeSet",
                "PNL_frameBow",
                "PNL_BowBottlePlus",
            },
        },
    },
}

---@param args AmmoBowPhialConfig
---@param parent Ammo
---@return AmmoBowPhial
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.bow_phials)
    end)
    setmetatable(o, self)
    ---@cast o AmmoBowPhial

    o.children.arrow = ctrl_child:new(args.children.arrow, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.arrow)
    end)
    o.children.light = hud_child:new(args.children.light, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.light)
    end)
    o.children.phial = hud_child:new(args.children.phial, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.phial)
    end)

    return o
end

---@return AmmoBowPhialConfig
function this.get_config()
    local base = hud_child.get_config("bow_phials") --[[@as AmmoBowPhialConfig]]
    local children = base.children

    children.light = { name_key = "light", hide = false }
    children.arrow = { name_key = "arrow", hide = false }
    children.phial = { name_key = "phial", hide = false }

    return base
end

return this
