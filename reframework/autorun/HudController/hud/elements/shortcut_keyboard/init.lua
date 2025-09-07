---@class (exact) ShortcutKeyboard : HudBase
---@field get_config fun(): ShortcutKeyboardConfig
---@field expanded boolean
---@field children {
--- background_blur: CtrlChild,
--- tab: ShortcutKeyboardTab,
--- item: ShortcutKeyboardItem,
--- pallet: ShortcutKeyboardPallet,
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

---@class (exact) ShortcutKeyboardControlArguments
---@field background_blur PlayObjectGetterFn[]
---@field arrow PlayObjectGetterFn[]
---@field frame PlayObjectGetterFn[]

local ctrl_child = require("HudController.hud.def.ctrl_child")
local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local item = require("HudController.hud.elements.shortcut_keyboard.item")
local pallet = require("HudController.hud.elements.shortcut_keyboard.pallet")
local play_object = require("HudController.hud.play_object")
local tab = require("HudController.hud.elements.shortcut_keyboard.tab")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class ShortcutKeyboard
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- PNL_Scale
---@type ShortcutKeyboardControlArguments
local control_arguments = {
    background_blur = {
        {
            play_object.child.get,
            {
                "PNL_Pat00",
            },
            "mat_Blur_bg",
            "via.gui.Material",
        },
    },
    frame = {
        {
            play_object.child.get,
            {
                "PNL_Pat00",
                "PNL_Palette",
                "FSL_Tab00",
            },
            "s9g_SideLineLeft",
            "via.gui.Scale9GridV2",
        },
        {
            play_object.child.get,
            {
                "PNL_Pat00",
                "PNL_Palette",
                "FSL_Tab00",
            },
            "s9g_SideLineRight",
            "via.gui.Scale9GridV2",
        },
    },
    arrow = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_Palette",
                "PNL_Common",
                "PNL_Arrows",
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

    o.children.background_blur = ctrl_child:new(
        args.children.background_blur,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.background_blur)
        end
    )
    o.children.arrow = hud_child:new(args.children.arrow, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.arrow)
    end)
    o.children.frame = ctrl_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.frame)
    end)
    o.children.tab = tab:new(args.children.tab, o)
    o.children.item = item:new(args.children.item, o)
    o.children.pallet = pallet:new(args.children.pallet, o)

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

    children.tab = tab.get_config()
    children.item = item.get_config()
    children.pallet = pallet.get_config()

    return base
end

return this
