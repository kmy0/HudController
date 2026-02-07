---@class ModHook
---@field is_hud_hooked table<string, boolean>
---@field is_option_hooked table<string, boolean>
---@field is_fun_hooked table<fun(), true>
---@field hud_hooks table<string, fun(...)>
---@field option_hooks table<string, fun()>
---@field hud table<string, fun()|fun()[]>
---@field option table<string, fun()|fun()[]>

local common = require("HudController.hud.hook.common")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local elements = require("HudController.hud.hook.elements.init")
local m = require("HudController.util.ref.methods")
local misc = require("HudController.hud.hook.misc")
local options = require("HudController.hud.hook.options.init")
local util_ref = require("HudController.util.ref.init")

local ace_map = data.ace.map
local mod_map = data.mod.map

---@class ModHook
local this = {
    is_hud_hooked = {},
    is_option_hooked = {},
    is_fun_hooked = {},
    hud_hooks = {},
    option_hooks = {},
    hud = {},
    option = {},
}
---@type table<string, boolean>
local on_render_hooks = {}

m.hook("app.GUIManager.resetTitleApp()", nil, misc.reset_hud_default_post)
m.hook(
    "app.HunterCharacter.warp(via.vec3, System.Nullable`1<via.Quaternion>, System.Boolean)",
    nil,
    misc.reset_cache_post
)
m.hook("app.GUIManager.lateUpdateApp()", nil, function(_)
    if not common.is_ok() then
        return
    end

    for gui_type in pairs(on_render_hooks) do
        elements.update.update_post(gui_type)
    end
end)

function this.hud_hooks.target_reticle()
    m.hook(
        "app.GUI020021.guiUpdate()",
        util_ref.capture_this,
        elements.update.update_target_reticle_post
    )
end

function this.hud_hooks.menu_button_guide()
    m.hook(
        "app.GUI000008.guiLateUpdate()",
        util_ref.capture_this,
        elements.update.update_menu_button_guide_post
    )
end

function this.hud_hooks.damage_numbers()
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

function this.hud_hooks.subtitles()
    m.hook("app.cDialogueSubtitleManager.updateDisp()", elements.update.update_subtitles_pre)
end

function this.hud_hooks.training_room_hud()
    m.hook(
        "app.GUI600100.guiUpdate()",
        util_ref.capture_this,
        elements.update.update_training_room_hud_post
    )
end

function this.hud_hooks.name_access()
    m.hook(
        "app.GUI020001PanelBase.onLateUpdate()",
        util_ref.capture_this,
        elements.update.update_name_access_icons_post
    )
    m.hook(
        "app.GUIAccessIconControl.lateUpdate()",
        util_ref.capture_this,
        elements.name_access.hide_iteractables_post
    )
end

function this.hud_hooks.barrel_bowling_score()
    m.hook(
        "app.GUI090901.guiHudVisibleUpdate()",
        util_ref.capture_this,
        elements.update.update_barrel_score_post
    )
end

function this.hud_hooks.chat_log()
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

function this.hud_hooks.radial()
    m.hook("app.GUI020008.checkOpen()", util_ref.capture_this, elements.radial.hide_radial_post)
    m.hook(
        "app.GUI020008PartsPallet.callbackSelectICL(via.gui.Control, via.gui.SelectItem, System.UInt32, System.Int32, System.UInt32, System.Int32)",
        elements.radial.hide_radial_pallet_pre
    )
end

