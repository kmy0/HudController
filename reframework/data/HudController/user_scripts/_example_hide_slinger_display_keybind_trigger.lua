-- Hide Slinger Display when LB/L_CTRL is held

local ace_misc = require("HudController.util.ace.misc")
local e = require("HudController.util.game.enum")
local hook_common = require("HudController.hud.hook.common")
local m = require("HudController.util.ref.methods")
local s = require("HudController.util.ref.singletons")

m.hook("app.cGUIHudDisplayManager.lateUpdate()", function(retval)
    local slinger = hook_common.get_elem_t("Slinger")

    if slinger then
        local device = e.get("ace.GUIDef.INPUT_DEVICE")[s.get("app.GUIManager")
            :get_LastInputDeviceIgnoreMouseMove()]
        local flag = false

        if device == "PAD" then
            local pad = ace_misc.get_pad()
            local btn = pad:get_KeyOn()
            local L1 = e.get("ace.ACE_PAD_KEY.BITS").L1
            flag = btn & L1 == L1
        elseif device == "KEYBOARD" then
            local kb = ace_misc.get_kb()
            local L_CTRL = e.get("ace.ACE_MKB_KEY.INDEX").L_CTRL
            flag = kb:isOn(L_CTRL)
        end

        if flag and slinger.hide then
            slinger:set_hide(false)
        elseif not flag and not slinger.hide then
            slinger:set_hide(true)
        end
    end
end)
