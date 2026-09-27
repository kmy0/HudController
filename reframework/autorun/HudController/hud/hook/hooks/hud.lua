---@class HudOptionHook
---@field condition fun(config_path: string): boolean
---@field fn fun()
---@field force_once boolean

local common = require("HudController.hud.hook.common")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local elements = require("HudController.hud.hook.elements.init")
local hud = require("HudController.hud.init")
local m = require("HudController.util.ref.methods")
local util_ref = require("HudController.util.ref.init")
local util_table = require("HudController.util.misc.table")
local mod_enum = require("HudController.data.mod").enum
local elem_base_def = require("HudController.hud.elements.init")
local elem_def = require("HudController.data.option.element.init")

local ace_map = data.ace.map

---@class HudHooksFns : { [string]: fun() }
local hud_hooks = {}
---@class HudOptionHooksFns : { [string]: { [string]: HudOptionHook } }
local hud_option_hooks = {}

---@param node ElementOptNode | string
---@param opt ElementOptionDef | string
---@return string
local function opt_key(node, opt)
    if type(opt) ~= "string" then
        opt = opt.key --[[@as string]]
    end

    if type(node) ~= "string" then
        node = node.config_key --[[@as string]]
    end

    return ("%s.%s"):format(node, opt)
end

---@return HudOptionHook
local function make_hud_options_hook(fn, condition)
    condition = condition
        or function(config_path)
            local profile = hud.get_current() --[[@as ModProfileConfig]]
            return util_table.get_by_path(profile, string.format("elements.%s", config_path))
        end

    local ret = {
        force_once = false,
        fn = fn,
    }

    ret.condition = function(...)
        if ret.force_once then
            ret.force_once = false
            return true
        end

        return condition(...)
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return ret
end

function hud_hooks.target_reticle()
    m.hook(
        "app.GUI020021.guiUpdate()",
        util_ref.capture_this,
        elements.update.update_target_reticle_post
    )
end

function hud_hooks.menu_button_guide()
    m.hook(
        "app.GUI000008.guiLateUpdate()",
        util_ref.capture_this,
        elements.update.update_menu_button_guide_post
    )
end

function hud_hooks.damage_numbers()
    m.hook(
        "app.GUI020020.requestDamage(via.vec3, System.Single, app.GUI020020.State, app.TARGET_ACCESS_KEY.CATEGORY, "
            .. "app.GUI020020.DAMAGE_TYPE, app.GUI020020.CRITICAL_STATE, System.Boolean, "
            .. "System.Boolean, System.Action`1<app.GUI020020.DAMAGE_INFO>)",
        elements.update.update_damage_numbers_static_pre
    )
    m.hook(
        "app.GUI020020.guiLateUpdate()",
        util_ref.capture_this,
        elements.update.update_damage_numbers_post
    )
end

function hud_hooks.subtitles()
    m.hook("app.cDialogueSubtitleManager.updateDisp()", elements.update.update_subtitles_pre)

    local root = elem_def.map[elem_base_def.Subtitles]
    local def = elem_def.main[mod_enum.hud_type.SUBTITLES]

    hud_option_hooks[elem_base_def.Subtitles] = {
        [opt_key(root, "_hide_subtitles")] = make_hud_options_hook(function()
            m.hook(
                "app.cDialogueSubtitleManager.dispText(app.cDialogueSubtitleManager.RequestData, System.Int32)",
                elements.subtitles.hide_subtitles_pre
            )
            m.hook(
                "app.SoundDialogueTriggerManager.onSpeakSkip(app.DialogueDef.DialogueVoiceParam)",
                elements.subtitles.hide_subtitles_pre2
            )
        end, function(_)
            local subtitles = common.get_elem_t("Subtitles")
            if not subtitles or subtitles.hide then
                return false
            end

            return subtitles:any_hide()
        end),
        [opt_key(root, "_mute_subtitles")] = make_hud_options_hook(function()
            m.hook(
                "app.SoundDialogueTriggerManager.shouldTrigger(app.DialogueDef.DialogueVoiceParam, soundlib.SoundContainer, System.UInt32)",
                elements.subtitles.mute_subtitles_pre,
                elements.subtitles.mute_subtitles_post
            )
        end, function(_)
            local subtitles = common.get_elem_t("Subtitles")
            if not subtitles then
                return false
            end

            return subtitles:any_mute()
        end),
        [opt_key(root, def.opt.cache_subtitles)] = make_hud_options_hook(function()
            m.hook(
                "app.cDialogueSubtitleManager.dispText(app.cDialogueSubtitleManager.RequestData, System.Int32)",
                elements.subtitles.cache_subtitles_pre
            )
        end),
        [opt_key(root, def.opt.cache_sfx)] = make_hud_options_hook(function()
            m.hook(
                "soundlib.SoundContainer.trigger(soundlib.SoundManager.RequestInfo)",
                elements.subtitles.log_sfx_pre
            )
        end),
        [opt_key(root, "_mute_sfx")] = make_hud_options_hook(function()
            m.hook(
                "soundlib.SoundContainer.trigger(soundlib.SoundManager.RequestInfo)",
                elements.subtitles.mute_sfx_pre
            )
        end, function(_)
            local subtitles = common.get_elem_t("Subtitles")
            if not subtitles then
                return false
            end

            return subtitles:any_mute_sfx()
        end),
    }