function this.hud_hooks.itembar()
    m.hook("app.GUI020006.controlSliderOpen()", elements.itembar.open_expanded_itembar_pre)
    m.hook(
        m.get_by_regex("app.GUI020007", "^<guiHudUpdate>.-1$") --[[@as REMethodDefinition]],
        elements.itembar.keep_ammo_open_pre
    )
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
    m.hook(
        "app.GUIManager.updatePlCommandMask()",
        nil,
        elements.itembar.unblock_camera_control_post
    )
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
    m.hook("app.GUI000006.guiLateUpdate()", elements.itembar.force_mouse_pos_pre)
    m.hook("app.GUI000006.updateMouseVisible()", elements.itembar.skip_mouse_update_pre)
    m.hook(
        "app.GUI020006.callbackPouchChange(app.ItemDef.ID)",
        nil,
        elements.itembar.refresh_all_slider_post
    )
    m.hook(
        "app.ItemUtil.useItem(app.ItemDef.ID, System.Int16, System.Boolean)",
        elements.itembar.move_next_item_pre
    )
    m.hook(
        "app.GUI020006PartsAllSlider.updateDispItems(System.Int32, via.gui.SelectItem, System.Int32)",
        elements.itembar.clear_cache_pre
    )
    m.hook("app.GUI020008.checkOpen()", util_ref.capture_this, elements.itembar.hide_radial_post)
end

function this.hud_hooks.ammo()
    m.hook("app.GUI020007.controlSliderStatus()", elements.ammo.no_hide_ammo_slider_parts_pre)
    m.hook(
        "app.GUI020007.setReloadState(System.String)",
        elements.ammo.no_hide_ammo_slider_reload_pre
    )
end

function this.hud_hooks.name_other()
    m.hook(
        "app.GUI020016PartsBase.checkIsVisible()",
        util_ref.capture_this,
        elements.name_other.hide_nameplate_post
    )
    m.hook("app.GUI020016.guiHudUpdate()", elements.name_other.name_other_update_player_pos_pre)
end

function this.hud_hooks.control()
    m.hook(
        "app.GUI020014.changeViewTypeState(System.Boolean)",
        elements.control.set_control_global_pos_pre,
        elements.control.set_control_global_pos_post
    )
end

function this.hud_hooks.progress()
    m.hook(
        "app.MissionManager.unLoadMissionData(app.MissionIDList.ID)",
        elements.progress.reset_progress_mission_pre
    )
    m.hook(
        "app.MissionManager.unLoadAllMissionData()",
        elements.progress.reset_progress_default_pre
    )
    m.hook("app.GUI020018.updateMission()", elements.progress.clear_cache_pre)
end

function this.hud_hooks.notice()
    m.hook("app.GUI020100.dispPanel(app.cGUI020100PanelBase)", elements.notice.cache_message_pre)
    m.hook(
        "app.ChatManager.pushBackLobbyLog(app.ChatDef.ChatBase)",
        elements.notice.skip_lobby_message_pre
    )
    m.hook(
        "app.ChatManager.pushBackSystemLog(app.ChatDef.SystemMessage, System.Boolean)",
        elements.notice.skip_system_message_pre
    )
    m.hook(
        "app.ChatManager.onReceiveSystem(app.net_packet.cChatBase, System.Boolean, System.Boolean, app.net_session_manager.SESSION_TYPE, System.Int32, System.Boolean, System.Boolean)",
        elements.notice.skip_auto_message_pre
    )
end

function this.hud_hooks.shortcut_keyboard()
    m.hook("app.cGUIMapFlowCtrl.update()", elements.shortcut_keyboard.reveal_minimap_pre)
    m.hook(
        "app.GUI020600.guiHudVisibleUpdate()",
        nil,
        elements.shortcut_keyboard.reveal_elements_post
    )
    m.hook("app.GUI020600.guiHudOpenUpdate()", nil, elements.shortcut_keyboard.reveal_elements_post)
    m.hook(
        "app.GUI020600.requestOpenPCShortcut(app.GUI020600.TYPE, System.Int32, System.Int32, app.GUI020600.MODE, via.gui.Rect)",
        elements.shortcut_keyboard.clear_cache_pre
    )
end

function this.hud_hooks.minimap()
    m.hook(
        "app.cGUIMapCameraController.updateCameraParam_Radar(System.Single)",
        util_ref.capture_this,
        elements.minimap.classic_minimap_param_update_post
    )
    m.hook(
        "app.cGUIMapIconModelSize.updateIconSizeParam()",
        util_ref.capture_this,
        elements.minimap.classic_minimap_icon_scale_post
    )
    m.hook(
        "app.cGUI060000Radar.getRadarSizeType(app.cPlayerManageInfo)",
        elements.minimap.classic_minimap_no_resize_pre
    )
