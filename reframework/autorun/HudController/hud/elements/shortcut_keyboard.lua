---@class (exact) ShortcutKeyboard : HudBase
---@field get_config fun(): ShortcutKeyboardConfig
---@field expanded boolean
---@field children {
--- background_blur: CtrlChild,
--- tab: ShortcutKeyboardTab,
--- item: ShortcutKeyboardItem,
--- pallet: ShortcutKeyboardPallet,
--- keybind: HudChild,
--- arrow: HudChild,
--- frame: CtrlChild,
--- }

---@class (exact) ShortcutKeyboardConfig : HudBaseConfig
---@field expanded boolean
---@field children {
--- background_blur: CtrlChildConfig,
--- tab: ShortcutKeyboardTabConfig,
--- item: ShortcutKeyboardItemConfig,
--- pallet: ShortcutKeyboardPalletConfig,
--- keybind: HudChildConfig,
--- arrow: HudChildConfig,
--- frame: CtrlChildConfig,
--- }

---@class (exact) ShortcutKeyboardTab : HudChild
---@field children {
--- background: CtrlChild,
--- keybind: HudChild,
--- icon: HudChild,
--- cursor_background: HudChild,
--- frame: CtrlChild,
--- }

---@class (exact) ShortcutKeyboardTabConfig : HudChildConfig
---@field children {
--- background: CtrlChildConfig,
--- keybind: HudChildConfig,
--- icon: HudChildConfig,
--- cursor_background: HudChildConfig,
--- frame: CtrlChildConfig,
--- }

---@class (exact) ShortcutKeyboardItem : HudChild
---@field children {
--- background: HudChild,
--- keybind: HudChild,
--- text: HudChild,
--- }

---@class (exact) ShortcutKeyboardItemConfig : HudChildConfig
---@field children {
--- background: HudChildConfig,
--- keybind: HudChildConfig,
--- text: HudChildConfig,
--- }

---@class (exact) ShortcutKeyboardPallet : HudChild
---@field children {
--- text: HudChild,
--- keybind: HudChild,
--- }

---@class (exact) ShortcutKeyboardPalletConfig : HudChildConfig
---@field children {
--- text: HudChildConfig,
--- keybind: HudChildConfig,
--- }

local ctrl_child = require("HudController.hud.def.ctrl_child")
local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class ShortcutKeyboard
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- ctrl = PNL_Scale
local ctrl_args = {
    background_blur = {
        {
            {
                "PNL_Pat00",
            },
            "mat_Blur_bg",
            "via.gui.Material",
        },
    },
    tabs = {
        {
            {
                "PNL_Pat00",
                "PNL_Palette",
                "FSL_Tab00",
            },
            "Item",
        },
    },
    tab_background = {
        {
            {
                "PNL_UnSelectedBase",
            },
            "tex_Base",
            "via.gui.Texture",
        },
        {
            {
                "PNL_UnSelectedBase",
            },
            "tex_BaseAdjust",
            "via.gui.Texture",
        },
        {
            {
                "PNL_SelectedBase",
            },
            "tex_Base",
            "via.gui.Texture",
        },
        {
            {
                "PNL_SelectedBase",
            },
            "tex_BaseAdjust",
            "via.gui.Texture",
        },
    },
    tab_cursor_background = {
        {
            {
                "PNL_cursor",
                "PNL_Glow",
                "PNL_cursorPattern",
            },
        },
        {
            {
                "PNL_cursor",
                "PNL_Glow",
                "PNL_EffectColor",
            },
        },
    },
    tab_frame = {
        {
            {
                "PNL_UnSelectedBase",
            },
            "s9g_Line",
            "via.gui.Scale9GridV2",
        },
        {
            {
                "PNL_SelectedBase",
            },
            "s9g_Line",
            "via.gui.Scale9GridV2",
        },
    },
    tab_key = {
        {
            {
                "PNL_ItemIcon",
                "PNL_EachItem00",
                "PNL_ref_Key_S00",
            },
        },
    },
    tab_icon = {
        {
            {
                "PNL_ItemIcon",
                "PNL_EachItem00",
                "PNL_ref_icon00",
            },
        },
    },
    frame = {
        {
            {
                "PNL_Pat00",
                "PNL_Palette",
                "FSL_Tab00",
            },
            "s9g_SideLineLeft",
            "via.gui.Scale9GridV2",
        },
        {
            {
                "PNL_Pat00",
                "PNL_Palette",
                "FSL_Tab00",
            },
            "s9g_SideLineRight",
            "via.gui.Scale9GridV2",
        },
    },
    pallet = {
        {
            {
                "PNL_Pat00",
                "PNL_Palette",
            },
        },
    },
    pallet_key = {
        {
            {
                "PNL_ref_Key_S02",
            },
        },
    },
    pallet_name = {
        {
            {
                "PNL_Common",
                "PNL_PalletName",
            },
        },
    },
    arrow = {
        {
            {
                "PNL_Pat00",
                "PNL_Palette",
                "PNL_Common",
                "PNL_Arrows",
            },
        },
    },
    item = {
        {
            {
                "PNL_Pat00",
                "PNL_Palette",
                "PNL_Main",
                "FSG_Keys",
            },
            "Item",
        },
    },
    item_key = {
        {
            {
                "PNL_itemAll",
                "PNL_ref_Key_S00",
            },
        },
    },
    item_background = {
        {
            {
                "PNL_itemAll",
                "PNL_KeyBg",
            },
        },
    },
    item_text = {
        {
            {
                "PNL_itemAll",
                "PNL_ItemName",
            },
        },
    },
}

