---@class (exact) Ammo : HudBase
---@field get_config fun(): AmmoConfig
---@field no_hide_parts boolean
---@field children {
--- keys: HudChild,
--- text: CtrlChild,
--- energy: HudChild,
--- sp_ammo1: HudChild,
--- sp_ammo2: HudChild,
--- sp_ammo_frame: HudChild,
--- reload: HudChild,
--- mode_icon1: HudChild,
--- mode_icon2: HudChild,
--- no_hide_parts: HudChild,
--- bow_phials: AmmoBowPhial,
--- bow_icon: HudChild,
--- }

---@class (exact) AmmoBowPhial : HudChild
---@field children {
--- light: HudChild,
--- arrow: CtrlChild,
--- phial: HudChild,
--- }

---@class (exact) AmmoConfig : HudBaseConfig
---@field no_hide_parts boolean
---@field children {
--- keys: HudChildConfig,
--- text: CtrlChildConfig,
--- energy: HudChildConfig,
--- sp_ammo1: HudChildConfig,
--- sp_ammo2: HudChildConfig,
--- sp_ammo_frame: HudChildConfig,
--- reload: HudChildConfig,
--- mode_icon1: HudChildConfig,
--- mode_icon2: HudChildConfig,
--- no_hide_parts: HudChildConfig,
--- bow_phials: AmmoBowPhialConfig,
--- bow_icon: HudChildConfig,
--- }

---@class (exact) AmmoBowPhialConfig : HudChildConfig
---@field children {
--- light: HudChildConfig,
--- arrow: CtrlChildConfig,
--- phial: HudChildConfig,
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

---@class Ammo
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- ctrl = PNL_Scale
local ctrl_args = {
    keys = {
        {
            {
                "PNL_Pat00",
                "PNL_bulletSlider",
                "PNL_BSActive",
            },
            "PNL_ref_Key",
        },
        {
            {
                "PNL_Pat00",
                "PNL_BSActive1",
            },
            "PNL_ref_Key",
        },
        {
            {
                "PNL_Pat00",
                "PNL_change",
            },
            "PNL_ref_Key",
        },
    },
    text1 = {
        {
            {
                "PNL_Pat00",
                "PNL_bulletSlider",
                "PNL_BSActive",
                "PNL_BSList",
            },
            "PNL_icon",
        },
    },
    text2 = {
        {
            { "PNL_itemName" },
        },
    },
    energy = {
        {
            {
                "PNL_Pat00",
                "PNL_energy",
            },
        },
    },
    sp_ammo1 = {
        {
            {
                "PNL_Pat00",
                "PNL_SPAmmoSet",
            },
        },
    },
    sp_ammo2 = {
        {
            {
                "PNL_Pat00",
                "PNL_SPAmmoSet2_2",
            },
        },
    },
    sp_ammo_frame = {
        {
            {
                "PNL_Pat00",
                "PNL_SPAmmoSet2_2",
                "PNL_SPA2Frame1",
            },
        },
    },
    reload = {
        {
            {
                "PNL_Pat00",
                "PNL_bulletSlider",
                "PNL_BSActive",
                "PNL_reload",
            },
        },
    },
    mode_icon1 = {
        {
            {
                "PNL_Pat00",
                "PNL_change",
                "PNL_endRapid",
            },
        },
    },
    mode_icon2 = {
        {
            {
                "PNL_Pat00",
                "PNL_change",
                "PNL_changeArrow",
            },
        },
    },
    bow_phials = {
        {
            {
                "PNL_Pat00",
                "PNL_energy",
                "PNL_ENGaugeSet",
                "PNL_frameBow",
                "PNL_BowBottlePlus",
            },
        },
    },
    -- ctrl = PNL_BowBottlePlus
    ["bow_phials.arrow"] = {
        {
            {
                "PNL_BowBottleAnim",
            },
            "tex_arrow",
            "via.gui.Texture",
        },
    },
    ["bow_phials.light"] = {
        {
            {
                "PNL_light",
            },
        },
    },
    ["bow_phials.phial"] = {
        {
            {
                "PNL_BowBottleAnim",
                "PNL_icon00",
            },
        },
    },
    bow_seperate = {
        {
            {
                "PNL_Pat00",
                "PNL_energy",
                "PNL_ENGaugeSet",
                "PNL_bowSeparate",
            },
            "PNL_bowSepa",
            true,
        },
    },
    -- ctrl = PNL_bowSepaXX
    bow_icon_active = {
        {
            {
                "PNL_BowSP00",
                "PNL_iconActiveBow",
            },
        },
    },
    bow_icon_disable = {
        {
            {
                "PNL_BowSP00",
            },
            "tex_iconDisable",
            "via.gui.Texture",
        },
    },
}

---@param args AmmoConfig
---@return Ammo
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Ammo

    o.children.keys = hud_child:new(args.children.keys, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.all, ctrl, ctrl_args.keys)
    end)
    o.children.text = ctrl_child:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        local icons = play_object.iter_args(play_object.control.all, ctrl, ctrl_args.text1)
        local ret = {}
        util_table.do_something(icons, function(t, key, value)
            util_table.array_merge_t(
                ret,
                play_object.iter_args(play_object.control.get, value --[[@as via.gui.Control]], ctrl_args.text2)
            )
        end)
        return ret
    end)
    o.children.energy = hud_child:new(args.children.energy, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.energy)
    end)
    o.children.sp_ammo1 = hud_child:new(args.children.sp_ammo1, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.sp_ammo1)
    end)
    o.children.sp_ammo2 = hud_child:new(args.children.sp_ammo2, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.sp_ammo2)
    end)
    o.children.sp_ammo_frame = hud_child:new(args.children.sp_ammo_frame, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.sp_ammo_frame)
    end)
    o.children.reload = hud_child:new(args.children.reload, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.reload)
    end)
    o.children.mode_icon1 = hud_child:new(args.children.mode_icon1, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.mode_icon1)
    end)
    o.children.mode_icon2 = hud_child:new(args.children.mode_icon2, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.mode_icon2)
    end)
    o.children.no_hide_parts = hud_child:new(args.children.no_hide_parts, o, function(s, hudbase, gui_id, ctrl)
        return ctrl
    end, function(s, ctrl)
        -- if opacity is not forced there is a flicker sometimes
        for _, child in pairs({
            o.children.energy,
            o.children.reload,
            o.children.sp_ammo1,
            o.children.sp_ammo2,
            o.children.sp_ammo_frame,
        }) do
            if not child.hide and not child.opacity then
                ---@diagnostic disable-next-line: param-type-mismatch, invisible
                for _, c in pairs(child:_ctrl_getter(nil, nil, { ctrl })) do
                    self:_set_opacity(c, 1.0)
                end
            end
        end

        return true
    end, nil, true)
    o.children.bow_icon = hud_child:new(args.children.bow_icon, o, function(s, hudbase, gui_id, ctrl)
        local separators = play_object.iter_args(play_object.control.all, ctrl, ctrl_args.bow_seperate)
        local ret = {}

        for _, sep in pairs(separators) do
            ---@cast sep via.gui.Control
            util_table.array_merge_t(
                ret,
                play_object.iter_args(play_object.control.get, sep, ctrl_args.bow_icon_active)
            )
            util_table.array_merge_t(ret, play_object.iter_args(play_object.child.get, sep, ctrl_args.bow_icon_disable))
        end

        return ret
    end)

    o.children.bow_phials = hud_child:new(args.children.bow_phials, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.bow_phials)
    end) --[[@as AmmoBowPhial]]
    o.children.bow_phials.children.arrow = ctrl_child:new(
        args.children.bow_phials.children.arrow,
        o.children.bow_phials,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.child.get, ctrl, ctrl_args["bow_phials.arrow"])
        end
    )
    o.children.bow_phials.children.light = hud_child:new(
        args.children.bow_phials.children.light,
        o.children.bow_phials,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args["bow_phials.light"])
        end
    )
    o.children.bow_phials.children.phial = hud_child:new(
        args.children.bow_phials.children.phial,
        o.children.bow_phials,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args["bow_phials.phial"])
        end
    )

    o.hide_write = true
    if args.no_hide_parts then
        o:set_no_hide_parts(args.no_hide_parts)
    end

    return o
