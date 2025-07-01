---@class (exact) Slinger : HudBase
---@field get_config fun(): SlingerConfig
---@field children {
--- text: HudChild,
--- background: CtrlChild,
--- frame: HudChild,
--- other_slinger: HudChild,
--- ammo: HudChild,
--- }

---@class (exact) SlingerConfig : HudBaseConfig
---@field children {
--- text: HudChildConfig,
--- frame: HudChildConfig,
--- background: CtrlChildConfig,
--- ammo: HudChildConfig,
--- other_slinger: HudChildConfig,
--- }

local ctrl_child = require("HudController.hud.def.ctrl_child")
local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Slinger
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- ctrl = PNL_Scale
local ctrl_args = {
    text = {
        {
            {
                "PNL_Pat00",
                "PNL_MainName",
            },
        },
    },
    background1 = {
        {
            {
                "PNL_Pat00",
                "PNL_MainObject",
                "PNL_Blur",
            },
        },
    },
    background2 = {
        {
            {
                "PNL_Pat00",
                "PNL_MainObject",
            },
            "tex_ItemBase",
            "via.gui.Texture",
        },
    },
    frame = {
        {
            {
                "PNL_Pat00",
                "PNL_MainObject",
                "PNL_Base",
            },
        },
    },
    other_slinger = {
        {
            {
                "PNL_Pat00",
                "PNL_KeepingObject",
            },
        },
    },
    ammo = {
        {
            {
                "PNL_Pat00",
                "PNL_MainObject",
                "PNL_Numbers",
            },
        },
        {
            {
                "PNL_Pat00",
                "PNL_MainObject",
                "PNL_NumbersUnlimited",
            },
        },
    },
}

---@param args SlingerConfig
---@return Slinger
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Slinger

    o.children.text = hud_child:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.text)
    end)
    o.children.frame = hud_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.frame)
    end)
    o.children.background = ctrl_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return util_table.array_merge_t(
            play_object.iter_args(play_object.control.get, ctrl, ctrl_args.background1),
            play_object.iter_args(play_object.child.get, ctrl, ctrl_args.background2)
        )
    end)
    o.children.ammo = hud_child:new(args.children.ammo, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.ammo)
    end)
    o.children.other_slinger = hud_child:new(args.children.other_slinger, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.other_slinger)
    end)

    return o
end

---@return SlingerConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "SLINGER"), "SLINGER") --[[@as SlingerConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.SLINGER

    children.text = { name_key = "text", hide = false }
    children.background = { name_key = "background", hide = false }
    children.frame = { name_key = "frame", hide = false }
    children.ammo = { name_key = "ammo", hide = false }
    children.other_slinger = { name_key = "other_slinger", hide = false }

    return base
end

return this
