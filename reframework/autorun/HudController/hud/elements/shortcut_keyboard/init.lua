---@class (exact) ShortcutKeyboard : HudBase
---@field get_config fun(): ShortcutKeyboardConfig
---@field no_hide_elements boolean
---@field always_visible boolean
---@field GUI020600 app.GUI020600
---@field open_timer FrameTimer
---@field always_visible_delay_timer Timer
---@field children {
--- background_blur: CtrlChild,
--- tab: ShortcutKeyboardTab,
--- item: ShortcutKeyboardItem,
--- pallet: ShortcutKeyboardPallet,
--- arrow: HudChild,
--- frame: CtrlChild,
--- prepare: ShortcutKeyboardPrepare,
--- line_cursor: HudChild,
--- }

---@class (exact) ShortcutKeyboardConfig : HudBaseConfig
---@field no_hide_elements boolean
---@field always_visible boolean
---@field children {
--- background_blur: CtrlChildConfig,
--- tab: ShortcutKeyboardTabConfig,
--- item: ShortcutKeyboardItemConfig,
--- pallet: ShortcutKeyboardPalletConfig,
--- keybind: HudChildConfig,
--- arrow: HudChildConfig,
--- frame: CtrlChildConfig,
--- prepare: ShortcutKeyboardPrepareConfig,
--- line_cursor: HudChildConfig,
--- }

---@class (exact) ShortcutKeyboardChangedProperties : HudChildChangedProperties
---@field no_hide_elements boolean?
---@field always_visible boolean?

---@class (exact) ShortcutKeyboardProperties : {[ShortcutKeyboardProperty]: boolean}, HudChildProperties
---@field no_hide_elements boolean
---@field always_visible boolean

---@alias ShortcutKeyboardProperty HudChildProperty | "no_hide_elements" | "always_visible"

---@class (exact) ShortcutKeyboardControlArguments
---@field background_blur PlayObjectGetterFn[]
---@field arrow PlayObjectGetterFn[]
---@field frame PlayObjectGetterFn[]
---@field line_cursor PlayObjectGetterFn[]
---@field tabs PlayObjectGetterFn[]

local ace_player = require("HudController.util.ace.player")
local ctrl_child = require("HudController.hud.def.ctrl_child")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local frame_cache = require("HudController.util.misc.frame_cache")
local frame_timer = require("HudController.util.misc.frame_timer")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local item = require("HudController.hud.elements.shortcut_keyboard.item")
local m = require("HudController.util.ref.methods")
local pallet = require("HudController.hud.elements.shortcut_keyboard.pallet")
local play_object = require("HudController.hud.play_object.init")
local prepare = require("HudController.hud.elements.shortcut_keyboard.prepare")
local s = require("HudController.util.ref.singletons")
local tab = require("HudController.hud.elements.shortcut_keyboard.tab")
local timer = require("HudController.util.misc.timer")
local util_mod = require("HudController.util.mod.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

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
    tabs = {
        {
            play_object.control.all,
            {
                "PNL_Pat00",
                "PNL_Palette",
            },
            "FSL_Tab",
        },
    },
    frame = {
        {
            play_object.child.all_type,
            "s9g_.*SideLine",
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
    line_cursor = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_Palette",
                "PNL_Main",
                "FSL_LineCursor",
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
        always_visible = true,
    })
    o.open_timer = frame_timer:new(15)
    o.always_visible_delay_timer = timer:new(0.5)

    o.children.background_blur = ctrl_child:new(
        args.children.background_blur,
        o,
        function(_, _, _, ctrl)
            return play_object.iter_args(ctrl, control_arguments.background_blur)
        end
    )
    o.children.arrow = hud_child:new(args.children.arrow, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.arrow)
    end)
    o.children.frame = ctrl_child:new(args.children.frame, o, function(_, _, _, ctrl)
        local tabs = play_object.iter_args(ctrl, control_arguments.tabs)
        return play_object.iter_args(tabs, control_arguments.frame)
    end)
    o.children.line_cursor = hud_child:new(args.children.line_cursor, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.line_cursor)
    end)
    o.children.tab = tab:new(args.children.tab, o)
    o.children.item = item:new(args.children.item, o)
    o.children.pallet = pallet:new(args.children.pallet, o)
    o.children.prepare = prepare:new(args.children.prepare, o)

    o.no_hide_elements = args.no_hide_elements
    o.always_visible = args.always_visible
    o.is_always_visible = frame_cache.memoize(o.is_always_visible)
    return o
end

---@param val boolean
function this:set_no_hide_elements(val)
    self.no_hide_elements = val
end

---@param val boolean
function this:set_always_visible(val)
    self.always_visible = val
end

---@return app.GUI020600
function this:get_GUI020600()
    if not self.GUI020600 then
        self.GUI020600 = util_mod.get_gui_cls("app.GUI020600") --[[@as app.GUI020600]]
    end

    return self.GUI020600
end

---@return boolean
function this:is_always_visible()
    if self.always_visible_delay_timer:active() then
        return false
    end

    local minimap_hide = m.getOptionValue(e.get("app.Option.ID").HUD_DISPLAY_MINIMAP)
    if minimap_hide ~= 3 then
        local map_ctrl = s.get("app.GUIManager"):get_MAP3D()
        local flow = map_ctrl._Flow
        if not flow:isOpenRadarMapGUI() then
            self.always_visible_delay_timer:restart(1)
            return false
        end
    end

    local shortcut_display = m.getOptionValue(e.get("app.Option.ID").KB_SHORTCUT_DISP)
    return self.always_visible
        and shortcut_display ~= 2
        and not ace_player.check_continue_flag(
            e.get("app.HunterDef.CONTINUE_FLAG").OPEN_ITEM_SLIDER
        )
end

function this:is_switch_input_method()
    local shortcut_display = m.getOptionValue(e.get("app.Option.ID").KB_SHORTCUT_DISP)
    return shortcut_display == 0
end

---@return boolean
function this:is_open()
    local is_open = self:get_GUI020600()._IsOpen
    if is_open then
        self.open_timer:restart()
    end

    return (is_open or self.open_timer:active()) and m.canOpenStartMenu(true)
end

---@param val number
function this:set_open_timer(val)
    local timer = self:get_GUI020600()._DispTimer
    timer._Timer = val * 1.0
    self:get_GUI020600()._DispTimer = timer
end

function this:reset_close_timer()
    self:set_open_timer(0.0)
end
function this:close()
    self:set_open_timer(3.0)
end

---@param key HudBaseWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    if self.always_visible then
        self:close()
    end

    hud_base.reset(self, key)
end

---@return ShortcutKeyboardConfig
function this.get_config()
    local base =
        hud_base.get_config(e.get("app.GUIHudDef.TYPE").SHORTCUT_KEYBOARD, "SHORTCUT_KEYBOARD") --[[@as ShortcutKeyboardConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.SHORTCUT_KEYBOARD

    base.no_hide_elements = false
    base.always_visible = false
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
    children.line_cursor = {
        name_key = "line_cursor",
        hide = false,
    }

    children.tab = tab.get_config()
    children.item = item.get_config()
    children.pallet = pallet.get_config()
    children.prepare = prepare.get_config()

    return base
end

return this
