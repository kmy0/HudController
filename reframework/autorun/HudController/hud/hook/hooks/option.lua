---@class OptionHooks
---@field option_hooks table<string, fun()>
---@field option_mod_hooks table<string, fun()>

local common = require("HudController.hud.hook.common")
local hud = require("HudController.hud.init")
local m = require("HudController.util.ref.methods")
local options = require("HudController.hud.hook.options.init")
local options_mod = require("HudController.hud.hook.options_mod")
local util_ref = require("HudController.util.ref.init")

---@class OptionHooks
local this = {
    option_hooks = {},
    option_mod_hooks = {},
}

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
        options.scoutflies.disable_scoutflies_pre
    )
    m.hook("app.GuideInsectCharacter.update()", options.scoutflies.disable_scoutflies_pre)
    m.hook(
        "app.cHunterEffect.updateGuideInsectCage(app.HunterCharacter)",
        options.scoutflies.disable_scoutflies_pre
    )
    m.hook(
        "app.cGUIMapNaviPointController.IsGuideInsectNavigating()",
        nil,
        options.scoutflies.disable_scoutflies_post
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
    m.hook(
        "app.GUIAccessIconControl.lateUpdate()",
        util_ref.capture_this,
        options.em.hide_em_iteractables_post
    )
    m.hook(
        "app.mcGuideInsectNavigationController"
            .. ".startNavigation(app.TARGET_ACCESS_KEY, via.vec3, System.Boolean, System.Boolean, System.Boolean, System.Boolean)",
        options.em.disable_scoutflies_em_tracking_pre
    )
    m.hook(
        "app.cGUIMapNaviPointController.IsGuideInsectNavigating()",
        nil,
        options.em.hide_map_em_navi_points_post
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

function this.option_hooks.hide_npc()
    m.hook("app.NpcCharacter.doLateUpdateEnd()", options.npc.hide_npc_pre)
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

function this.option_hooks.mute_gui()
    common.mute_gui_element(function(_)
        local hud_config = common.get_hud()
        if not hud_config then
            return false
        end

        return hud.get_hud_option("mute_gui") or false
    end)
end

function this.option_hooks.disable_area_intro()
    m.hook(
        "app.GUI020206.requestBase(System.Guid, System.Guid, app.FieldDef.STAGE, app.FieldDef.LIFE_AREA, System.Boolean)",
        options.misc.disable_area_intro_pre
    )
end

function this.option_hooks.hide_aggro()
    m.hook(
        "app.mcReceivedEnemyStatePool.push(app.game_message.cEmChangeState)",
        options.player.hide_aggro_pre
    )
end

function this.option_mod_hooks.block_input()
    m.hook("app.GUIManager.lateUpdateApp()", nil, options_mod.block_input_all_post)
    m.hook(
        "app.GUI020006PartsSlider.callbackOther(ace.GUIDef.BUTTON_SLOT, via.gui.Control, via.gui.SelectItem, System.UInt32)",
        options_mod.block_input_itembar_pre
    )
end

function this.option_mod_hooks.draw_canvas()
    m.hook("app.GUIManager.isMouseCursorAvailable()", nil, options_mod.draw_canvas_cursor_post)
end

return this
