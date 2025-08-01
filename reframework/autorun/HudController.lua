local config = require("HudController.config")
local config_menu = require("HudController.gui")
local data = require("HudController.data")
local grid = require("HudController.gui.elements.grid")
local gui_debug = require("HudController.gui.debug")
local hook = require("HudController.hud.hook")
local hud = require("HudController.hud")
local util = require("HudController.util")

local init = util.misc.init_chain:new(
    config.init,
    data.init,
    util.game.bind.init,
    util.ace.scene_fade.init,
    util.ace.porter.init,
    config_menu.init,
    hud.manager.init,
    data.mod.init
)
---@class MethodUtil
local m = util.ref.methods

m.getGUIscreenPos = m.wrap(m.get("app.GUIUtilApp.getScreenPosByGrobalPosition(via.vec3)")) --[[@as fun(global_pos: via.vec3): via.vec3]]
m.getWeaponName = m.wrap(m.get("app.WeaponUtil.getWeaponTypeName(app.WeaponDef.TYPE)")) --[[@as fun(weapon_type: app.WeaponDef.TYPE): System.Guid]]
m.setOptionValue = m.wrap(m.get("app.OptionUtil.setOptionValue(app.Option.ID, System.Int32)")) --[[@as fun(option_id: app.Option.ID, option_value: System.Int32)]]
m.getOptionValue = m.wrap(m.get("app.OptionUtil.getOptionValue(app.Option.ID)")) --[[@as fun(option_id: app.Option.ID): System.Int32]]
m.getOptionData = m.wrap(m.get("app.OptionUtil.getOptionData(app.Option.ID)")) --[[@as fun(option_id: app.Option.ID): app.user_data.OptionData.Data]]
m.getPlayObjectFullPath = m.wrap(m.get("app.GUIUtilApp.getFullPath(via.gui.PlayObject)")) --[[@as fun(o: via.gui.PlayObject): System.String]]
m.getItemNum = m.wrap(m.get("app.ItemUtil.getItemNum(app.ItemDef.ID, app.ItemUtil.STOCK_TYPE)")) --[[@as fun(item_id: app.ItemDef.ID, stock_type: app.ItemUtil.STOCK_TYPE): System.Int32]]
-- bool is something story related if false
m.getHandlerNpcIDFixed = m.wrap(m.get("app.NpcPartnerUtil.getCurAdvisorID(System.Boolean)")) --[[@as fun(bool: System.Boolean): app.NpcDef.ID_Fixed]]

