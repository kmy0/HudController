---@class (exact) ShortcutKeyboardItem : HudChild
---@field get_config fun(): ShortcutKeyboardItemConfig
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

---@class (exact) ShortcutKeyboardItemControlArguments
---@field text PlayObjectGetterFn[]
---@field background PlayObjectGetterFn[]
---@field keybind PlayObjectGetterFn[]

local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

---@class ShortcutKeyboardItem
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

---@type ShortcutKeyboardItemControlArguments
local control_arguments = {
    keybind = {
        {
            play_object.control.get,
            {
                "PNL_itemAll",
                "PNL_ref_Key_S00",
            },
        },
    },
    background = {
        {
            play_object.control.get,
            {
                "PNL_itemAll",
                "PNL_KeyBg",
            },
        },
    },
    text = {
        {
            play_object.control.get,
            {
                "PNL_itemAll",
                "PNL_ItemName",
            },
        },
    },
}

---@param args ShortcutKeyboardItemConfig
---@param parent ShortcutKeyboard
---@param ctrl_getter fun(self: HudChild, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): PlayObject[] | PlayObject?
---@return ShortcutKeyboardItem
function this:new(args, parent, ctrl_getter)
    local o = hud_child.new(self, args, parent, ctrl_getter)
    setmetatable(o, self)
    ---@cast o ShortcutKeyboardItem

    o.children.keybind = hud_child:new(args.children.keybind, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.keybind)
    end)
    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.background)
    end)
    o.children.text = hud_child:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text)
    end)

    return o
end

---@return ShortcutKeyboardItemConfig
function this.get_config()
    return {
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
end

return this
