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

---@class (exact) AmmoControlArguments
---@field keys PlayObjectGetterFn[]
---@field text PlayObjectGetterFn[]
---@field icons PlayObjectGetterFn[]
---@field energy PlayObjectGetterFn[]
---@field sp_ammo1 PlayObjectGetterFn[]
---@field sp_ammo2 PlayObjectGetterFn[]
---@field sp_ammo_frame PlayObjectGetterFn[]
---@field reload PlayObjectGetterFn[]
---@field mode_icon1 PlayObjectGetterFn[]
---@field mode_icon2 PlayObjectGetterFn[]
---@field bow_seperate PlayObjectGetterFn[]
---@field bow_icon_active PlayObjectGetterFn[]
---@field bow_icon_disable PlayObjectGetterFn[]

local bow_phials = require("HudController.hud.elements.ammo.bow_phials")
local ctrl_child = require("HudController.hud.def.ctrl_child")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

---@class Ammo
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- PNL_Scale
---@type AmmoControlArguments
local control_arguments = {
    keys = {
        {
            play_object.control.all,
            {
                "PNL_Pat00",
                "PNL_bulletSlider",
                "PNL_BSActive",
            },
            "PNL_ref_Key",
        },
        {
            play_object.control.all,
            {
                "PNL_Pat00",
                "PNL_BSActive1",
            },
            "PNL_ref_Key",
        },
        {
            play_object.control.all,
            {
                "PNL_Pat00",
                "PNL_change",
            },
            "PNL_ref_Key",
        },
    },
    icons = {
        {
            play_object.control.all,
            {
                "PNL_Pat00",
                "PNL_bulletSlider",
                "PNL_BSActive",
                "PNL_BSList",
            },
            "PNL_icon",
        },
    },
    text = {
        {
            play_object.control.get,
            { "PNL_itemName" },
        },
    },
    energy = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_energy",
            },
        },
    },
    sp_ammo1 = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_SPAmmoSet",
            },
        },
    },
    sp_ammo2 = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_SPAmmoSet2_2",
            },
        },
    },
    sp_ammo_frame = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_SPAmmoSet2_2",
                "PNL_SPA2Frame1",
            },
        },
    },
    reload = {
        {
            play_object.control.get,
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
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_change",
                "PNL_endRapid",
            },
        },
    },
    mode_icon2 = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_change",
                "PNL_changeArrow",
            },
        },
    },
    bow_seperate = {
        {
            play_object.control.all,
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
    -- PNL_bowSepaXX
    bow_icon_active = {
        {
            play_object.control.get,
            {
                "PNL_BowSP00",
                "PNL_iconActiveBow",
            },
        },
    },
    bow_icon_disable = {
        {
            play_object.child.get,
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

    o.children.keys = hud_child:new(args.children.keys, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.keys)
    end)
    o.children.text = ctrl_child:new(args.children.text, o, function(_, _, _, ctrl)
        local icons = play_object.iter_args(ctrl, control_arguments.icons)
        return play_object.iter_args(icons, control_arguments.text)
    end)
    o.children.energy = hud_child:new(args.children.energy, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.energy)
    end)
    o.children.sp_ammo1 = hud_child:new(args.children.sp_ammo1, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.sp_ammo1)
    end)
    o.children.sp_ammo2 = hud_child:new(args.children.sp_ammo2, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.sp_ammo2)
    end)
    o.children.sp_ammo_frame = hud_child:new(args.children.sp_ammo_frame, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.sp_ammo_frame)
    end)
    o.children.reload = hud_child:new(args.children.reload, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.reload)
    end)
    o.children.mode_icon1 = hud_child:new(args.children.mode_icon1, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.mode_icon1)
    end)
    o.children.mode_icon2 = hud_child:new(args.children.mode_icon2, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.mode_icon2)
    end)
    o.children.no_hide_parts = hud_child:new(args.children.no_hide_parts, o, function(_, _, _, ctrl)
        return ctrl
    end, function(_, ctrl)
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
                for _, c in pairs(child:ctrl_getter(nil, nil, ctrl)) do
                    ---@diagnostic disable-next-line: invisible
                    o:_set_opacity(c, 1.0)
                end
            end
        end

        return true
    end, nil, true)
    o.children.bow_icon = hud_child:new(args.children.bow_icon, o, function(_, _, _, ctrl)
        local separators = play_object.iter_args(ctrl, control_arguments.bow_seperate)
        local ret = {}
        util_table.array_merge_t(
            ret,
            play_object.iter_args(separators, control_arguments.bow_icon_active)
        )
        util_table.array_merge_t(
            ret,
            play_object.iter_args(separators, control_arguments.bow_icon_disable)
        )
        return ret
    end)
    o.children.bow_phials = bow_phials:new(args.children.bow_phials, o)

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
    local base = hud_base.get_config(e.get("app.GUIHudDef.TYPE").SLIDER_BULLET, "SLIDER_BULLET") --[[@as AmmoConfig]]
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
    children.no_hide_parts =
        { name_key = "__no_hide_parts", enabled_play_state = false, play_state = "" }
    children.bow_phials = bow_phials.get_config()

    return base
end

return this