end

function hud_hooks.training_room_hud()
    m.hook(
        "app.GUI600100.guiUpdate()",
        util_ref.capture_this,
        elements.update.update_training_room_hud_post
    )
end

function hud_hooks.name_access()
    m.hook(
        "app.GUI020001PanelBase.onLateUpdate()",
        util_ref.capture_this,
        elements.update.update_name_access_icons_post
    )

    hud_option_hooks[elem_base_def.NameAccess] = {
        [opt_key(elem_base_def.NameAccess, "_hide_interactables")] = make_hud_options_hook(
            function()
                m.hook(
                    "app.GUIAccessIconControl.lateUpdate()",
                    util_ref.capture_this,
                    elements.name_access.hide_iteractables_post
                )
            end,
            function(_)
                local name_access = common.get_elem_t("NameAccess")
                if not name_access then
                    return false
                end

                if name_access.hide then
                    return false
                end

                return util_table.any({
                    name_access.npc_draw_distance > 0,
                    name_access:any_panel(),
                    name_access:any_npc(),
                    name_access:any_gossip(),
                    name_access:any_enemy(),
                })
            end
        ),
    }
end

function hud_hooks.barrel_bowling_score()
    m.hook(
        "app.GUI090901.guiHudVisibleUpdate()",
        util_ref.capture_this,
        elements.update.update_barrel_score_post
    )
end

function hud_hooks.chat_log()
    m.hook(
        "app.GUI020101.guiLateUpdate()",
        util_ref.capture_this,
        elements.update.update_chat_log_post
    )
    m.hook(
        "app.GUI000008.guiLateUpdate()",
        nil,
        elements.update.update_chat_log_menu_button_guide_post
    )
    m.hook("app.GUI020101.guiAwake()", elements.chat_log.clear_cache_pre)
end

function hud_hooks.radial()
    local root = elem_def.map[elem_base_def.Radial]
    local pallet = root.children.pallet

    hud_option_hooks[elem_base_def.Radial] = {
        [opt_key(root, elem_def.opt.hide)] = make_hud_options_hook(function()
            m.hook(
                "app.GUI020008.checkOpen()",
                util_ref.capture_this,
                elements.radial.hide_radial_post
            )
        end),
        [opt_key(pallet, elem_def.opt.hide)] = make_hud_options_hook(function()
            m.hook(
                "app.GUI020008PartsPallet.callbackSelectICL(via.gui.Control, via.gui.SelectItem, System.UInt32, System.Int32, System.UInt32, System.Int32)",
                elements.radial.hide_radial_pallet_pre
            )
        end),
    }
end

