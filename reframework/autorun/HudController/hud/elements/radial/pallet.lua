---@class (exact) RadialPallet : HudChild
---@field get_config fun(): RadialPalletConfig
---@field expanded boolean
---@field children {
--- background: HudChild,
--- keys: HudChild,
--- text: HudChild,
--- frame: HudChild,
--- pallet_state: HudChild,
--- select: HudChild,
--- select_arrow: HudChild,
--- center: HudChild,
--- }

---@class (exact) RadialPalletConfig : HudChildConfig
---@field expanded boolean
---@field children {
--- background: HudChildConfig,
--- keys: HudChildConfig,
--- text: RadialPalletTextConfig,
--- frame: HudChildConfig,
--- pallet_state: HudChildConfig,
--- select: HudChildConfig,
--- select_arrow: HudChildConfig,
--- center: HudChildConfig,
--- }

---@class (exact) RadialPalletTextConfig : HudChildConfig
---@field children table<string, HudChildConfig>

---@class (exact) RadialPalletControlArguments
---@field keys PlayObjectGetterFn[]
---@field text PlayObjectGetterFn[]
---@field background PlayObjectGetterFn[]
---@field frame PlayObjectGetterFn[]
---@field pallet_state PlayObjectGetterFn[]
---@field center PlayObjectGetterFn[]
---@field icons RadialPalletIconControlArguments
---@field icon_center RadialPalletIconCenterControlArguments
---@field pallet PlayObjectGetterFn[]

---@class (exact) RadialPalletIconControlArguments
---@field icons PlayObjectGetterFn[]
---@field ps PlayObjectGetterFn[]
---@field keys PlayObjectGetterFn[]
---@field select PlayObjectGetterFn[]
---@field select_arrow PlayObjectGetterFn[]
---@field frame PlayObjectGetterFn[]

---@class (exact) RadialPalletIconCenterControlArguments
---@field icon PlayObjectGetterFn[]
---@field frame PlayObjectGetterFn[]

local frame_cache = require("HudController.util.misc.frame_cache")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local util_table = require("HudController.util.misc.table")

---@class RadialPallet
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

---@type RadialPalletControlArguments
local control_arguments = {
    background = {
        {
            play_object.control.get,
            {
                "PNL_Pallet",
                "PNL_PalletBlurBase",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_Pallet",
                "PNL_PalletSelect",
                "PNL_PSBase",
            },
        },
        {
            play_object.child.get,
            {
                "PNL_Pallet",
                "PNL_PalletMini",
                "PNL_PM_base",
            },
            "texset_PM_base",
            "via.gui.TextureSet",
        },
    },
    icon_center = {
        icon = {
            {
                play_object.control.get,
                {
                    "PNL_Pallet",
                    "PNL_PalletSelect",
                    "ICL_PSG",
                    "SCG_PS_C",
                    "ITM_PS_C",
                },
            },
        },
        frame = {
            {
                play_object.control.get,
                {
                    "PNL_base",
                },
            },
        },
    },
    icons = {
        icons = {
            {
                play_object.control.all,
                {
                    "PNL_Pallet",
                    "PNL_PalletSelect",
                    "ICL_PSG",
                },
                "SCG_PS_%d",
                true,
            },
        },
        ps = {
            {
                play_object.control.all,
                {},
                "ITM_PS_%d",
                true,
            },
        },
        frame = {
            {
                play_object.control.get,
                {
                    "PNL_PS_base",
                },
            },
        },
        keys = {
            {
                play_object.control.get,
                {
                    "PNL_ref_Key_S00",
                },
            },
        },
        select = {
            {
                play_object.child.get,
                {
                    "PNL_PS_Select",
                },
                "texset_base",
                "via.gui.TextureSet",
            },
        },
        select_arrow = {
            {
                play_object.control.all,
                {
                    "PNL_PS_Select",
                },
                "PNL_SArrow",
                true,
            },
        },
    },
    frame = {
        {
            play_object.child.get,
            {
                "PNL_Pallet",
                "PNL_PalletMini",
                "PNL_PM_base",
            },
            "mat_base00",
            "via.gui.Material",
        },
        {
            play_object.child.get,
            {
                "PNL_Pallet",
                "PNL_PalletMini",
                "PNL_PM_base",
            },
            "mat_base01",
            "via.gui.Material",
        },
        {
            play_object.child.get,
            {
                "PNL_Pallet",
                "PNL_PalletMini",
                "PNL_PM_base",
            },
            "mat_base02",
            "via.gui.Material",
        },
        {
            play_object.child.get,
            {
                "PNL_Pallet",
                "PNL_PalletMini",
                "PNL_PM_base",
            },
            "mat_base03",
            "via.gui.Material",
        },
    },
    keys = {
        {
            play_object.control.get,
            {
                "PNL_Pallet",
                "PNL_centerKey",
            },
        },
    },
    text = {
        {
            play_object.control.get,
            {
                "PNL_txtName",
            },
        },
    },
    pallet_state = {
        {
            play_object.control.get,
            {
                "PNL_Pallet",
            },
        },
    },
    center = {
        {
            play_object.control.get,
            {
                "PNL_Pallet",
                "PNL_PalletSelect",
                "ICL_PSG",
                "SCG_PS_C",
                "ITM_PS_C",
                "PNL_PS_Select_C",
            },
        },
    },
    pallet = {
        {
            play_object.control.get,
            {
                "PNL_PalletInOut",
            },
        },
    },
}

