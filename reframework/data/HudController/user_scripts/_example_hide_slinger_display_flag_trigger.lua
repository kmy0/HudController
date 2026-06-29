-- Hide Slinger Display when LB/L_CTRL is held

local ace_player = require("HudController.util.ace.player")
local e = require("HudController.util.game.enum")
local hook_common = require("HudController.hud.hook.common")
local m = require("HudController.util.ref.methods")

m.hook("app.cGUIHudDisplayManager.lateUpdate()", function(retval)
    local slinger = hook_common.get_elem_t("Slinger")

    if slinger then
        local flag =
            ace_player.check_continue_flag(e.get("app.HunterDef.CONTINUE_FLAG").OPEN_ITEM_SLIDER)
        if flag and slinger.hide then
            slinger:set_hide(false)
        elseif not flag and not slinger.hide then
            slinger:set_hide(true)
        end
    end
end)