end

function this.hud_hooks.quest_end_timer()
    m.hook(
        "app.GUI020202.guiVisibleUpdate()",
        util_ref.capture_this,
        elements.update.update_quest_end_timer_post
    )
end

function this.option_hooks.disable_scoutflies()
    m.hook(
        "app.cInteractGuideInsectController.isEnable()",
        nil,
        options.scoutflies.disable_scoutflies_post
    )
    m.hook(
        "app.mcGuideInsectNavigationController.startNavigation(System.Boolean, System.Boolean, System.Boolean, System.Boolean)",
        options.scoutflies.disable_scoutflies_pre
    )
    m.hook(
        "app.mcGuideInsectNavigationController"
            .. ".startNavigation(app.TARGET_ACCESS_KEY, via.vec3, System.Boolean, System.Boolean, System.Boolean, System.Boolean)",
        options.scoutflies.disable_scoutflies_target_tracking_pre
    )
    m.hook("app.GuideInsectCharacter.update()", options.scoutflies.disable_scoutflies_pre)
    m.hook(
        "app.cHunterEffect.updateGuideInsectCage(app.HunterCharacter)",
        options.scoutflies.disable_scoutflies_pre
    )
    m.hook(
        "app.cGUIMapNaviPointController.IsGuideInsectNavigating()",
        nil,
        options.scoutflies.hide_map_navi_points_post
    )
end

function this.option_hooks.disable_porter_call()
    m.hook(
        "app.PlayerCommonSubAction.cCallPorter.doEnter()",
        options.porter.disable_porter_call_cmd_pre,
        options.porter.update_porter_call_post
    )
    m.hook(
        "app.WpCommonSubAction.cCallPorter.doEnter()",
        options.porter.disable_porter_call_cmd_pre,
        options.porter.update_porter_call_post
    )
    m.hook(
        "app.btable.PlCommand.cPorterAskToRescure.callPorterRescue(app.cPlayerBTableCommandWork, System.Boolean)",
        options.porter.disable_porter_call_cmd_pre,
        options.porter.update_porter_call_post
    )
end

function this.option_hooks.hide_porter()
    m.hook("app.PorterManager.update()", nil, options.porter.hide_porter_post)
end

function this.option_hooks.disable_porter_tracking()
    m.hook(
        "app.mcPorterNavigationController.startNavigation(app.TARGET_ACCESS_KEY, System.Boolean)",
        options.porter.disable_porter_nav_pre
    )
end

function this.option_hooks.hide_monster_icon()
    m.hook(
        "app.cGUI060000OutFrameTarget.updateDrawIcon()",
        util_ref.capture_this,
        options.em.hide_monster_icon_out_post
    )
    m.hook(
        "app.cGUI060010utFrameTarget.updateDrawIcon()",
        util_ref.capture_this,
        options.em.hide_monster_icon_out_post
    )
    m.hook(
        "app.cGUI060000Recommend.cRecommendNoticeSign.playRecommendSign(app.cGUIBeaconBase, app.cGUI060000Recommend.cRecommendNoticeSign.TYPE)",
        options.em.hide_monster_recommend_pre
    )
    m.hook(
        "app.cGUI060000Recommend.onLateUpdate()",
        util_ref.capture_this,
        options.em.hide_monster_recommend_post
    )
    m.hook(
        "app.GUI060008.requestSummaryEnemy(app.cEnemyContextHolder)",
        options.em.skip_monster_select_pre
    )
    m.hook("app.GUIMapBeaconManager.update()", options.em.hide_monster_icon_pre)
    m.hook(
        "app.cEmGridPartition.getArrayLimitedRadius_Func(via.vec3, System.Single, System.Func`2<app.cEnemyManageInfo,System.Boolean>, System.Int32, System.Boolean)",
        options.em.get_near_monsters_pre,
        options.em.get_near_monsters_post
    )
end

