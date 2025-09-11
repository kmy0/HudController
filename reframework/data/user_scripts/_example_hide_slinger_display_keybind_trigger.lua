-- Hide Slinger Display when LB/L_CTRL is held

local ace_misc = require("HudController.util.ace.misc")
local hook_common = require("HudController.hud.hook.common")
local m = require("HudController.util.ref.methods")
local s = require("HudController.util.ref.singletons")
local util_game = require("HudController.util.game.init")

local rl = util_game.data.reverse_lookup
local key_enum = require("HudController.util.game.bind.enum")

m.hook("app.cGUIHudDisplayManager.lateUpdate()", function(retval)
    local slinger = hook_common.get_elem_t("Slinger")

    if slinger then
        local device = key_enum.input_device[s.get("app.GUIManager")
            :get_LastInputDeviceIgnoreMouseMove()]
        local flag = false

        if device == "PAD" then
            local pad = ace_misc.get_pad()
            local btn = pad:get_KeyOn()
            local L1 = rl(key_enum.pad_btn, "L1")
            flag = btn & L1 == L1
        elseif device == "KEYBOARD" then
            local kb = ace_misc.get_kb()
            local L_CTRL = rl(key_enum.kb_btn, "L_CTRL")
            flag = kb:isOn(L_CTRL)
        end

        if flag and slinger.hide then
            slinger:set_hide(false)
        elseif not flag and not slinger.hide then
            slinger:set_hide(true)
        end
    end
end)
