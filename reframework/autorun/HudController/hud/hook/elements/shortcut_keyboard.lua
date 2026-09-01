local common = require("HudController.hud.hook.common")
local e = require("HudController.util.game.enum")
local m = require("HudController.util.ref.methods")
local s = require("HudController.util.ref.singletons")
local util_mod = require("HudController.util.mod.init")
local util_ref = require("HudController.util.ref.init")

local this = {}
local gui_flags = {
    "HIDE_CLOCK",
    "HIDE_TARGET_ICON",
    "HIDE_SLINGER_HUD",
    "HIDE_MANTLE_HUD",
}

local function is_reveal()
    local shortcut_keyboard = common.get_elem_t("ShortcutKeyboard")
    return shortcut_keyboard and shortcut_keyboard.no_hide_elements and shortcut_keyboard:is_open()
end

function this.reveal_minimap_pre(args)
    if is_reveal() then
        local flow = sdk.to_managed_object(args[2]) --[[@as app.cGUIMapFlowCtrl]]
        local flags = flow:get_Flags()
        flags:set_Item(e.get("app.cGUIMapFlowCtrl.FLAG").CLOSE, false)
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.reveal_elements_post(_)
    if is_reveal() then
        local guiman = s.get("app.GUIManager")
        local flags = guiman:get_AppContinueFlag()

        for _, flag in pairs(gui_flags) do
            flags:off(e.get("app.GUIManager.APP_CONTINUE_FLAG")[flag])
        end
    end
end

function this.clear_cache_pre(_)
    local shortcut_keyboard = common.get_elem_t("ShortcutKeyboard")
    if shortcut_keyboard then
        shortcut_keyboard:do_something_to_children(function(hudchild)
            hudchild:cache_clear()
        end)
    end
end

function this.always_visible_post(_)
    local shortcut_keyboard = common.get_elem_t("ShortcutKeyboard")
    if not shortcut_keyboard or not shortcut_keyboard:is_always_visible() then
        return
    end

    shortcut_keyboard:reset_close_timer()
end

function this.always_visible_open_post(_)
    local shortcut_keyboard = common.get_elem_t("ShortcutKeyboard")
    if
        not shortcut_keyboard
        or not shortcut_keyboard:is_always_visible()
        or not m.canOpenStartMenu(true)
    then
        return
    end

    local system_input_ctrl = util_mod.get_pc_shortcut_input()

    if
        shortcut_keyboard:is_switch_input_method()
        and system_input_ctrl:checkHoldButton()
        and shortcut_keyboard:get_GUI020600()._Type ~= e.get("app.GUI020600.TYPE").EXPAND
    then
        shortcut_keyboard:close()
        system_input_ctrl._OpenType = e.get("app.GUI020600.TYPE").EXPAND
        shortcut_keyboard.always_visible_delay_timer:restart({ timeout = 2 })
        return
    end

    if system_input_ctrl._OpenType == e.get("app.GUI020600.TYPE").EXPAND then
        if not shortcut_keyboard:get_GUI020600()._IsOpen then
            system_input_ctrl._OpenType = e.get("app.GUI020600.TYPE").NORMAL
        end

        return
    end

    if system_input_ctrl:canOpen(true) then
        system_input_ctrl:onOpen()
    end
end

function this.prevent_close_post(_)
    local shortcut_keyboard = common.get_elem_t("ShortcutKeyboard")
    if not shortcut_keyboard or not shortcut_keyboard:is_always_visible() then
        return
    end

    local args = util_ref.thread_get()
    local o = sdk.to_managed_object(args[2]) --[[@as ace.cGUIInputCtrl_FluentScrollList]]
    if o == shortcut_keyboard:get_GUI020600():get__CtrlTab_Normal() then
        return -1
    end
end

function this.prevent_close2_pre(args)
    local shortcut_keyboard = common.get_elem_t("ShortcutKeyboard")
    if not shortcut_keyboard or not shortcut_keyboard:is_always_visible() then
        return
    end

    local button = util_ref.to_int(args[3])
    if button == shortcut_keyboard:get_GUI020600().SLOT_CLOSE_NORMAL_PALLET then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

return this
