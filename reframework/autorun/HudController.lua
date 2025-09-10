local call_queue = require("HudController.hud.call_queue")
local config = require("HudController.config")
local config_menu = require("HudController.gui")
local data = require("HudController.data")
local grid = require("HudController.gui.elements.grid")
local gui_debug = require("HudController.gui.debug")
local hook = require("HudController.hud.hook")
local hud = require("HudController.hud")
local hud_base = require("HudController.hud.def.hud_base")
local sorter = require("HudController.gui.elements.sorter")
local user = require("HudController.hud.user")
local util = require("HudController.util")
local logger = util.misc.logger.g

local init = util.misc.init_chain:new(
    "MAIN",
    config.init,
    data.init,
    util.game.bind.init,
    util.ace.scene_fade.init,
    util.ace.porter.init,
    config_menu.init,
    hud.manager.init,
    data.mod.init,
    user.init
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
m.sendEnemyMessage =
    m.wrap(m.get("app.ChatLogUtil.addEnemyLog(app.EnemyDef.ID, app.ChatDef.ENEMY_LOG_TYPE)")) --[[@as fun(em_id: app.EnemyDef.ID, msg_type: app.ChatDef.ENEMY_LOG_TYPE)]]
m.isGunnerWeapon =
    util.misc.cache.memoize(m.wrap(m.get("app.WeaponUtil.isGunnerWeapon(app.WeaponDef.TYPE)"))) --[[@as fun(weapon_type: app.WeaponDef.TYPE): System.Boolean]]

--#region elements
--#region update
m.hook(
    "app.cGUIHudDisplayManager.applySetting(app.cGUIHudDisplayControl)",
    hook.elements.update.update_pre,
    hook.elements.update.update_post
)
m.hook(
    "app.GUI020021.guiUpdate()",
    util.ref.capture_this,
    hook.elements.update.update_target_reticle_post
)
m.hook(
    "app.GUI000008.guiLateUpdate()",
    util.ref.capture_this,
    hook.elements.update.update_menu_button_guide_post
)
m.hook(
    "app.GUI020020.requestDamage(via.vec3, System.Single, app.GUI020020.State, app.TARGET_ACCESS_KEY.CATEGORY, "
        .. "app.GUI020020.DAMAGE_TYPE, app.GUI020020.CRITICAL_STATE, System.Boolean, "
        .. "System.Boolean, System.Action`1<app.GUI020020.DAMAGE_INFO>)",
    hook.elements.update.update_damage_numbers_static_pre
)
m.hook("app.cDialogueSubtitleManager.updateDisp()", hook.elements.update.update_subtitles_pre)
m.hook("app.GUI020020.guiLateUpdate()", nil, hook.elements.update.update_damage_numbers_post)
m.hook(
    "app.GUI600100.guiUpdate()",
    util.ref.capture_this,
    hook.elements.update.update_training_room_hud_post
)
m.hook(
    "app.GUI020001PanelBase.onLateUpdate()",
    util.ref.capture_this,
    hook.elements.update.update_name_access_icons_post
)
m.hook(
    "app.GUI090901.guiHudVisibleUpdate()",
    util.ref.capture_this,
    hook.elements.update.update_barrel_score_post
)
--#endregion
--#region radial
m.hook("app.GUI020008.checkOpen()", util.ref.capture_this, hook.elements.radial.hide_radial_post)
m.hook(
    "app.GUI020008PartsPallet.callbackSelectICL(via.gui.Control, via.gui.SelectItem, System.UInt32, System.Int32, System.UInt32, System.Int32)",
    hook.elements.radial.hide_radial_pallet_pre
)
--#endregion
--#region itembar
m.hook("app.GUI020006.controlSliderOpen()", hook.elements.itembar.open_expanded_itembar_pre)
m.hook(
    m.get_by_regex("app.GUI020007", "^<guiHudUpdate>.-1$") --[[@as REMethodDefinition]],
    hook.elements.itembar.keep_ammo_open_pre
)
m.hook(
    m.get_by_regex("app.GUI020017", "^<setupOpenCloseEvent>.-1$") --[[@as REMethodDefinition]],
    util.ref.capture_this,
    hook.elements.itembar.keep_slinger_open1_post
)
m.hook(
    m.get_by_regex("app.GUI020017", "^<setupOpenCloseEvent>.-0$") --[[@as REMethodDefinition]],
    util.ref.capture_this,
    hook.elements.itembar.keep_slinger_open0_post
)
m.hook(
    "app.GUIManager.updatePlCommandMask()",
    nil,
    hook.elements.itembar.unblock_camera_control_post
)
m.hook(
    "app.GUI020006PartsAllSlider.onLateUpdate()",
    util.ref.capture_this,
    hook.elements.itembar.expanded_itembar_mouse_control_post
)
m.hook(
    "app.GUIManager.isMouseCursorAvailable()",
    nil,
    hook.elements.itembar.force_cursor_visible_post
)
m.hook("app.GUI000006.guiLateUpdate()", hook.elements.itembar.force_mouse_pos_pre)
m.hook("app.GUI000006.updateMouseVisible()", hook.elements.itembar.skip_mouse_update_pre)
m.hook(
    "app.GUI020006.callbackPouchChange(app.ItemDef.ID)",
    nil,
    hook.elements.itembar.refresh_all_slider_post
)
m.hook(
    "app.ItemUtil.useItem(app.ItemDef.ID, System.Int16, System.Boolean)",
    hook.elements.itembar.move_next_item_pre
)
--#endregion
--#region ammo
m.hook("app.GUI020007.controlSliderStatus()", hook.elements.ammo.no_hide_ammo_slider_parts_pre)
m.hook(
    "app.GUI020007.setReloadState(System.String)",
    hook.elements.ammo.no_hide_ammo_slider_reload_pre
)
--#endregion
--#region name_other
m.hook(
    "app.GUI020016PartsBase.checkIsVisible()",
    util.ref.capture_this,
    hook.elements.name_other.hide_nameplate_post
)
m.hook("app.GUI020016.guiHudUpdate()", hook.elements.name_other.name_other_update_player_pos_pre)
--#endregion
--#region control
m.hook(
    "app.GUI020014.changeViewTypeState(System.Boolean)",
    hook.elements.control.set_control_global_pos_pre,
    hook.elements.control.set_control_global_pos_post
)
--#endregion
--#region progress
m.hook(
    "app.MissionManager.unLoadMissionData(app.MissionIDList.ID)",
    hook.elements.progress.reset_progress_mission_pre
)
m.hook(
    "app.MissionManager.unLoadAllMissionData()",
    hook.elements.progress.reset_progress_default_pre
)
m.hook("app.GUI020018.updateMission()", hook.elements.progress.clear_cache_pre)
--#endregion
--#region notice
m.hook("app.GUI020100.dispPanel(app.cGUI020100PanelBase)", hook.elements.notice.cache_message_pre)
m.hook(
    "app.ChatManager.pushBackLobbyLog(app.ChatDef.ChatBase)",
    hook.elements.notice.skip_lobby_message_pre
)
m.hook(
    "app.ChatManager.pushBackSystemLog(app.ChatDef.SystemMessage, System.Boolean)",
    hook.elements.notice.skip_system_message_pre
)
--#endregion
--#region name_access
m.hook(
    "app.GUIAccessIconControl.lateUpdate()",
    util.ref.capture_this,
    hook.elements.name_access.hide_iteractables_post
)
--#endregion
--#region shortcut_keyboard
m.hook("app.cGUIMapFlowCtrl.update()", hook.elements.shortcut_keyboard.reveal_minimap_pre)
m.hook(
    "app.GUI020600.guiHudVisibleUpdate()",
    nil,
    hook.elements.shortcut_keyboard.reveal_elements_post
)
m.hook(
    "app.GUI020600.guiHudOpenUpdate()",
    nil,
    hook.elements.shortcut_keyboard.reveal_elements_post
)
--#endregion
--#endregion

--#region options
--#region scoutflies
m.hook(
    "app.cInteractGuideInsectController.isEnable()",
    nil,
    hook.options.scoutflies.disable_scoutflies_post
)
m.hook(
    "app.mcGuideInsectNavigationController.startNavigation(System.Boolean, System.Boolean, System.Boolean, System.Boolean)",
    hook.options.scoutflies.disable_scoutflies_pre
)
m.hook(
    "app.mcGuideInsectNavigationController"
        .. ".startNavigation(app.TARGET_ACCESS_KEY, via.vec3, System.Boolean, System.Boolean, System.Boolean, System.Boolean)",
    hook.options.scoutflies.disable_scoutflies_target_tracking_pre
)
m.hook("app.GuideInsectCharacter.update()", hook.options.scoutflies.disable_scoutflies_pre)
m.hook(
    "app.cHunterEffect.updateGuideInsectCage(app.HunterCharacter)",
    hook.options.scoutflies.disable_scoutflies_pre
)
m.hook(
    "app.cGUIMapNaviPointController.IsGuideInsectNavigating()",
    nil,
    hook.options.scoutflies.hide_map_navi_points_post
)
--#endregion
--#region porter
m.hook("app.PorterManager.update()", nil, hook.options.porter.hide_porter_post)
m.hook(
    "app.PlayerCommonSubAction.cCallPorter.doEnter()",
    hook.options.porter.disable_porter_call_cmd_pre,
    hook.options.porter.update_porter_call_post
)
m.hook(
    "app.WpCommonSubAction.cCallPorter.doEnter()",
    hook.options.porter.disable_porter_call_cmd_pre,
    hook.options.porter.update_porter_call_post
)
m.hook(
    "app.btable.PlCommand.cPorterAskToRescure.callPorterRescue(app.cPlayerBTableCommandWork, System.Boolean)",
    hook.options.porter.disable_porter_call_cmd_pre,
    hook.options.porter.update_porter_call_post
)
m.hook(
    "app.mcPorterNavigationController.startNavigation(app.TARGET_ACCESS_KEY, System.Boolean)",
    hook.options.porter.disable_porter_nav_pre
)
--#endregion
--#region em
m.hook(
    "app.cGUI060000OutFrameTarget.updateDrawIcon()",
    util.ref.capture_this,
    hook.options.em.hide_monster_icon_out_post
)
m.hook(
    "app.cGUI060010utFrameTarget.updateDrawIcon()",
    util.ref.capture_this,
    hook.options.em.hide_monster_icon_out_post
)
m.hook(
    "app.cGUI060000Recommend.cRecommendNoticeSign.playRecommendSign(app.cGUIBeaconBase, app.cGUI060000Recommend.cRecommendNoticeSign.TYPE)",
    hook.options.em.hide_monster_recommend_pre
)
m.hook(
    "app.cGUI060000Recommend.onLateUpdate()",
    util.ref.capture_this,
    hook.options.em.hide_monster_recommend_post
)
m.hook(
    "app.GUI060008.requestSummaryEnemy(app.cEnemyContextHolder)",
    hook.options.em.skip_monster_select_pre
)
m.hook("app.GUIMapBeaconManager.update()", hook.options.em.hide_monster_icon_pre)
m.hook("app.GUIMapBeaconManager.update()", hook.options.em.hide_small_monsters_pre)
m.hook(
    "app.cEmGridPartition.getArrayLimitedRadius_Func(via.vec3, System.Single, System.Func`2<app.cEnemyManageInfo,System.Boolean>, System.Int32, System.Boolean)",
    hook.options.em.get_near_monsters_pre,
    hook.options.em.get_near_monsters_post
)
m.hook(
    "app.cEmReactableGmInterface_Camp.get_AcceptableAIStates()",
    hook.options.em.stop_camp_target_pre
)
m.hook(
    "app.mcGimmickBreak.isHit(app.HitInfo)",
    util.ref.capture_this,
    hook.options.em.stop_camp_damage_post
)
--#endregion
--#region npc
m.hook("app.NpcManager.update()", nil, hook.options.npc.hide_handler_post)
m.hook("app.NpcCharacter.doLateUpdateEnd()", hook.options.npc.hide_no_talk_npc_pre)
m.hook("app.OtomoManager.update()", hook.options.npc.hide_pet_pre)
--#endregion
--#region quest
m.hook(
    "app.GUI020201.onOpen()",
    util.ref.capture_this,
    hook.options.quest.disable_quest_intro_outro_post
)
m.hook(
    "app.cQuestDirector.canPlayHuntCompleteCamera()",
    nil,
    hook.options.quest.disable_quest_end_camera_post
)
m.hook("app.cQuestSuccessFreePlayTime.enter()", hook.options.quest.skip_quest_end_timer_pre)
m.hook(
    "app.PlayerManager.evQuestFlowChanged(app.cQuestFlowPartsBase)",
    hook.options.quest.skip_quest_end_animation_pre
)
m.hook(
    "app.CameraManager.onQuestFlowChanged(app.cQuestFlowPartsBase)",
    hook.options.quest.skip_quest_end_animation_pre
)
m.hook(
    "app.GUIFlowQuestResult.cContext.setup(app.cGUIQuestResultInfo.MODE, System.Boolean, System.Boolean, System.Boolean, System.Boolean, System.Boolean)",
    util.ref.capture_this,
    hook.options.quest.hide_quest_result_setup_post
)
m.hook(
    "app.GUIFlowQuestResult.Flow.SeamlessResultList.onEnter()",
    hook.options.quest.hide_quest_result_pre,
    hook.options.quest.hide_quest_result_post
)
m.hook(
    "app.GUIFlowQuestResult.Flow.FixResultList.onEnter()",
    hook.options.quest.hide_quest_result_pre,
    hook.options.quest.hide_quest_result_post
)
m.hook(
    "ace.GUIManagerBase`2<app.GUIID.ID,app.GUIFunc.TYPE>"
        .. ".openGUI(app.GUIID.ID, System.Object, ace.GUIDef.CtrlGUIFunc`2<app.GUIID.ID,app.GUIFunc.TYPE>, "
        .. "ace.GUIDef.CtrlGUICheckFunc`2<app.GUIID.ID,app.GUIFunc.TYPE>)",
    hook.options.quest.skip_quest_end_timer_open_pre
)
m.hook("app.cQuestDirector.update()", util.ref.capture_this, hook.options.quest.stop_hide_gui_post)
m.hook("app.GUI020202.guiVisibleUpdate()", hook.options.quest.hide_quest_end_input_pre)
m.hook("app.cBowlingUpdater.cUpdater_ResultEnd.onInit", hook.options.quest.skip_bowling_result_pre)
--#endregion
--#region scar
m.hook(
    "app.EnemyScar.requestScarStamp(app.cEmModuleScar.cScarParts.STATE)",
    hook.options.scar.disable_scar_stamp_pre
)
m.hook(
    "app.mcEnemyScarManager.activateScar(System.Int32, app.EnemyScar.CreateInfo, System.Boolean, app.cEmModuleScar.cScarParts.STATE)",
    hook.options.scar.disable_scar_activate_pre
)
m.hook(
    "app.mcEnemyScarManager.changeState(System.Int32, app.cEmModuleScar.cScarParts.STATE, app.EnemyScar.CreateInfo, System.Boolean, System.Boolean)",
    hook.options.scar.disable_scar_state_pre
)
m.hook(
    "app.cEnemyLoopEffectHighlight.isActivate()",
    util.ref.capture_this,
    hook.options.scar.scar_state_post
)
--#endregion
--#region player
m.hook(
    "app.AttackAreaResult.getDangerousDetectedDataList()",
    nil,
    hook.options.player.hide_danger_line_post
)
m.hook(
    "app.HunterCharacter.changeActionRequest(app.AppActionDef.LAYER, ace.ACTION_ID, System.Boolean)",
    hook.options.player.disable_focus_turn_pre
)
m.hook("app.HunterCharacter.isEnableAimTurn()", nil, hook.options.player.disable_focus_turn_post)
m.hook(
    "app.cMasterPlayerControllerEntity.entityUpdate()",
    hook.options.player.hide_weapon_pre,
    hook.options.player.hide_weapon_post
)
--#endregion
--#region misc
m.hook(
    "app.cDialogueSubtitleManager.dispText(app.cDialogueSubtitleManager.RequestData, System.Int32)",
    hook.options.misc.hide_gossip_subtitles_pre
)
m.hook(
    "app.SoundGUITriggerManagerBase`3"
        .. "<app.SoundGUITriggerManager,app.GUIID.ID,app.GUIID.ID_Fixed>"
        .. ".request(System.Int32, System.Int32, System.Int32, System.UInt32, System.Boolean)",
    hook.options.misc.disable_gui_sound_pre
)
m.hook(
    "app.GUI020206.requestBase(System.Guid, System.Guid, app.FieldDef.STAGE, app.FieldDef.LIFE_AREA, System.Boolean)",
    hook.options.misc.disable_area_intro_pre
)
--#endregion
--#endregion

--#region misc
m.hook("app.GUIManager.resetTitleApp()", nil, hook.misc.reset_hud_default_post)
m.hook(
    "app.HunterCharacter.warp(via.vec3, System.Nullable`1<via.Quaternion>, System.Boolean)",
    nil,
    hook.misc.reset_cache_post
)
--#endregion

re.on_draw_ui(function()
    if imgui.button(string.format("%s %s", config.name, config.commit)) and init.ok then
        local gui_main = config.gui.current.gui.main
        gui_main.is_opened = not gui_main.is_opened
    end

    if not init.failed then
        local errors = logger:format_errors()
        if errors then
            imgui.same_line()
            imgui.text_colored("Error!", config_menu.state.colors.bad)
            util.imgui.tooltip_exclamation(errors)
        elseif not init.ok then
            imgui.same_line()
            imgui.text_colored("Initializing...", config_menu.state.colors.info)
        end
    else
        imgui.same_line()
        imgui.text_colored("Init failed!", config_menu.state.colors.bad)
    end
end)

re.on_application_entry("BeginRendering", function()
    init:init() -- reframework does not like nested re.on_frame
end)

re.on_frame(function()
    if not init.ok then
        return
    end

    hud.update()

    local config_gui = config.gui.current.gui
    local config_mod = config.current.mod

    if not reframework:is_drawing_ui() then
        config_gui.main.is_opened = false
        config_gui.debug.is_opened = false
    end

    if config_gui.main.is_opened then
        config_menu.draw()
    end

    if config_mod.grid.draw then
        grid.draw()
    end

    if config_gui.debug.is_opened then
        gui_debug.draw()
    end

    if sorter.is_opened then
        sorter.draw()
    end

    config.run_save()
end)

re.on_config_save(function()
    if data.mod.initialized then
        config.save_no_timer_global()
    end
end)
re.on_script_reset(function()
    hud.clear()
    call_queue.clear()
    hud_base.restore_all_force_invis()
end)