---@param args ShortcutKeyboardConfig
---@return ShortcutKeyboard
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o ShortcutKeyboard

    o.children.background_blur = ctrl_child:new(args.children.background_blur, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.background_blur)
    end)
    o.children.arrow = hud_child:new(args.children.arrow, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.arrow)
    end)
    o.children.frame = ctrl_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.frame)
    end)

    o.children.tab = hud_child:new(args.children.tab, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.all, ctrl, ctrl_args.tabs)
    end) --[[@as ShortcutKeyboardTab]]
    o.children.tab.children.keybind = hud_child:new(
        args.children.tab.children.keybind,
        o.children.tab,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.tab_key)
        end
    )
    o.children.tab.children.background = ctrl_child:new(
        args.children.tab.children.background,
        o.children.tab,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.tab_background)
        end
    )
    o.children.tab.children.frame = ctrl_child:new(
        args.children.tab.children.frame,
        o.children.tab,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.tab_frame)
        end
    )
    o.children.tab.children.cursor_background = hud_child:new(
        args.children.tab.children.cursor_background,
        o.children.tab,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.tab_cursor_background)
        end
    )
    o.children.tab.children.icon = hud_child:new(
        args.children.tab.children.icon,
        o.children.tab,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.tab_icon)
        end
    )

    o.children.item = hud_child:new(args.children.item, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.all, ctrl, ctrl_args.item)
    end) --[[@as ShortcutKeyboardItem]]
    o.children.item.children.keybind = hud_child:new(
        args.children.item.children.keybind,
        o.children.item,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.item_key)
        end
    )
    o.children.item.children.background = hud_child:new(
        args.children.item.children.background,
        o.children.item,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.item_background)
        end
    )
    o.children.item.children.text = hud_child:new(
        args.children.item.children.text,
        o.children.item,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.item_text)
        end
    )

    o.children.pallet = hud_child:new(args.children.pallet, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.pallet)
    end) --[[@as ShortcutKeyboardPallet]]
    o.children.pallet.children.keybind = hud_child:new(
        args.children.pallet.children.keybind,
        o.children.pallet,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.pallet_key)
        end
    )
    o.children.pallet.children.text = hud_child:new(
        args.children.pallet.children.text,
        o.children.pallet,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.pallet_name)
        end
    )
    return o
end

---@return ShortcutKeyboardConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "SHORTCUT_KEYBOARD"), "SHORTCUT_KEYBOARD") --[[@as ShortcutKeyboardConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.SHORTCUT_KEYBOARD

    children.background_blur = {
        name_key = "background_blur",
        hide = false,
    }
    children.frame = {
        name_key = "frame",
        hide = false,
    }
    children.arrow = {
        name_key = "arrow",
        hide = false,
    }
    children.tab = {
        name_key = "tab",
        hide = false,
        children = {
            background = {
                name_key = "background",
                hide = false,
            },
            keybind = {
                name_key = "keybind",
                hide = false,
            },
            frame = {
                name_key = "frame",
                hide = false,
            },
            cursor_background = {
                name_key = "cursor_background",
                hide = false,
            },
            icon = {
                name_key = "icon",
                hide = false,
            },
        },
    }
    children.item = {
        name_key = "item",
        hide = false,
        children = {
            background = {
                name_key = "background",
                hide = false,
            },
            keybind = {
                name_key = "keybind",
                hide = false,
            },
            text = {
                name_key = "text",
                hide = false,
            },
        },
    }
    children.pallet = {
        name_key = "pallet",
        hide = false,
        children = {
            keybind = {
                name_key = "keybind",
                hide = false,
            },
            text = {
                name_key = "text",
                hide = false,
            },
        },
    }

    return base
end

return this