function this.option_hooks.hide_small_monsters()
    m.hook("app.GUIMapBeaconManager.update()", options.em.hide_small_monsters_pre)
end

function this.option_hooks.monster_ignore_camp()
    m.hook(
        "app.cEmReactableGmInterface_Camp.get_AcceptableAIStates()",
        options.em.stop_camp_target_pre
    )
    m.hook(
        "app.mcGimmickBreak.isHit(app.HitInfo)",
        util_ref.capture_this,
        options.em.stop_camp_damage_post
    )
end

function this.option_hooks.hide_handler()
    m.hook("app.NpcManager.update()", nil, options.npc.hide_handler_post)
end

function this.option_hooks.hide_no_talk_npc()
    m.hook("app.NpcCharacter.doLateUpdateEnd()", options.npc.hide_no_talk_npc_pre)
end

function this.option_hooks.hide_pet()
    m.hook("app.OtomoManager.update()", options.npc.hide_pet_pre)
end

function this.option_hooks.disable_quest_intro()
    m.hook(
        "app.GUI020201.onOpen()",
        util_ref.capture_this,
        options.quest.disable_quest_intro_outro_post
    )
end

function this.option_hooks.disable_quest_end_outro()
    m.hook(
        "app.PlayerManager.evQuestFlowChanged(app.cQuestFlowPartsBase)",
        options.quest.skip_quest_end_animation_pre
    )
    m.hook(
        "app.CameraManager.onQuestFlowChanged(app.cQuestFlowPartsBase)",
        options.quest.skip_quest_end_animation_pre
    )
    m.hook("app.cQuestDirector.update()", util_ref.capture_this, options.quest.stop_hide_gui_post)
end

function this.option_hooks.disable_quest_end_camera()
    m.hook(
        "app.cQuestDirector.canPlayHuntCompleteCamera()",
        nil,
        options.quest.disable_quest_end_camera_post
    )
end

function this.option_hooks.skip_quest_end_timer()
    m.hook("app.cQuestSuccessFreePlayTime.enter()", options.quest.skip_quest_end_timer_pre)
    m.hook(
        "ace.GUIManagerBase`2<app.GUIID.ID,app.GUIFunc.TYPE>"
            .. ".openGUI(app.GUIID.ID, System.Object, ace.GUIDef.CtrlGUIFunc`2<app.GUIID.ID,app.GUIFunc.TYPE>, "
            .. "ace.GUIDef.CtrlGUICheckFunc`2<app.GUIID.ID,app.GUIFunc.TYPE>)",
        options.quest.skip_quest_end_timer_open_pre
    )
    m.hook("app.GUI020202.guiVisibleUpdate()", options.quest.hide_quest_end_input_pre)
end

function this.option_hooks.skip_quest_result()
    m.hook(
        "app.GUIFlowQuestResult.cContext.setup(app.cGUIQuestResultInfo.MODE, System.Boolean, System.Boolean, System.Boolean, System.Boolean, System.Boolean)",
        util_ref.capture_this,
        options.quest.hide_quest_result_setup_post
    )
    m.hook(
        "app.GUIFlowQuestResult.Flow.SeamlessResultList.onEnter()",
        options.quest.hide_quest_result_pre,
        options.quest.hide_quest_result_post
    )
    m.hook(
        "app.GUIFlowQuestResult.Flow.FixResultList.onEnter()",
        options.quest.hide_quest_result_pre,
        options.quest.hide_quest_result_post
    )
    m.hook("app.cBowlingUpdater.cUpdater_ResultEnd.onInit", options.quest.skip_bowling_result_pre)
end

function this.option_hooks.scar()
    m.hook(
        "app.EnemyScar.requestScarStamp(app.cEmModuleScar.cScarParts.STATE)",
        options.scar.disable_scar_stamp_pre
    )
    m.hook(
        "app.mcEnemyScarManager.activateScar(System.Int32, app.EnemyScar.CreateInfo, System.Boolean, app.cEmModuleScar.cScarParts.STATE)",
        options.scar.disable_scar_activate_pre
    )
    m.hook(
        "app.mcEnemyScarManager.changeState(System.Int32, app.cEmModuleScar.cScarParts.STATE, app.EnemyScar.CreateInfo, System.Boolean, System.Boolean)",
        options.scar.disable_scar_state_pre
    )
    m.hook(
        "app.cEnemyLoopEffectHighlight.isActivate()",
        util_ref.capture_this,
        options.scar.scar_state_post
    )