function hud_hooks.itembar()
    local root = elem_def.map[elem_base_def.Itembar]
    local def = elem_def.main[mod_enum.hud_type.ITEMBAR]
    local slider = root.children.slider
    local all = root.children.all_slider

    hud_option_hooks[elem_base_def.Itembar] = {
        [opt_key(root, def.opt.start_expanded)] = make_hud_options_hook(function()
            m.hook("app.GUI020006.controlSliderOpen()", elements.itembar.open_expanded_itembar_pre)
            m.hook(
                "app.GUI020008.checkOpen()",
                util_ref.capture_this,
                elements.itembar.hide_radial_post
            )
        end),
        [opt_key(all, def.opt.all_slider_ammo_visible)] = make_hud_options_hook(function()
            m.hook(
                m.get_by_regex("app.GUI020007", "^<guiHudUpdate>.-1$") --[[@as REMethodDefinition]],
                elements.itembar.keep_ammo_open_pre
            )
        end),
        [opt_key(all, def.opt.all_slider_slinger_visible)] = make_hud_options_hook(function()
            m.hook(
                m.get_by_regex("app.GUI020017", "^<setupOpenCloseEvent>.-1$") --[[@as REMethodDefinition]],
                util_ref.capture_this,
                elements.itembar.keep_slinger_open1_post
            )
            m.hook(
                m.get_by_regex("app.GUI020017", "^<setupOpenCloseEvent>.-0$") --[[@as REMethodDefinition]],
                util_ref.capture_this,
                elements.itembar.keep_slinger_open0_post
            )
        end),
        [opt_key(all, def.opt.all_slider_disable_right_stick)] = make_hud_options_hook(function()
            m.hook(
                "app.GUIManager.updatePlCommandMask()",
                nil,
                elements.itembar.unblock_camera_control_post
            )
        end),
        [opt_key(all, def.opt.all_slider_enable_mouse_control)] = make_hud_options_hook(function()
            m.hook(
                "app.GUI020006PartsAllSlider.onLateUpdate()",
                util_ref.capture_this,
                elements.itembar.expanded_itembar_mouse_control_post
            )
            m.hook(
                "app.GUIManager.isMouseCursorAvailable()",
                nil,
                elements.itembar.force_cursor_visible_post
            )
            m.hook("app.GUI000006.updateMouseVisible()", elements.itembar.skip_mouse_update_pre)
            m.hook("app.GUI000006.guiLateUpdate()", elements.itembar.force_mouse_pos_pre)
        end),
        [opt_key(all, def.opt.all_slider_appear_open)] = make_hud_options_hook(function()
            m.hook(
                "app.GUI020006.callbackPouchChange(app.ItemDef.ID)",
                nil,
                elements.itembar.refresh_all_slider_post
            )
        end),
        [opt_key(slider, def.opt.slider_move_next)] = make_hud_options_hook(function()
            m.hook(
                "app.ItemUtil.useItem(app.ItemDef.ID, System.Int16, System.Boolean)",
                elements.itembar.move_next_item_pre
            )
        end),
        [opt_key(root, "_all_slider_clear_cache")] = make_hud_options_hook(function()
            m.hook(
                "app.GUI020006PartsAllSlider.updateDispItems(System.Int32, via.gui.SelectItem, System.Int32)",
                elements.itembar.clear_cache_pre
            )
        end, function(_)
            local itembar = common.get_elem_t("Itembar")
            if not itembar then
                return false
            end

            return itembar.children.all_slider:any()
        end),
    }
end

function hud_hooks.ammo()
    local root = elem_def.map[elem_base_def.Ammo]
    local def = elem_def.main[mod_enum.hud_type.AMMO]

    hud_option_hooks[elem_base_def.Ammo] = {
        [opt_key(root, def.opt.no_hide_parts)] = make_hud_options_hook(function()
            m.hook(
                "app.GUI020007.controlSliderStatus()",
                elements.ammo.no_hide_ammo_slider_parts_pre
            )
            m.hook(
                "app.GUI020007.setReloadState(System.String)",
                elements.ammo.no_hide_ammo_slider_reload_pre
            )
        end),
    }
end

function hud_hooks.name_other()
    m.hook("app.GUI020016.guiHudUpdate()", elements.name_other.name_other_update_player_pos_pre)

    local root = elem_def.map[elem_base_def.NameOther]

    hud_option_hooks[elem_base_def.NameOther] = {
        [opt_key(root, "_hide_nameplete")] = make_hud_options_hook(function()
            m.hook(
                "app.GUI020016PartsBase.checkIsVisible()",
                util_ref.capture_this,
                elements.name_other.hide_nameplate_post
            )
        end, function(_)
            local name_other = common.get_elem_t("NameOther")
            if not name_other or name_other.hide then
                return false
            end

            return name_other.pl_draw_distance > 0
                or name_other.pet_draw_distance > 0
                or util_table.any(name_other.nameplate_type)
        end),
    }
end

function hud_hooks.control()
    local root = elem_def.map[elem_base_def.Control]

    hud_option_hooks[elem_base_def.Control] = {
        [opt_key(root, "_hide_nameplete")] = make_hud_options_hook(function()
            m.hook(
                "app.GUI020014.changeViewTypeState(System.Boolean)",
                elements.control.set_control_global_pos_pre,
                elements.control.set_control_global_pos_post
            )
        end, function(_)
            local control = common.get_elem_t("Control")
            if
                not control
                or control.hide
                or control.children.control_guide1.hide
                or not control.children.control_guide1.offset
            then
                return false
            end

            return true
        end),
    }
end

