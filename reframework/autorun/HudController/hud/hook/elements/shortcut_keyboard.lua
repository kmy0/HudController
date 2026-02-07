local common = require("HudController.hud.hook.common")
local e = require("HudController.util.game.enum")
local s = require("HudController.util.ref.singletons")

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
            hudchild:clear_cache()
        end)
    end
end

return this