local pallet_expanded_states = {
    pallet_state = "SELECT",
}

---@param ctrl via.gui.Control
---@return via.gui.Control[]
local function get_pallet_icon_ps(ctrl)
    local icons = play_object.iter_args(ctrl, control_arguments.icons.icons)
    return play_object.iter_args(icons, control_arguments.icons.ps)
end

---@param ctrl via.gui.Control
---@return via.gui.Control
local function get_icl(ctrl)
    local pallet = play_object.control.get_parent(ctrl, "PNL_PalletInOut") --[[@as via.gui.Control]]
    return play_object.control.get(pallet, {
        "PNL_Pallet",
        "PNL_PalletSelect",
        "ICL_PSG",
    }) --[[@as via.gui.Control]]
end

---@param ctrl via.gui.Control
---@return via.gui.Control[]
local function get_pallet_icon_center(ctrl)
    return play_object.iter_args(ctrl, control_arguments.icon_center.icon)
end

---@param args RadialPalletConfig
---@param parent Radial
function this:new(args, parent)
    local o = hud_child:new(args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.pallet)
    end)
    setmetatable(o, self)
    ---@cast o RadialPallet

    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.background)
    end)
    o.children.frame = hud_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        return util_table.array_merge_t(
            play_object.iter_args(get_pallet_icon_ps(ctrl), control_arguments.icons.frame),
            play_object.iter_args(ctrl, control_arguments.frame),
            play_object.iter_args(get_pallet_icon_center(ctrl), control_arguments.icon_center.frame)
        )
    end)
    o.children.keys = hud_child:new(args.children.keys, o, function(s, hudbase, gui_id, ctrl)
        return util_table.array_merge_t(
            play_object.iter_args(get_pallet_icon_ps(ctrl), control_arguments.icons.keys),
            play_object.iter_args(ctrl, control_arguments.keys)
        )
    end)

    o.children.text = hud_child:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(get_pallet_icon_ps(ctrl), control_arguments.text)
    end)
    for i = 1, 8 do
        o.children.text.children["text" .. i] = hud_child:new(
            args.children.text.children["text" .. i],
            o.children.text,
            function(s, hudbase, gui_id, ctrl)
                local ps = play_object.control.get(get_icl(ctrl), { "SCG_PS_" .. i, "ITM_PS_" .. i }) --[[@as via.gui.Control]]
                return play_object.iter_args(ps, control_arguments.text)
            end
        )
    end

    o.children.select = hud_child:new(args.children.select, o, function(s, hudbase, gui_id, ctrl)
        --FIXME: icons 1, 3, 6, 8 don't have texset, it's probably not worth to filter those out?
        return play_object.iter_args(get_pallet_icon_ps(ctrl), control_arguments.icons.select)
    end)
    o.children.select_arrow = hud_child:new(args.children.select_arrow, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(get_pallet_icon_ps(ctrl), control_arguments.icons.select_arrow)
    end)
    o.children.center = hud_child:new(args.children.center, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.center)
    end)
    o.children.pallet_state = hud_child:new(args.children.pallet_state, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.pallet_state)
    end, nil, nil, true)

    if args.expanded then
        o:set_expanded(args.expanded)
    end
    return o
end

---@param val boolean
function this:set_expanded(val)
    if val then
        self:set_play_states(pallet_expanded_states)
    else
        self:reset_play_states(pallet_expanded_states)
    end
    self.expanded = val
end

---@return RadialPalletConfig
function this.get_config()
    local base = hud_child.get_config("pallet") --[[@as RadialPalletConfig]]
    local children = base.children

    base.expanded = false

    children.background = {
        name_key = "background",
        hide = false,
    }
    children.frame = {
        name_key = "frame",
        hide = false,
    }
    children.keys = {
        name_key = "keybind",
        hide = false,
    }
    children.select = {
        name_key = "select",
        hide = false,
    }
    children.select_arrow = {
        name_key = "select_arrow",
        hide = false,
    }
    children.center = {
        name_key = "center",
        hide = false,
    }
    children.pallet_state = { name_key = "__pallet_state", play_state = "" }

    children.text = {
        name_key = "text",
        hide = false,
        enabled_offset = false,
        offset = { x = 0, y = 0 },
        children = {},
    }

    for i = 1, 8 do
        children.text.children["text" .. i] = {
            name_key = "text" .. i,
            hide = false,
            enabled_offset = false,
            offset = { x = 0, y = 0 },
        }
    end

    return base
end

get_pallet_icon_ps = frame_cache.memoize(get_pallet_icon_ps)
get_icl = frame_cache.memoize(get_icl)
get_pallet_icon_center = frame_cache.memoize(get_pallet_icon_center)

return this