m.hook("app.cGUIHudDisplayManager.applySetting(app.cGUIHudDisplayControl)", hook.update_pre, hook.update_post)
m.hook("app.GUI020008.checkOpen()", util.ref.capture_this, hook.hide_radial_post)
m.hook(
    "app.GUI020008PartsPallet.callbackSelectICL(via.gui.Control, via.gui.SelectItem, System.UInt32, System.Int32, System.UInt32, System.Int32)",
    hook.hide_radial_pallet_pre
)
m.hook(
    "app.SoundGUITriggerManagerBase`3"
        .. "<app.SoundGUITriggerManager,app.GUIID.ID,app.GUIID.ID_Fixed>"
        .. ".request(System.Int32, System.Int32, System.Int32, System.UInt32, System.Boolean)",
    hook.disable_gui_sound_pre
)
m.hook(
    "app.cDialogueSubtitleManager.dispText(app.cDialogueSubtitleManager.RequestData, System.Int32)",
    hook.hide_subtitles_pre
)
m.hook("app.GUI020006.controlSliderOpen()", hook.open_expanded_itembar_pre)
m.hook(m.get_by_regex("app.GUI020007", "^<guiHudUpdate>.-1$") --[[@as REMethodDefinition]], hook.keep_ammo_open_pre)
m.hook(
    m.get_by_regex("app.GUI020017", "^<setupOpenCloseEvent>.-1$") --[[@as REMethodDefinition]],
    util.ref.capture_this,
    hook.keep_slinger_open1_post
)
m.hook(
    m.get_by_regex("app.GUI020017", "^<setupOpenCloseEvent>.-0$") --[[@as REMethodDefinition]],
    util.ref.capture_this,
    hook.keep_slinger_open0_post
)
m.hook("app.GUIManager.updatePlCommandMask()", nil, hook.unblock_camera_control_post)
m.hook("app.GUI020006PartsAllSlider.onLateUpdate()", util.ref.capture_this, hook.expanded_itembar_mouse_control_post)
m.hook("app.GUIManager.isMouseCursorAvailable()", nil, hook.force_cursor_visible_post)
m.hook("app.GUI000006.guiLateUpdate()", hook.force_mouse_pos_pre)
m.hook("app.GUI000006.updateMouseVisible()", hook.skip_mouse_update_pre)
m.hook("app.ChatManager.pushBackLobbyLog(app.ChatDef.ChatBase)", hook.skip_lobby_message_pre)
m.hook("app.ChatManager.pushBackSystemLog(app.ChatDef.SystemMessage, System.Boolean)", hook.skip_system_message_pre)
m.hook("app.GUI020006.callbackPouchChange(app.ItemDef.ID)", nil, hook.refresh_all_slider_post)
m.hook("app.ItemUtil.useItem(app.ItemDef.ID, System.Int16, System.Boolean)", hook.move_next_item_pre)
m.hook("app.GUIAccessIconControl.lateUpdate()", util.ref.capture_this, hook.hide_iteractables_post)
m.hook("app.cInteractGuideInsectController.isEnable()", nil, hook.disable_scoutflies_post)
m.hook(
    "app.mcGuideInsectNavigationController.startNavigation(System.Boolean, System.Boolean, System.Boolean, System.Boolean)",
    hook.disable_scoutflies_pre
)
m.hook(
    "app.mcGuideInsectNavigationController"
        .. ".startNavigation(app.TARGET_ACCESS_KEY, via.vec3, System.Boolean, System.Boolean, System.Boolean, System.Boolean)",
    hook.disable_scoutflies_target_tracking_pre
)
m.hook("app.GuideInsectCharacter.update()", hook.disable_scoutflies_pre)
m.hook("app.cHunterEffect.updateGuideInsectCage(app.HunterCharacter)", hook.disable_scoutflies_pre)
m.hook("app.PorterManager.update()", hook.hide_porter_post)
m.hook(
    "app.PlayerCommonSubAction.cCallPorter.doEnter()",
    hook.disable_porter_call_cmd_pre,
    hook.update_porter_call_post
)
m.hook("app.WpCommonSubAction.cCallPorter.doEnter()", hook.disable_porter_call_cmd_pre, hook.update_porter_call_post)
m.hook(
    "app.btable.PlCommand.cPorterAskToRescure.callPorterRescue(app.cPlayerBTableCommandWork, System.Boolean)",
    hook.disable_porter_call_cmd_pre,
    hook.update_porter_call_post
)
m.hook("app.NpcManager.update()", nil, hook.hide_handler_post)
m.hook("app.AttackAreaResult.getDangerousDetectedDataList()", nil, hook.hide_danger_line_post)
m.hook(
    "app.GUI020206.requestBase(System.Guid, System.Guid, app.FieldDef.STAGE, app.FieldDef.LIFE_AREA, System.Boolean)",
    hook.disable_area_intro_pre
)
m.hook("app.GUI020201.onOpen()", util.ref.capture_this, hook.disable_quest_intro_outro_post)
m.hook("app.GUI020016PartsBase.checkIsVisible()", util.ref.capture_this, hook.hide_nameplate_post)
m.hook("app.GUI020007.controlSliderStatus()", hook.no_hide_ammo_slider_parts_pre)
m.hook("app.GUI020007.setReloadState(System.String)", hook.no_hide_ammo_slider_reload_pre)
m.hook("app.cQuestDirector.canPlayHuntCompleteCamera()", nil, hook.disable_quest_end_camera_post)
m.hook("app.cGUI060000OutFrameTarget.updateDrawIcon()", util.ref.capture_this, hook.hide_icon_out_post)
m.hook("app.cGUI060010utFrameTarget.updateDrawIcon()", util.ref.capture_this, hook.hide_icon_out_post)
m.hook(
    "app.cGUI060000Recommend.cRecommendNoticeSign.playRecommendSign(app.cGUIBeaconBase, app.cGUI060000Recommend.cRecommendNoticeSign.TYPE)",
    hook.hide_recommend_pre
)
m.hook("app.cGUI060000Recommend.onLateUpdate()", util.ref.capture_this, hook.hide_recommend_post)
m.hook("app.GUI060008.requestSummaryEnemy(app.cEnemyContextHolder)", hook.skip_monster_select_pre)
m.hook("app.GUIMapBeaconManager.update()", hook.hide_monster_icon_pre)
m.hook("app.GUIMapBeaconManager.update()", hook.hide_small_monsters_pre)
m.hook(
    "app.cEmGridPartition.getArrayLimitedRadius_Func(via.vec3, System.Single, System.Func`2<app.cEnemyManageInfo,System.Boolean>, System.Int32, System.Boolean)",
    hook.get_near_monsters_pre,
    hook.get_near_monsters_post
)
m.hook("app.cQuestSuccessFreePlayTime.enter()", hook.skip_quest_end_timer_pre)
m.hook("app.PlayerManager.evQuestFlowChanged(app.cQuestFlowPartsBase)", hook.skip_quest_end_animation_pre)
m.hook("app.CameraManager.onQuestFlowChanged(app.cQuestFlowPartsBase)", hook.skip_quest_end_animation_pre)
m.hook(
    "app.GUIFlowQuestResult.cContext.setup(app.cGUIQuestResultInfo.MODE, System.Boolean, System.Boolean, System.Boolean, System.Boolean, System.Boolean)",
    util.ref.capture_this,
    hook.hide_quest_result_setup_post
)
m.hook(
    "app.GUIFlowQuestResult.Flow.SeamlessResultList.onEnter()",
    hook.hide_quest_result_pre,
    hook.hide_quest_result_post
)
m.hook("app.GUIFlowQuestResult.Flow.FixResultList.onEnter()", hook.hide_quest_result_pre, hook.hide_quest_result_post)
m.hook(
    "ace.GUIManagerBase`2<app.GUIID.ID,app.GUIFunc.TYPE>"
        .. ".openGUI(app.GUIID.ID, System.Object, ace.GUIDef.CtrlGUIFunc`2<app.GUIID.ID,app.GUIFunc.TYPE>, "
        .. "ace.GUIDef.CtrlGUICheckFunc`2<app.GUIID.ID,app.GUIFunc.TYPE>)",
    hook.skip_gui_open_pre
)
m.hook("app.cQuestDirector.update()", util.ref.capture_this, hook.stop_hide_gui_post)
m.hook("app.cDialogueSubtitleManager.updateDisp()", hook.update_subtitles_pre)
m.hook(
    "app.GUI020014.changeViewTypeState(System.Boolean)",
    hook.set_control_global_pos_pre,
    hook.set_control_global_pos_post
)
m.hook("app.cGUIMapNaviPointController.IsGuideInsectNavigating()", nil, hook.hide_map_navi_points_post)
m.hook("app.GUI020020.guiLateUpdate()", nil, hook.update_damage_numbers_post)
m.hook("app.GUI600100.guiUpdate()", util.ref.capture_this, hook.update_training_room_hud_post)
m.hook("app.GUI020202.guiVisibleUpdate()", hook.hide_quest_end_input)
m.hook("app.GUI020001PanelBase.onLateUpdate()", util.ref.capture_this, hook.update_name_access_icons_post)
m.hook("app.NpcCharacter.doLateUpdateEnd()", hook.hide_no_talk_npc_pre)
m.hook("app.cEmReactableGmInterface_Camp.get_AcceptableAIStates()", hook.stop_camp_target_pre)
m.hook("app.mcGimmickBreak.isHit(app.HitInfo)", util.ref.capture_this, hook.stop_camp_damage_post)
m.hook("app.EnemyScar.requestScarStamp(app.cEmModuleScar.cScarParts.STATE)", hook.disable_scar_stamp_pre)
m.hook(
    "app.mcEnemyScarManager.activateScar(System.Int32, app.EnemyScar.CreateInfo, System.Boolean, app.cEmModuleScar.cScarParts.STATE)",
    hook.disable_scar_activate_pre
)
m.hook(
    "app.mcEnemyScarManager.changeState(System.Int32, app.cEmModuleScar.cScarParts.STATE, app.EnemyScar.CreateInfo, System.Boolean, System.Boolean)",
    hook.disable_scar_state_pre
)
m.hook("app.MissionManager.unLoadMissionData(app.MissionIDList.ID)", hook.reset_progress_mission_pre)
m.hook("app.MissionManager.unLoadAllMissionData()", hook.reset_progress_default_pre)
m.hook("app.GUIManager.resetTitleApp()", nil, hook.reset_hud_default_post)
m.hook(
    "app.HunterCharacter.changeActionRequest(app.AppActionDef.LAYER, ace.ACTION_ID, System.Boolean)",
    hook.disable_focus_turn_pre
)
m.hook("app.HunterCharacter.isEnableAimTurn()", nil, hook.disable_focus_turn_post)
m.hook("app.cEnemyLoopEffectHighlight.isActivate()", util.ref.capture_this, hook.wound_state_post)
m.hook(
    "app.mcPorterNavigationController.startNavigation(app.TARGET_ACCESS_KEY, System.Boolean)",
    hook.disable_porter_nav
)
m.hook("app.GUI020016.guiHudUpdate()", hook.name_other_update_player_pos_pre)
m.hook("app.GUI020021.guiUpdate()", util.ref.capture_this, hook.update_target_reticle_post)

re.on_draw_ui(function()
    if imgui.button(string.format("%s %s", config.name, config.commit)) then
        config.current.gui.main.is_opened = not config.current.gui.main.is_opened
    end
end)

re.on_frame(function()
    if not init:init() then
        return
    end

    hud.update()

    if not reframework:is_drawing_ui() then
        config.current.gui.main.is_opened = false
        gui_debug.is_opened = false
    end

    if config.current.gui.main.is_opened then
        config_menu.draw()
    end

    if config.current.mod.grid.draw then
        grid.draw()
    end

    if gui_debug.is_opened then
        gui_debug.draw()
    end

    config.run_save()
end)

re.on_config_save(function()
    if data.mod.initialized then
        config.save_no_timer()
    end
end)
re.on_script_reset(hud.clear)