function hud_hooks.progress()
    local root = elem_def.map[elem_base_def.Progress]

    hud_option_hooks[elem_base_def.Progress] = {
        [opt_key(root, "_cache_reset")] = make_hud_options_hook(function()
            m.hook(
                "app.MissionManager.unLoadMissionData(app.MissionIDList.ID)",
                elements.progress.reset_progress_mission_pre
            )
            m.hook(
                "app.MissionManager.unLoadAllMissionData()",
                elements.progress.reset_progress_default_pre
            )
            m.hook("app.GUI020018.updateMission()", elements.progress.clear_cache_pre)
        end, function(_)
            local progress = common.get_elem_t("Progress")
            if not progress then
                return false
            end

            ---@diagnostic disable-next-line: no-unknown
            for _, child in pairs(progress.children) do
                if child:any() then
                    return true
                end
            end

            return false
        end),
    }
end

function hud_hooks.notice()
    local root = elem_def.map[elem_base_def.Notice]
    local def = elem_def.main[mod_enum.hud_type.NOTICE]

    hud_option_hooks[elem_base_def.Notice] = {
        [opt_key(root, def.opt.cache_msg)] = make_hud_options_hook(function()
            m.hook(
                "app.GUI020100.dispPanel(app.cGUI020100PanelBase)",
                elements.notice.cache_message_pre
            )
        end),

        [opt_key(root, "_skip_system")] = make_hud_options_hook(function()
            m.hook(
                "app.ChatManager.pushBackSystemLog(app.ChatDef.SystemMessage, System.Boolean)",
                elements.notice.skip_system_message_pre
            )
        end, function(_)
            local notice = common.get_elem_t("Notice")
            if not notice then
                return false
            end

            return notice.hide or util_table.any(notice.system_log)
        end),

        [opt_key(root, "_skip_lobby")] = make_hud_options_hook(function()
            m.hook(
                "app.ChatManager.pushBackLobbyLog(app.ChatDef.ChatBase)",
                elements.notice.skip_lobby_message_pre
            )
        end, function(_)
            local notice = common.get_elem_t("Notice")
            if not notice then
                return false
            end

            return notice.hide or util_table.any(notice.chat_log)
        end),

        [opt_key(root, "_skip_auto")] = make_hud_options_hook(function()
            m.hook(
                "app.ChatManager.pushBackSystem(app.net_packet.cChatBase, System.Boolean, System.Boolean, app.net_session_manager.SESSION_TYPE, System.Int32, System.Boolean, System.Boolean)",
                elements.notice.skip_auto_message_pre
            )
        end, function(_)
            local notice = common.get_elem_t("Notice")
            if not notice then
                return false
            end

            return notice.hide or util_table.any(notice.auto_id)
        end),
    }
end

function hud_hooks.shortcut_keyboard()
    local root = elem_def.map[elem_base_def.ShortcutKeyboard]
    local def = elem_def.main[mod_enum.hud_type.SHORTCUT_KEYBOARD]

    hud_option_hooks[elem_base_def.ShortcutKeyboard] = {
        [opt_key(root, def.opt.no_hide_elements)] = make_hud_options_hook(function()
            m.hook("app.cGUIMapFlowCtrl.update()", elements.shortcut_keyboard.reveal_minimap_pre)
            m.hook(
                "ace.GUIBase`2<app.GUIID.ID,app.GUIFunc.TYPE>.requestClose(System.Boolean)",
                elements.shortcut_keyboard.reveal_elements_pre
            )
            m.hook(
                "app.GUIManager.lateUpdateApp()",
                nil,
                elements.shortcut_keyboard.reveal_mantle_post
            )
        end),

        [opt_key(root, def.opt.always_visible)] = make_hud_options_hook(function()
            m.hook(
                "app.GUI020600.guiHudVisibleUpdate()",
                nil,
                elements.shortcut_keyboard.always_visible_post
            )
            m.hook(
                "app.GUIManager.lateUpdateApp()",
                nil,
                elements.shortcut_keyboard.always_visible_open_post
            )
            m.hook(
                "ace.cGUIInputCtrl_FluentScrollList`2<app.GUIID.ID,app.GUIFunc.TYPE>.getSelectedIndex()",
                util_ref.thread_store,
                elements.shortcut_keyboard.prevent_close_post
            )
            m.hook(
                "app.GUI020600.callback_OtherNormal(ace.GUIDef.BUTTON_SLOT, via.gui.Control, via.gui.SelectItem, System.UInt32)",
                elements.shortcut_keyboard.prevent_close2_pre
            )
        end),

        [opt_key(root, "_clear_cache")] = make_hud_options_hook(function()
            m.hook(
                "app.GUI020600.requestOpenPCShortcut(app.GUI020600.TYPE, System.Int32, System.Int32, app.GUI020600.MODE, via.gui.Rect)",
                elements.shortcut_keyboard.clear_cache_pre
            )
        end, function(_)
            local shortcut_keyboard = common.get_elem_t("ShortcutKeyboard")
            if not shortcut_keyboard then
                return false
            end

            ---@diagnostic disable-next-line: no-unknown
            for _, child in pairs(shortcut_keyboard.children) do
                if child:any() then
                    return true
                end
            end

            return false
        end),
    }
