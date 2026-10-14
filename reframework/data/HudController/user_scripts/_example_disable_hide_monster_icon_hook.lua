-- Disable Hide Monster Icon when map is open

local def = require("HudController.data.option.hud")
local e = require("HudController.util.game.enum")
local hook_common = require("HudController.hud.hook.common")
local hud = require("HudController.hud.init")
local m = require("HudController.util.ref.methods")
local mod = require("HudController.data.mod")
local util_ref = require("HudController.util.ref.init")

m.hook(
    "ace.GUIManagerBase`2<app.GUIID.ID,app.GUIFunc.TYPE>"
        .. ".openGUI(app.GUIID.ID, System.Object, ace.GUIDef.CtrlGUIFunc`2<app.GUIID.ID,app.GUIFunc.TYPE>, "
        .. "ace.GUIDef.CtrlGUICheckFunc`2<app.GUIID.ID,app.GUIFunc.TYPE>)",
    function(args)
        local hud_config = hook_common.get_hud()
        if
            hud_config
            and hud.get_hud_option(def.opt.monster_icon) ~= mod.enum.em_icon.DISABLED
            and util_ref.to_int(args[3]) == e.get("app.GUIID.ID").UI060000
        then
            hud.overwrite_hud_option(def.opt.monster_icon.key, mod.enum.em_icon.DISABLED)
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
            and hud_config.monster_icon ~= mod.enum.em_icon.DISABLED
            and hud.get_overridden(def.opt.monster_icon.key)
            and util_ref.to_int(args[3]) == e.get("app.GUIID.ID").UI060000
        then
            hud.clear_overridden(def.opt.monster_icon.key)
        end
    end
)
