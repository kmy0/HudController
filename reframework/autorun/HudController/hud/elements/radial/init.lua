---@class (exact) Radial : HudBase
---@field get_config fun(): RadialConfig
---@field expanded boolean
---@field children {
--- pallet: RadialPallet,
--- craft: HudChild,
--- background: HudChild,
--- keys: HudChild,
--- text: HudChild,
--- frame: HudChild,
--- center: HudChild,
--- radial_state: HudChild,
--- select: HudChild,
--- select_base: HudChild,
--- }

---@class (exact) RadialConfig : HudBaseConfig
---@field expanded boolean
---@field children {
--- pallet: RadialPalletConfig,
--- craft: HudChildConfig,
--- background: HudChildConfig,
--- keys: HudChildConfig,
--- text: HudChildConfig,
--- frame: HudChildConfig,
--- center: HudChildConfig,
--- radial_state: HudChildConfig,
--- select: HudChildConfig,
--- select_base: HudChildConfig,
--- }

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local pallet = require("HudController.hud.elements.radial.pallet")
local play_object = require("HudController.hud.play_object")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Radial
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- ctrl = PNL_Scale
local ctrl_args = {
    pallet = {
        {
            {
                "PNL_PalletInOut",
            },
        },
    },
    icons = {
        {
            {
                "PNL_Pat00",
                "PNL_SC_A",
            },
            "PNL_frame",
            true,
        },
    },
    frame_icon = {
        {
            {
                "PNL_frame",
            },
        },
    },
    background_icon = {
        {
            {
                "PNL_base",
            },
        },
    },
    keys = {
        {
            {
                "PNL_Pat00",
                "PNL_center",
                "PNL_ref_Key_S00",
            },
        },
    },
    background = {
        {
            {
                "PNL_Pat00",
                "PNL_blurCircleMask",
            },
        },
    },
    background_tex = {
        {
            {
                "PNL_Pat00",
                "PNL_center",
            },
            "texset_shadow",
            "via.gui.TextureSet",
        },
    },
    text = {
        {
            {
                "PNL_Pat00",
                "PNL_Item",
            },
        },
    },
    craft = {
        {
            {
                "PNL_preparation",
            },
        },
    },
    center = {
        {
            {
                "PNL_Pat00",
                "PNL_center",
            },
        },
    },
    radial_state = {
        {
            "PNL_Pat00",
        },
    },
    select_icon = {
        {
            {
                "PNL_select",
                "PNL_angleS00",
            },
        },
        {
            {
                "PNL_select",
                "PNL_angleS01",
            },
        },
    },
    select_base_icon = {
        {
            {
                "PNL_select",
                "PNL_baseL0",
            },
        },
        {
            {
                "PNL_select",
                "PNL_baseR0",
            },
        },
    },
}

local radial_expanded_states = {
    radial_state = "SELECT",
}

---@param args RadialConfig
---@return Radial
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Radial

    o.children.keys = hud_child:new(args.children.keys, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.keys)
    end)
    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        local ret = {}
        for _, icon in pairs(play_object.iter_args(play_object.control.all, ctrl, ctrl_args.icons)) do
            ---@cast icon via.gui.Control
            util_table.array_merge_t(
                ret,
                play_object.iter_args(play_object.control.get, icon, ctrl_args.background_icon)
            )
        end

        return util_table.array_merge_t(
            ret,
            play_object.iter_args(play_object.control.get, ctrl, ctrl_args.background),
            play_object.iter_args(play_object.child.get, ctrl, ctrl_args.background_tex)
        )
    end)
    o.children.text = hud_child:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.text)
    end)
    o.children.center = hud_child:new(args.children.center, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.center)
    end)
    o.children.frame = hud_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        local ret = {}
        for _, icon in pairs(play_object.iter_args(play_object.control.all, ctrl, ctrl_args.icons)) do
            ---@cast icon via.gui.Control
            util_table.array_merge_t(ret, play_object.iter_args(play_object.control.get, icon, ctrl_args.frame_icon))
        end

        return ret
    end)
    o.children.select = hud_child:new(args.children.select, o, function(s, hudbase, gui_id, ctrl)
        local ret = {}
        for _, icon in pairs(play_object.iter_args(play_object.control.all, ctrl, ctrl_args.icons)) do
            ---@cast icon via.gui.Control
            util_table.array_merge_t(ret, play_object.iter_args(play_object.control.get, icon, ctrl_args.select_icon))
        end

        return ret
    end)
    o.children.select_base = hud_child:new(args.children.select_base, o, function(s, hudbase, gui_id, ctrl)
        local ret = {}
        for _, icon in pairs(play_object.iter_args(play_object.control.all, ctrl, ctrl_args.icons)) do
            ---@cast icon via.gui.Control
            util_table.array_merge_t(
                ret,
                play_object.iter_args(play_object.control.get, icon, ctrl_args.select_base_icon)
            )
        end

        return ret
    end)
    o.children.frame = hud_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        local ret = {}
        for _, icon in pairs(play_object.iter_args(play_object.control.all, ctrl, ctrl_args.icons)) do
            ---@cast icon via.gui.Control
            util_table.array_merge_t(ret, play_object.iter_args(play_object.control.get, icon, ctrl_args.frame_icon))
        end

        return ret
    end)
    o.children.radial_state = hud_child:new(args.children.radial_state, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.radial_state)
    end, nil, nil, true)

    o.children.pallet = pallet:new(args.children.pallet, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.pallet)
    end)
    o.children.craft = hud_child:new(args.children.craft, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.craft)
    end)

    if args.expanded then
        o:set_expanded(args.expanded)
    end
    return o
end

---@param val boolean
function this:set_expanded(val)
    if val then
        self:set_play_states(radial_expanded_states)
    else
        self:reset_play_states(radial_expanded_states)
    end
    self.expanded = val
end

---@return RadialConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "SHORTCUT_GAMEPAD"), "SHORTCUT_GAMEPAD") --[[@as RadialConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.RADIAL

    base.expanded = false

    children.keys = {
        name_key = "keybind",
        hide = false,
    }
    children.background = {
        name_key = "background",
        hide = false,
    }
    children.frame = {
        name_key = "frame",
        hide = false,
    }
    children.text = {
        name_key = "text",
        hide = false,
        enabled_offset = false,
        offset = { x = 0, y = 0 },
    }
    children.center = {
        name_key = "center",
        hide = false,
    }
    children.select = {
        name_key = "select",
        hide = false,
    }
    children.select_base = {
        name_key = "select_base",
        hide = false,
    }
    children.radial_state = { name_key = "__radial_state", play_state = "" }
    children.craft = hud_child.get_config("craft")
    children.pallet = pallet.get_config()

    return base
end

return this
