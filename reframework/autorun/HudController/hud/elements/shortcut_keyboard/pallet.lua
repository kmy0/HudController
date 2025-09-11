---@class (exact) ShortcutKeyboardPallet : HudChild
---@field get_config fun(): ShortcutKeyboardPalletConfig
---@field children {
--- text: HudChild,
--- keybind: HudChild,
--- }

---@class (exact) ShortcutKeyboardPalletConfig : HudChildConfig
---@field children {
--- text: HudChildConfig,
--- keybind: HudChildConfig,
--- }

---@class (exact) ShortcutKeyboardPalletControlArguments
---@field text PlayObjectGetterFn[]
---@field keybind PlayObjectGetterFn[]
---@field pallet PlayObjectGetterFn[]

local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")

---@class ShortcutKeyboardPallet
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

---@type ShortcutKeyboardPalletControlArguments
local control_arguments = {
    text = {
        {
            play_object.control.get,
            {
                "PNL_ref_Key_S02",
            },
        },
    },
    keybind = {
        {
            play_object.control.get,
            {
                "PNL_Common",
                "PNL_PalletName",
            },
        },
    },
    pallet = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_Palette",
            },
        },
    },
}

---@param args ShortcutKeyboardPalletConfig
---@param parent ShortcutKeyboard
---@return ShortcutKeyboardPallet
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.pallet)
    end)
    setmetatable(o, self)
    ---@cast o ShortcutKeyboardPallet

    o.children.keybind = hud_child:new(args.children.keybind, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.keybind)
    end)
    o.children.text = hud_child:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text)
    end)

    return o
end

---@return ShortcutKeyboardPalletConfig
function this.get_config()
    return {
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
end

return this
