-- Disable Hide Monster Icon when map is open

local data = require("HudController.data")
local hook_common = require("HudController.hud.hook.common")
local hud = require("HudController.hud")
local m = require("HudController.util.ref.methods")
local util_game = require("HudController.util.game")
local util_ref = require("HudController.util.ref")

local rl = util_game.data.reverse_lookup

m.hook(
    "ace.GUIManagerBase`2<app.GUIID.ID,app.GUIFunc.TYPE>"
        .. ".openGUI(app.GUIID.ID, System.Object, ace.GUIDef.CtrlGUIFunc`2<app.GUIID.ID,app.GUIFunc.TYPE>, "
        .. "ace.GUIDef.CtrlGUICheckFunc`2<app.GUIID.ID,app.GUIFunc.TYPE>)",
    function(args)
        local hud_config = hook_common.get_hud()
        if
            hud_config
            and hud.get_hud_option("hide_monster_icon")
            and util_ref.to_int(args[3]) == rl(data.ace.enum.gui_id, "UI060000")
        then
            hud.overwrite_hud_option("hide_monster_icon", false)
        end
    end
)
m.hook(
    "ace.GUIManagerBase`2<app.GUIID.ID,app.GUIFunc.TYPE>"
        .. ".closeGUI(app.GUIID.ID, System.Object, ace.GUIDef.CtrlGUIFunc`2<app.GUIID.ID,app.GUIFunc.TYPE>, "
        .. "ace.GUIDef.CtrlGUICheckFunc`2<app.GUIID.ID,app.GUIFunc.TYPE>)",
    function(args)
        local hud_config = hook_common.get_hud()
        if
            hud_config
            and hud_config.hide_monster_icon
            and not hud.get_overridden("hide_monster_icon")
            and util_ref.to_int(args[3]) == rl(data.ace.enum.gui_id, "UI060000")
        then
            hud.manager.overridden_options["hide_monster_icon"] = nil
        end
    end
)
