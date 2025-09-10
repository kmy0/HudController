---@class (exact) ShortcutKeyboard : HudBase
---@field get_config fun(): ShortcutKeyboardConfig
---@field no_hide_elements boolean
---@field GUI020600 app.GUI020600
---@field open_timer FrameTimer
---@field children {
--- background_blur: CtrlChild,
--- tab: ShortcutKeyboardTab,
--- item: ShortcutKeyboardItem,
--- pallet: ShortcutKeyboardPallet,
--- arrow: HudChild,
--- frame: CtrlChild,
--- }

---@class (exact) ShortcutKeyboardConfig : HudBaseConfig
---@field no_hide_elements boolean
---@field children {
--- background_blur: CtrlChildConfig,
--- tab: ShortcutKeyboardTabConfig,
--- item: ShortcutKeyboardItemConfig,
--- pallet: ShortcutKeyboardPalletConfig,
--- keybind: HudChildConfig,
--- arrow: HudChildConfig,
--- frame: CtrlChildConfig,
--- }

---@class (exact) ShortcutKeyboardChangedProperties : HudChildChangedProperties
---@field no_hide_elements boolean?

---@class (exact) ShortcutKeyboardProperties : {[ShortcutKeyboardProperty]: boolean}, HudChildProperties
---@field no_hide_elements boolean

---@alias ShortcutKeyboardProperty HudChildProperty | "no_hide_elements"

---@class (exact) ShortcutKeyboardControlArguments
---@field background_blur PlayObjectGetterFn[]
---@field arrow PlayObjectGetterFn[]
---@field frame PlayObjectGetterFn[]

local ctrl_child = require("HudController.hud.def.ctrl_child")
local data = require("HudController.data")
local frame_timer = require("HudController.util.misc.frame_timer")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local item = require("HudController.hud.elements.shortcut_keyboard.item")
local pallet = require("HudController.hud.elements.shortcut_keyboard.pallet")
local play_object = require("HudController.hud.play_object")
local tab = require("HudController.hud.elements.shortcut_keyboard.tab")
local util_game = require("HudController.util.game")
local util_table = require("HudController.util.misc.table")
local uuid = require("HudController.util.misc.uuid")

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

    o.properties = util_table.merge_t(o.properties, {
        no_hide_elements = true,
    })
    o.open_timer = frame_timer.new(uuid.generate(), 15, nil, true)

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

    o.no_hide_elements = args.no_hide_elements
    return o
end

---@param val boolean
function this:set_no_hide_elements(val)
    self.no_hide_elements = val
end

function this:get_GUI020600()
    if not self.GUI020600 then
        self.GUI020600 = util_game.get_component_any("app.GUI020600") --[[@as app.GUI020600]]
    end

    return self.GUI020600
end

function this:is_open()
    local is_open = self:get_GUI020600()._IsOpen
    if is_open then
        self.open_timer:restart()
    end

    return is_open or not self.open_timer:update()
end

---@return ShortcutKeyboardConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "SHORTCUT_KEYBOARD"), "SHORTCUT_KEYBOARD") --[[@as ShortcutKeyboardConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.SHORTCUT_KEYBOARD

    base.no_hide_elements = false
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