end

function this.option_hooks.hide_danger()
    m.hook(
        "app.AttackAreaResult.getDangerousDetectedDataList()",
        nil,
        options.player.hide_danger_line_post
    )
end

function this.option_hooks.hide_weapon()
    m.hook(
        "app.cMasterPlayerControllerEntity.entityUpdate()",
        options.player.hide_weapon_pre,
        options.player.hide_weapon_post
    )
end

function this.option_hooks.hide_subtitles()
    m.hook(
        "app.cDialogueSubtitleManager.dispText(app.cDialogueSubtitleManager.RequestData, System.Int32)",
        options.misc.hide_gossip_subtitles_pre
    )
end

function this.option_hooks.mute_gui()
    m.hook(
        "app.SoundGUITriggerManagerBase`3"
            .. "<app.SoundGUITriggerManager,app.GUIID.ID,app.GUIID.ID_Fixed>"
            .. ".request(System.Int32, System.Int32, System.Int32, System.UInt32, System.Boolean)",
        options.misc.disable_gui_sound_pre
    )
end

function this.option_hooks.disable_area_intro()
    m.hook(
        "app.GUI020206.requestBase(System.Guid, System.Guid, app.FieldDef.STAGE, app.FieldDef.LIFE_AREA, System.Boolean)",
        options.misc.disable_area_intro_pre
    )
end

function this.option_hooks.mute_gossip()
    m.hook(
        "app.SoundDialogueTriggerManager.shouldTrigger(app.DialogueDef.DialogueVoiceParam, soundlib.SoundContainer, System.UInt32)",
        options.misc.mute_gossip_subtitles_pre,
        options.misc.mute_gossip_subtitles_post
    )
end

function this.option_hooks.hide_aggro()
    m.hook(
        "app.mcReceivedEnemyStatePool.push(app.game_message.cEmChangeState)",
        options.player.hide_aggro_pre
    )
end

---@param fn fun()|fun()[]
local function hook_fn(fn)
    if type(fn) ~= "table" then
        fn = { fn }
    end

    for _, f in pairs(fn) do
        if not this.is_fun_hooked[f] then
            f()
            this.is_fun_hooked[f] = true
        end
    end
end

---@param hud_id app.GUIHudDef.TYPE
---@param hud_name string
function this.hook_hud(hud_id, hud_name)
    for _, gui_id in pairs(ace_map.hudid_to_guiid[hud_id]) do
        local gui_type = string.format("app.G%s", e.get("app.GUIID.ID")[gui_id])
        local key = string.format("%s|%s", hud_name, gui_type)

        if this.is_hud_hooked[key] then
            goto continue
        end

        -- NamesAccess is updated here @update_name_access_icons_post
        if
            util_ref.is_a_str(gui_type, "app.GUIHudBase")
            and hud_id ~= e.get("app.GUIHudDef.TYPE").NAME_ACCESSIBLE
        then
            on_render_hooks[gui_type] = true
        end

        local fn = this.hud[hud_name]
        if fn then
            hook_fn(fn)
        end

        this.is_hud_hooked[key] = true
        ::continue::
    end
end

function this.hook_option(option_key)
    if this.is_option_hooked[option_key] then
        return
    end

    local fn = this.option[option_key]
    if fn then
        hook_fn(fn)
    end

    this.is_option_hooked[option_key] = true
end

---@param profile_config  HudProfileConfig
function this.hook_options(profile_config)
    for k, _ in pairs(mod_map.options_hud) do
        if profile_config[k] then
            this.hook_option(k)
        end
    end
end

