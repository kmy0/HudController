local ace_misc = require("HudController.util.ace.misc")
local ace_player = require("HudController.util.ace.player")
local cache = require("HudController.util.misc.cache")
local data = require("HudController.data")
local hook_common = require("HudController.hud.hook.common")
local hud = require("HudController.hud")
local m = require("HudController.util.ref.methods")
local s = require("HudController.util.ref.singletons")
local util_game = require("HudController.util.game")
local util_ref = require("HudController.util.ref")

local rl = util_game.data.reverse_lookup
local ace_enum = data.ace.enum
local key_enum = require("HudController.util.game.bind.enum")

--#region disable hide_monster_icon while map is open
--#region example 1
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
--#endregion
--#region example 2
---@return via.gui.GUI?
local function get_map()
    local map3d = s.get("app.GUIManager"):get_MAP3D()
    local GUI060000 = map3d:get_GUIFront()
    return GUI060000._GUI
end

---@return boolean
local function is_map_open()
    local map = get_map()
    if not map then
        return false
    end

    return map:get_Enabled()
end

re.on_frame(function()
    local hud_config = hook_common.get_hud()
    if hud_config and hud_config.hide_monster_icon then
        local map_open = is_map_open()
        if map_open and hud.get_hud_option("hide_monster_icon") then
            hud.overwrite_hud_option("hide_monster_icon", false)
        elseif not map_open and not hud.get_overridden("hide_monster_icon") then
            hud.manager.overridden_options["hide_monster_icon"] = nil
        end
    end
end)

get_map = cache.memoize(get_map)
--#endregion
--#endregion

--#region slinger visible only when L1 pressed
--#region example 1

m.hook("app.cGUIHudDisplayManager.lateUpdate()", function(retval)
    local slinger = hook_common.get_elem_t("Slinger")

    if slinger then
        --[[
            This is necessary to avoid flickering to the original position when switching from visible to hidden.
            The mod stops writing any other settings if an element is hidden, and because this particular element (like most of them)
            uses the ingame system to hide it, it creates a problem. The game doesn't hide the element on frame 1,
            instead, it fades out over several frames.
        ]]
        slinger.hide_write = true

        local flag = ace_player.check_continue_flag(rl(ace_enum.hunter_continue_flag, "OPEN_ITEM_SLIDER"))
        if flag and slinger.hide then
            slinger:set_hide(false)
        elseif not flag and not slinger.hide then
            slinger:set_hide(true)
        end
    end
end)
--#endregion
--#region example 2
m.hook("app.cGUIHudDisplayManager.lateUpdate()", function(retval)
    local slinger = hook_common.get_elem_t("Slinger")

    if slinger then
        slinger.hide_write = true
        local device = key_enum.input_device[s.get("app.GUIManager"):get_LastInputDeviceIgnoreMouseMove()]
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
--#endregion
--#endregion
