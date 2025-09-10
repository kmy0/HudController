local common = require("HudController.hud.hook.common")
local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local s = require("HudController.util.ref.singletons")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

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
        flags:set_Item(rl(ace_enum.map_flow_flag, "CLOSE"), false)
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.reveal_elements_post(retval)
    if is_reveal() then
        local guiman = s.get("app.GUIManager")
        local flags = guiman:get_AppContinueFlag()

        for _, flag in pairs(gui_flags) do
            flags:off(rl(ace_enum.gui_continue_flag, flag))
        end
    end
end

return this