---@return boolean
function this.init()
    this.hud["TARGET_RETICLE"] = this.hud_hooks.target_reticle
    this.hud["MENU_BUTTON_GUIDE"] = this.hud_hooks.menu_button_guide
    this.hud["DAMAGE_NUMBERS"] = this.hud_hooks.damage_numbers
    this.hud["SUBTITLES"] = this.hud_hooks.subtitles
    this.hud["SUBTITLES_CHOICE"] = this.hud_hooks.subtitles
    this.hud["TRAINING_ROOM_HUD"] = this.hud_hooks.training_room_hud
    this.hud["NAME_ACCESS"] = this.hud_hooks.name_access
    this.hud["BARREL_BOWLING_SCORE"] = this.hud_hooks.barrel_bowling_score
    this.hud["CHAT_LOG"] = this.hud_hooks.chat_log
    this.hud["RADIAL"] = this.hud_hooks.radial
    this.hud["ITEMBAR"] = this.hud_hooks.itembar
    this.hud["AMMO"] = this.hud_hooks.ammo
    this.hud["NAME_OTHER"] = this.hud_hooks.name_other
    this.hud["CONTROL"] = this.hud_hooks.control
    this.hud["PROGRESS"] = this.hud_hooks.progress
    this.hud["NOTICE"] = this.hud_hooks.notice
    this.hud["SHORTCUT_KEYBOARD"] = this.hud_hooks.shortcut_keyboard
    this.hud["MINIMAP"] = this.hud_hooks.minimap
    this.hud["QUEST_END_TIMER"] = this.hud_hooks.quest_end_timer
    this.hud["BUTTON_PRESS"] = this.option_hooks.mute_gui
    --
    this.option["disable_scoutflies"] = this.option_hooks.disable_scoutflies
    this.option["disable_porter_call"] = this.option_hooks.disable_porter_call
    this.option["hide_porter"] =
        { this.option_hooks.hide_porter, this.option_hooks.disable_porter_call }
    this.option["disable_porter_tracking"] = this.option_hooks.disable_porter_tracking
    this.option["hide_monster_icon"] = {
        this.option_hooks.hide_monster_icon,
        this.hud_hooks.name_access,
        this.option_hooks.disable_scoutflies,
    }
    this.option["hide_lock_target"] = this.option_hooks.hide_monster_icon
    this.option["hide_small_monsters"] = this.option_hooks.hide_small_monsters
    this.option["monster_ignore_camp"] = this.option_hooks.monster_ignore_camp
    this.option["hide_handler"] = this.option_hooks.hide_handler
    this.option["hide_no_talk_npc"] = this.option_hooks.hide_no_talk_npc
    this.option["hide_no_facility_npc"] = this.option_hooks.hide_no_talk_npc
    this.option["hide_pet"] = this.option_hooks.hide_pet
    this.option["disable_quest_intro"] = this.option_hooks.disable_quest_intro
    this.option["disable_quest_end_outro"] =
        { this.option_hooks.disable_quest_intro, this.option_hooks.disable_quest_end_outro }
    this.option["disable_quest_end_camera"] = this.option_hooks.disable_quest_end_camera
    this.option["skip_quest_end_timer"] =
        { this.option_hooks.skip_quest_end_timer, this.option_hooks.mute_gui }
    this.option["hide_quest_end_timer"] = this.option_hooks.skip_quest_end_timer
    this.option["skip_quest_result"] = this.option_hooks.skip_quest_result
    this.option["disable_scar"] = this.option_hooks.scar
    this.option["show_scar"] = this.option_hooks.scar
    this.option["hide_scar"] = this.option_hooks.scar
    this.option["hide_danger"] = this.option_hooks.hide_danger
    this.option["hide_weapon"] = this.option_hooks.hide_weapon
    this.option["hide_subtitles"] = this.option_hooks.hide_subtitles
    this.option["mute_gui"] = this.option_hooks.mute_gui
    this.option["disable_area_intro"] = this.option_hooks.disable_area_intro
    this.option["mute_gossip"] = this.option_hooks.mute_gossip
    this.option["hide_aggro"] = this.option_hooks.hide_aggro

    return true
end

return this
