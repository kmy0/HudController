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
--- text: HudChildConfig,
--- frame: HudChildConfig,
--- pallet_state: HudChildConfig,
--- select: HudChildConfig,
--- select_arrow: HudChildConfig,
--- center: HudChildConfig,
--- }

local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local util_table = require("HudController.util.misc.table")

---@class RadialPallet
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

local ctrl_args = {
    background = {
        {
            {
                "PNL_Pallet",
                "PNL_PalletBlurBase",
            },
        },
        {
            {
                "PNL_Pallet",
                "PNL_PalletSelect",
                "PNL_PSBase",
            },
        },
    },
    background_tex = {
        {
            {
                "PNL_Pallet",
                "PNL_PalletMini",
                "PNL_PM_base",
            },
            "texset_PM_base",
            "via.gui.TextureSet",
        },
    },
    icons = {
        {
            {
                "PNL_Pallet",
                "PNL_PalletSelect",
                "ICL_PSG",
            },
            "SCG_PS",
            true,
        },
    },
    ["icons.ps"] = {
        {
            {},
            "ITM_PS",
            true,
        },
    },
    frame_icon = {
        {
            {
                "PNL_PS_base",
            },
        },
        {
            {
                "PNL_base",
            },
        },
    },
    frame_mat = {
        {
            {
                "PNL_Pallet",
                "PNL_PalletMini",
                "PNL_PM_base",
            },
            "mat_base00",
            "via.gui.Material",
        },
        {
            {
                "PNL_Pallet",
                "PNL_PalletMini",
                "PNL_PM_base",
            },
            "mat_base01",
            "via.gui.Material",
        },
        {
            {
                "PNL_Pallet",
                "PNL_PalletMini",
                "PNL_PM_base",
            },
            "mat_base02",
            "via.gui.Material",
        },
        {
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
            {
                "PNL_Pallet",
                "PNL_centerKey",
            },
        },
    },
    keys_icon = {
        {
            {
                "PNL_ref_Key_S00",
            },
        },
    },
    text_icon = {
        {
            {
                "PNL_txtName",
            },
        },
    },
    pallet_state = {
        {
            {
                "PNL_Pallet",
            },
        },
    },
    select_icon = {
        {
            {
                "PNL_PS_Select",
            },
            "texset_base",
            "via.gui.TextureSet",
        },
    },
    select_arrow_icon = {
        {
            {
                "PNL_PS_Select",
            },
            "PNL_SArrow",
            true,
        },
    },
    center = {
        {
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
}

local pallet_expanded_states = {
    pallet_state = "SELECT",
}

---@param ctrl via.gui.Control
---@return via.gui.Control[]
local function get_pallet_icon_ps(ctrl)
    local icons = play_object.iter_args(play_object.control.all, ctrl, ctrl_args.icons)
    local ret = {}

    for _, icon in pairs(icons) do
        ---@cast icon via.gui.Control
        util_table.array_merge_t(ret, play_object.iter_args(play_object.control.all, icon, ctrl_args["icons.ps"]))
    end

    return ret
end

---@param args RadialPalletConfig
---@param parent Radial
---@param ctrl_getter fun(self: RadialPallet, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?
---@param ctrl_writer (fun(self: RadialPallet, ctrl: via.gui.Control): boolean)?
---@param default_overwrite HudBaseDefaultOverwrite?
---@param ignore boolean?
function this:new(args, parent, ctrl_getter, ctrl_writer, default_overwrite, ignore)
    local o = hud_child:new(args, parent, ctrl_getter, ctrl_writer, default_overwrite, ignore)
    setmetatable(o, self)
    ---@cast o RadialPallet

    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return util_table.array_merge_t(
            play_object.iter_args(play_object.control.get, ctrl, ctrl_args.background),
            play_object.iter_args(play_object.child.get, ctrl, ctrl_args.background_tex)
        )
    end)
    o.children.frame = hud_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        local icons = get_pallet_icon_ps(ctrl)
        local ret = {}
        for _, icon in pairs(icons) do
            ---@cast icon via.gui.Control
            util_table.array_merge_t(ret, play_object.iter_args(play_object.control.get, icon, ctrl_args.frame_icon))
        end

        return util_table.array_merge_t(ret, play_object.iter_args(play_object.child.get, ctrl, ctrl_args.frame_mat))
    end)
    o.children.keys = hud_child:new(args.children.keys, o, function(s, hudbase, gui_id, ctrl)
        local icons = get_pallet_icon_ps(ctrl)
        local ret = {}
        for _, icon in pairs(icons) do
            ---@cast icon via.gui.Control
            util_table.array_merge_t(ret, play_object.iter_args(play_object.control.get, icon, ctrl_args.keys_icon))
        end

        return util_table.array_merge_t(ret, play_object.iter_args(play_object.control.get, ctrl, ctrl_args.keys))
    end)
    o.children.text = hud_child:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        local icons = get_pallet_icon_ps(ctrl)
        local ret = {}
        for _, icon in pairs(icons) do
            ---@cast icon via.gui.Control
            util_table.array_merge_t(ret, play_object.iter_args(play_object.control.get, icon, ctrl_args.text_icon))
        end

        return ret
    end)
    o.children.select = hud_child:new(args.children.select, o, function(s, hudbase, gui_id, ctrl)
        local icons = get_pallet_icon_ps(ctrl)
        local ret = {}
        for _, icon in pairs(icons) do
            ---@cast icon via.gui.Control
            util_table.array_merge_t(ret, play_object.iter_args(play_object.child.get, icon, ctrl_args.select_icon))
        end

        return ret
    end)
    o.children.select_arrow = hud_child:new(args.children.select_arrow, o, function(s, hudbase, gui_id, ctrl)
        local icons = get_pallet_icon_ps(ctrl)
        local ret = {}
        for _, icon in pairs(icons) do
            ---@cast icon via.gui.Control
            util_table.array_merge_t(
                ret,
                play_object.iter_args(play_object.control.all, icon, ctrl_args.select_arrow_icon)
            )
        end

        return ret
    end)
    o.children.center = hud_child:new(args.children.center, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.center)
    end)
    o.children.pallet_state = hud_child:new(args.children.pallet_state, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.pallet_state)
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
    children.text = {
        name_key = "text",
        hide = false,
    }
    children.pallet_state = { name_key = "__pallet_state", play_state = "" }
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

    return base
end

return this
