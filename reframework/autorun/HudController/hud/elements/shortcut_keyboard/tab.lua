---@class (exact) ShortcutKeyboardTab : HudChild
---@field get_config fun(): ShortcutKeyboardTabConfig
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

---@class (exact) ShortcutKeyboardTabControlArguments
---@field icon PlayObjectGetterFn[]
---@field background PlayObjectGetterFn[]
---@field keybind PlayObjectGetterFn[]
---@field frame PlayObjectGetterFn[]
---@field cursor_background PlayObjectGetterFn[]
---@field tabs PlayObjectGetterFn[]

local ctrl_child = require("HudController.hud.def.ctrl_child")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

---@class ShortcutKeyboardTab
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

---@type ShortcutKeyboardTabControlArguments
local control_arguments = {
    background = {
        {
            play_object.child.get,
            {
                "PNL_UnSelectedBase",
            },
            "tex_Base",
            "via.gui.Texture",
        },
        {
            play_object.child.get,
            {
                "PNL_UnSelectedBase",
            },
            "tex_BaseAdjust",
            "via.gui.Texture",
        },
        {
            play_object.child.get,
            {
                "PNL_SelectedBase",
            },
            "tex_Base",
            "via.gui.Texture",
        },
        {
            play_object.child.get,
            {
                "PNL_SelectedBase",
            },
            "tex_BaseAdjust",
            "via.gui.Texture",
        },
    },
    cursor_background = {
        {
            play_object.control.get,
            {
                "PNL_cursor",
                "PNL_Glow",
                "PNL_cursorPattern",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_cursor",
                "PNL_Glow",
                "PNL_EffectColor",
            },
        },
    },
    frame = {
        {
            play_object.child.get,
            {
                "PNL_UnSelectedBase",
            },
            "s9g_Line",
            "via.gui.Scale9GridV2",
        },
        {
            play_object.child.get,
            {
                "PNL_SelectedBase",
            },
            "s9g_Line",
            "via.gui.Scale9GridV2",
        },
    },
    keybind = {
        {
            play_object.control.get,
            {
                "PNL_ItemIcon",
                "PNL_EachItem00",
                "PNL_ref_Key_S00",
            },
        },
    },
    icon = {
        {
            play_object.control.get,
            {
                "PNL_ItemIcon",
                "PNL_EachItem00",
                "PNL_ref_icon00",
            },
        },
    },
    tabs = {
        {
            play_object.control.all,
            {
                "PNL_Pat00",
                "PNL_Palette",
                "FSL_Tab00",
            },
            "Item",
        },
    },
}

---@param args ShortcutKeyboardTabConfig
---@param parent ShortcutKeyboard
---@return ShortcutKeyboardTab
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.tabs)
    end)
    setmetatable(o, self)
    ---@cast o ShortcutKeyboardTab

    o.children.keybind = hud_child:new(args.children.keybind, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.keybind)
    end)
    o.children.background = ctrl_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.background)
    end)
    o.children.frame = ctrl_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.frame)
    end)
    o.children.cursor_background = hud_child:new(args.children.cursor_background, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.cursor_background)
    end)
    o.children.icon = hud_child:new(args.children.icon, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.icon)
    end)

    return o
end

---@return ShortcutKeyboardTabConfig
function this.get_config()
    return {
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
end

return this