end

function hud_hooks.minimap()
    local root = elem_def.map[elem_base_def.Minimap]
    local def = elem_def.main[mod_enum.hud_type.MINIMAP]
    local classic = root.children["__classic_minimap__"]

    hud_option_hooks[elem_base_def.Minimap] = {
        [opt_key(classic, def.opt.classic_minimap)] = make_hud_options_hook(function()
            m.hook(
                "app.cGUIMapCameraController.updateCameraParam_Radar(System.Single)",
                util_ref.capture_this,
                elements.minimap.classic_minimap_param_update_post
            )
            m.hook(
                "app.cGUI060000Radar.getRadarSizeType(app.cPlayerManageInfo)",
                elements.minimap.classic_minimap_no_resize_pre
            )
        end),

        [opt_key(classic, def.opt.classic_minimap_icon_scale)] = make_hud_options_hook(function()
            m.hook(
                "app.cGUIMapIconModelSize.updateIconSizeParam()",
                util_ref.capture_this,
                elements.minimap.classic_minimap_icon_scale_post
            )
        end),
    }
end

function hud_hooks.quest_end_timer()
    local root = elem_def.map[elem_base_def.QuestEndTimer]
    local def = elem_def.main[mod_enum.hud_type.QUEST_END_TIMER]

    m.hook(
        "app.GUI020202.guiVisibleUpdate()",
        util_ref.capture_this,
        elements.update.update_quest_end_timer_post
    )

    hud_option_hooks[elem_base_def.QuestEndTimer] = {
        [opt_key(root, "_skip_" .. def.opt.quest_end_timer.key)] = make_hud_options_hook(function()
            m.hook(
                "app.cQuestSuccessFreePlayTime.enter()",
                elements.quest_end_timer.skip_quest_end_timer_pre
            )
            m.hook(
                "ace.GUIManagerBase`2<app.GUIID.ID,app.GUIFunc.TYPE>"
                    .. ".openGUI(app.GUIID.ID, System.Object, ace.GUIDef.CtrlGUIFunc`2<app.GUIID.ID,app.GUIFunc.TYPE>, "
                    .. "ace.GUIDef.CtrlGUICheckFunc`2<app.GUIID.ID,app.GUIFunc.TYPE>)",
                elements.quest_end_timer.skip_quest_end_timer_open_pre
            )

            common.mute_gui_element(function(args)
                local quest_end_timer = common.get_elem_t("QuestEndTimer")
                local guiid = util_ref.to_short(args[3])

                if
                    quest_end_timer
                    and quest_end_timer.quest_end_timer == mod_enum.quest_end_timer.SKIP
                    and guiid == e.get("app.GUIID.ID").UI020202
                then
                    return true
                end

                return false
            end)
        end, function(_)
            local quest_end_timer = common.get_elem_t("QuestEndTimer")

            return (
                quest_end_timer
                and quest_end_timer.quest_end_timer == mod_enum.quest_end_timer.SKIP
            ) or false
        end),

        [opt_key(root, "_hide_" .. def.opt.quest_end_timer.key)] = make_hud_options_hook(function()
            m.hook(
                "app.GUI020202.guiVisibleUpdate()",
                elements.quest_end_timer.hide_quest_end_input_pre
            )
        end, function(_)
            local quest_end_timer = common.get_elem_t("QuestEndTimer")

            return (
                quest_end_timer
                and quest_end_timer.quest_end_timer == mod_enum.quest_end_timer.HIDE
            ) or false
        end),
    }
end

function hud_hooks.button_press()
    common.mute_gui_element(function(args)
        local guiid = util_ref.to_short(args[3])
        if e.get("app.GUIID.ID")[guiid] == ace_map.additional_hud_to_guiid_name.BUTTON_PRESS then
            local hud_elem, _ = common.get_elem_consume_t(nil, guiid)
            return hud_elem and hud_elem.hide and true or false
        end

        return false
    end)
end

return {
    hud_hooks = hud_hooks,
    hud_option_hooks = hud_option_hooks,
}
