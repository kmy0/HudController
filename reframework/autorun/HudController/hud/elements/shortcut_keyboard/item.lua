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
local util_game = require("HudController.util.game")

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
                "PNL_ref_Key_S00",
            },
        },
    },
    background = {
        {
            play_object.control.get,
            {
                "PNL_KeyBg",
            },
        },
    },
    text = {
        {
            play_object.control.get,
            {
                "PNL_ItemName",
            },
        },
    },
}

---@param args ShortcutKeyboardItemConfig
---@param parent ShortcutKeyboard
---@return ShortcutKeyboardItem
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        ---@cast hudbase app.GUI020600
        local ret = {}
        -- items are recreated every time ShortcutKeyboard is opened, so play_object.control.all cannot be used,
        util_game.do_something(hudbase._Frames, function(_, _, tabs)
            util_game.do_something(tabs, function(_, _, frame)
                if frame then
                    local shrt = frame:get__ShortcutItem()
                    local pnl = shrt:get__BasePanel()
                    table.insert(ret, play_object.control.get_parent(pnl, "PNL_itemAll", true))
                end
            end)
        end)

        return ret
    end)
    setmetatable(o, self)
    ---@cast o ShortcutKeyboardItem

    o.children.keybind = hud_child:new(args.children.keybind, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.keybind)
    end)
    o.children.background = hud_child:new(
        args.children.background,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.background)
        end
    )
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