end

---@param no_hide boolean
function this:set_no_hide_parts(no_hide)
    if no_hide then
        self.children.no_hide_parts:set_play_state("dummy")
    else
        self.children.no_hide_parts:set_play_state()
    end
    self.no_hide_parts = no_hide
end

---@return AmmoConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "SLIDER_BULLET"), "SLIDER_BULLET") --[[@as AmmoConfig]]
    local children = base.children

    base.no_hide_parts = false
    base.hud_type = mod.enum.hud_type.AMMO

    children.keys = { name_key = "keybind", hide = false }
    children.text = { name_key = "text", hide = false }
    children.sp_ammo_frame = { name_key = "sp_ammo_frame", hide = false }
    children.energy = hud_child.get_config("energy")
    children.sp_ammo1 = hud_child.get_config("sp_ammo1")
    children.sp_ammo2 = hud_child.get_config("sp_ammo2")
    children.reload = hud_child.get_config("reload")
    children.mode_icon1 = hud_child.get_config("mode_icon1")
    children.mode_icon2 = hud_child.get_config("mode_icon2")
    children.bow_icon = { name_key = "bow_icon", hide = false }
    children.no_hide_parts = { name_key = "__no_hide_parts", enabled_play_state = false, play_state = "" }

    children.bow_phials = hud_child.get_config("bow_phials") --[[@as AmmoBowPhialConfig]]
    local phial_children = children.bow_phials.children
    phial_children.light = { name_key = "light", hide = false }
    phial_children.arrow = { name_key = "arrow", hide = false }
    phial_children.phial = { name_key = "phial", hide = false }

    return base
end

return this
