---@meta

---@class app.AppBehavior : via.Behavior
---@class app.cGameContext : via.clr.ManagedObject
---@class app.cGameContextHolder : via.clr.ManagedObject
---@class app.AttackAreaResult : via.clr.ManagedObject
---@class app.cCharacterExtendBase : via.clr.ManagedObject
---@class app.GUIBaseApp : ace.GUIBase
---@class app.cGUIPartsBaseApp : ace.cGUIPartsBase
---@class app.MissionGuideGUIParts.SmallMissionPanelBase : app.MissionGuideGUIParts.MissionGuidePartsBase
---@class app.GUI020010Accessor : app.cGUIAppAccessorBase
---@class app.GUI020006Accessor : app.cGUIAppAccessorBase
---@class app.GUI060002Accessor : app.cGUIAppAccessorBase
---@class app.StatusIconManager : app.StatusIconManagerBase
---@class app.GUI020010 : app.GUIHudBase
---@class app.GUI020008 : app.GUIHudBase
---@class app.user_data.OptionData.Item : app.user_data.OptionData.Base
---@class app.cGUIBeaconContainerBase : via.clr.ManagedObject
---@class app.cQuestFlowPartsBase : via.clr.ManagedObject
---@class app.cGUIFlowContextBaseApp : ace.cGUIFlowContextBase
---@class app.GUI020003 : app.GUIGaugeHudBase
---@class app.GUI020020.DAMAGE_INFO : System.ValueType
---@class app.GUI020001 : app.GUIHudBase
---@class app.MissionGuideGUIParts.TaskPanelData : app.MissionGuideGUIParts.SmallMissionPanelBase
---@class app.mcGimmickBreak : app.mcGimmick
---@class app.GimmickBaseApp : ace.GimmickBase
---@class app.cActionController : via.clr.ManagedObject
---@class app.cEnemyEntrustMultipleLoopEffectState : app.cEnemyEntrustEffectState
---@class app.cEnemyEntrustEffectState : via.clr.ManagedObject
---@class app.cGuideInsectContext.cTargetInfo.cNavigationTargetInfoGuideInsect : app.cNavigationTargetInfo
---@class app.cGUI3DMapModelContollerBase : ace.cGUIPartsBase
---@class app.GUI060000 : app.GUIBaseApp
---@class app.CONTEXT_HANDLE : System.ValueType
---@class app.FacilityBase : via.clr.ManagedObject
---@class app.cBowlingUpdater.UpdaterBase : via.clr.ManagedObject
---@class app.GUI090901 : app.GUIHudBase
---@class app.GUI020600PartsFrame : app.cGUIPartsShortcutFrameBase
---@class app.GUI020002_PartsBase : via.clr.ManagedObject
---@class ace.cGUISystemModuleBase : via.clr.ManagedObject

---@class app.ChatManager : ace.GAElement
---@field addSystemLog fun(self: app.ChatManager, message: System.String)

---@class app.GUIManager : ace.GUIManagerBase
---@field get_HudDisplayManager fun(self: app.GUIManager): app.cGUIHudDisplayManager
---@field get_GUI020018Accessor fun(self: app.GUIManager): app.GUI020018Accessor
---@field get_GUI020006Accessor fun(self: app.GUIManager): app.GUI020006Accessor
---@field get_GUI020100Accessor fun(self: app.GUIManager): app.GUI020010Accessor
---@field get_GUI060002Accessor fun(self: app.GUIManager): app.GUI060002Accessor
---@field get_MAP3D fun(self: app.GUIManager): app.cGUIMapController
---@field set_IsAllSliderMode fun(self: app.GUIManager, state: System.Boolean)
-- bool sets <SelectedIndexRequest>k__BackingField to true
---@field addActiveItem fun(self: app.GUIManager, item_id: app.ItemDef.ID, bool: System.Boolean)
---@field get_AppContinueFlag fun(self: app.GUIManager): ace.cSafeContinueFlag
---@field getQuestResult fun(self: app.GUIManager): app.cGUISystemModuleQuestResult

---@class app.cGUIMapController : via.clr.ManagedObject
---@field get_GUIBack fun(self: app.cGUIMapController): app.GUI060001
---@field get_GUIFront fun(self: app.cGUIMapController): app.GUI060000

---@class app.GUI020018Accessor : app.cGUIAppAccessorBase
---@field MissionGuideGUI app.GUI020018

---@class app.cGUIAppAccessorBase : via.clr.ManagedObject
---@field GUIs System.Array<ace.GUIBase>

---@class app.cGUIHudDisplayManager : via.clr.ManagedObject
---@field findDisplayControl fun(self: app.cGUIHudDisplayManager, gui_id: app.GUIID.ID): app.cGUIHudDisplayControl?
---@field getHudSetting fun(self: app.cGUIHudDisplayManager, gui_id: app.GUIID.ID): app.user_data.GUIHudData.cSetting
---@field applySetting fun(self: app.cGUIHudDisplayManager, ctrl: app.cGUIHudDisplayControl)
---@field setHudDisplay fun(self: app.cGUIHudDisplayManager, hud_id: app.GUIHudDef.TYPE, hud_display: app.GUIHudDef.DISPLAY)
---@field getHudDisplay fun(self: app.cGUIHudDisplayManager, hud_id: app.GUIHudDef.TYPE): app.GUIHudDef.DISPLAY
---@field _HudData app.user_data.GUIHudData
---@field _DisplayControls System.Array<app.cGUIHudDisplayControl>

---@class app.user_data.GUIHudData : via.UserData
---@field _Settings System.Array<app.user_data.GUIHudData.cSetting>

---@class app.user_data.GUIHudData.cSetting : via.clr.ManagedObject
---@field get_Type fun(self: app.user_data.GUIHudData.cSetting): app.GUIHudDef.TYPE
---@field get_Id fun(self: app.user_data.GUIHudData.cSetting): app.GUIID.ID

---@class app.cGUIHudDisplayControl : via.clr.ManagedObject
---@field get_Owner fun(self: app.cGUIHudDisplayControl): app.GUIHudBase
---@field isHudOpen fun(self: app.cGUIHudDisplayControl): System.Boolean
---@field _TargetControl via.gui.Control

---@class app.GUIHudBase : app.GUIBaseApp
---@field _DisplayControl app.cGUIHudDisplayControl

---@class app.GUIGaugeHudBase : app.GUIHudBase
---@field _StatusIconManager app.StatusIconManager

---@class app.WeaponGUIHudBase : app.GUIHudBase

---@class app.StatusIconManagerBase : via.clr.ManagedObject
---@field _PanelStatusIcon via.gui.Panel
---@field _StatusIconInfoList System.Array<app.StatusIconInfo>

---@class app.StatusIconInfo : via.clr.ManagedObject
---@field get_StatusIconPanel fun(self: app.StatusIconInfo): via.gui.Panel

---@class app.GUI020018 : app.GUIHudBase
---@field _TimerPanelData app.MissionGuideGUIParts.TimePanelData
---@field _WatchPanelData app.MissionGuideGUIParts.WatchPanelData
---@field _DiePanelData app.MissionGuideGUIParts.TaskPanelData
---@field _BestRecordPanelData app.MissionGuideGUIParts.BestRecordData
---@field _DispSmallMissionTargetList System.Array<app.MissionGuideGUIParts.MissionGuideGUIDef.SmallMissionInfo>
---@field _MissionDuplicatePanelDataList System.Array<app.MissionGuideGUIParts.MissionGuidePartsBase>
---@field _FadeInWaitPanelList System.Array<app.MissionGuideGUIParts.MissionGuidePartsBase>
---@field releaseSmallMissionGuide fun(self: app.GUI020018, mission_info: app.MissionGuideGUIParts.MissionGuideGUIDef.SmallMissionInfo)
---@field createSmallMissionGuide fun(self: app.GUI020018, mission_info: app.MissionGuideGUIParts.MissionGuideGUIDef.SmallMissionInfo, panel_type: app.GUI020018.GUIDE_PANEL_TYPE): app.MissionGuideGUIParts.SmallMissionPanelBase

---@class app.MissionGuideGUIParts.BestRecordData : app.MissionGuideGUIParts.SmallMissionPanelBase
---@field _arenaRankPanel via.gui.Panel

---@class app.MissionGuideGUIParts.MissionGuideGUIDef.SmallMissionInfo : via.clr.ManagedObject
---@field IsEnableCheck System.Boolean

---@class app.MissionGuideGUIParts.WatchPanelData : app.MissionGuideGUIParts.SmallMissionPanelBase
---@field isVisibleWatch fun(self: app.MissionGuideGUIParts.WatchPanelData): System.Boolean

---@class app.MissionGuideGUIParts.TimePanelData : app.MissionGuideGUIParts.SmallMissionPanelBase
---@field _TextTime via.gui.Text
---@field get_SmallMissionInfo fun(self: app.MissionGuideGUIParts.TimePanelData): app.MissionGuideGUIParts.MissionGuideGUIDef.SmallMissionInfo
---@field getIsArenaQuest fun(self: app.MissionGuideGUIParts.TimePanelData): System.Boolean

---@class app.MissionGuideGUIParts.MissionGuidePartsBase : app.cGUIPartsBaseApp
---@field _DuplicatePanel via.gui.Panel

---@class app.MissionManager : ace.GAElementBase
---@field get_QuestDirector fun(self: app.MissionManager): app.cQuestDirector
---@field isFastTravel fun(self: app.MissionManager): System.Boolean

---@class app.cQuestDirector : via.clr.ManagedObject
---@field get_QuestElapsedTime fun(self: app.cQuestDirector): System.Single
---@field isTargetClearAll fun(self: app.cQuestDirector): System.Boolean
---@field QuestReturnSkip fun(self: app.cQuestDirector)
---@field isPlayingQuest fun(self: app.cQuestDirector): System.Boolean
---@field isQuestEndShowing fun(self: app.cQuestDirector): System.Boolean
---@field get_CurFlow fun(self: app.cQuestDirector): app.cQuestFlowPartsBase

---@class app.PlayerManager : ace.GAElementBase
---@field getMasterPlayer fun(self: app.PlayerManager): app.cPlayerManageInfo
---@field get_InstancedPlayerNum fun(self: app.PlayerManager): System.UInt32

---@class app.cPlayerManageInfo : via.clr.ManagedObject
---@field get_Character fun(self: app.cPlayerManageInfo): app.HunterCharacter

---@class app.HunterCharacter : app.CharacterBase
---@field get_WeaponType fun(self: app.HunterCharacter): app.WeaponDef.TYPE
---@field get_IsCombat fun(self: app.HunterCharacter): System.Boolean
---@field get_IsWeaponOn fun(self: app.HunterCharacter): System.Boolean
---@field get_IsWeaponOnAction fun(self: app.HunterCharacter): System.Boolean
---@field get_HunterExtend fun(self: app.HunterCharacter): app.HunterCharacter.cHunterExtendBase
---@field get_MeshFadeController fun(self: app.HunterCharacter): app.cMeshFadeController
---@field get_PorterComm fun(self: app.HunterCharacter): app.mcPorterCommunicator
---@field get_IsInBaseCamp fun(self: app.HunterCharacter): System.Boolean
---@field get_IsInTent fun(self: app.HunterCharacter): System.Boolean
---@field _HunterContinueFlag ace.cSafeContinueFlagGroup
---@field _HunterBTableCommandFlag ace.cSafeContinueFlag

---@class app.mcPorterCommunicator : ace.minicomponent.cOrderedActionBase
---@field get_IsRiderWithinRanged fun(self: app.mcPorterCommunicator): System.Boolean
---@field isQuestClearGestureEnabled fun(self: app.mcPorterCommunicator): System.Boolean

---@class app.HunterCharacter.cHunterExtendBase : app.cCharacterExtendBase
---@field get_IsNpc fun(self: app.HunterCharacter.cHunterExtendBase): System.Boolean

---@class app.HunterCharacter.cHunterExtendNpc : app.HunterCharacter.cHunterExtendBase
---@field get_NpcID fun(self: app.HunterCharacter.cHunterExtendNpc): app.NpcDef.ID
---@field _ContextHolder app.cNpcContextHolder

---@class app.cNpcContextHolder : app.cGameContextHolder
---@field get_Npc fun(self: app.cNpcContextHolder): app.cNpcContext

---@class app.cNpcContext : app.cGameContext
---@field NpcContinueFlag ace.cSafeContinueFlagGroup
---@field NpcID app.NpcDef.ID

---@class app.user_data.VariousDataManagerSetting : via.UserData
---@field get_GUIVariousData fun(self: app.user_data.VariousDataManagerSetting): app.user_data.GUIVariousData

---@class app.VariousDataManager : ace.GAElement
---@field get_Setting fun(self: app.VariousDataManager) : app.user_data.VariousDataManagerSetting

---@class app.user_data.GUIVariousData : via.UserData
---@field get_HudDisplayOptionData fun(self: app.user_data.GUIVariousData): app.user_data.HudDisplayOptionData

---@class app.user_data.HudDisplayOptionData : via.UserData
---@field getSetting fun(self: app.user_data.HudDisplayOptionData, type: app.GUIHudDef.TYPE): app.user_data.HudDisplayOptionData.cSetting

---@class app.user_data.HudDisplayOptionData.cSetting : via.UserData
---@field get_Name fun(self: app.user_data.HudDisplayOptionData.cSetting): System.Guid
---@field get_DisableHide fun(self: app.user_data.HudDisplayOptionData.cSetting): System.Boolean

---@class app.user_data.OptionData.Data : app.user_data.OptionData.Base
---@field get_Items fun(self: app.user_data.OptionData.Data): System.Array<app.user_data.OptionData.Item>

---@class app.user_data.OptionData.Base : via.clr.ManagedObject
---@field get_MsgTitle fun(self: app.user_data.OptionData.Base): System.Guid

---@class app.cDialogueSubtitleManager.RequestData : via.clr.ManagedObject
---@field SubTitleParam app.DialogueDef.SubTitleParam

---@class app.DialogueDef.SubTitleParam : via.clr.ManagedObject
---@field DialogueType app.DialogueType.TYPE

---@class app.GUI020006 : app.GUIHudBase
---@field get_IsItemSliderMode fun(self: app.GUI020006): System.Boolean
---@field get_IsAllSliderMode fun(self: app.GUI020006): System.Boolean
---@field startAllSlider fun(self: app.GUI020006)
---@field endAllSlider fun(self: app.GUI020006)
---@field get_StateAllSliderIN fun(self: app.GUI020006): ace.cGUIParamState
---@field set_IsAllSliderMode fun(self: app.GUI020006, state: System.Boolean)
---@field get__PartsAllSlider fun(self: app.GUI020006): app.GUI020006PartsAllSlider
---@field get__PanelAllSlider fun(self: app.GUI020006): via.gui.Panel
---@field get_getIsItemSliderMode fun(self: app.GUI020006): System.Boolean
---@field initAllList fun(self: app.GUI020006)
---@field get_ItemPouchDisp fun(self: app.GUI020006): app.cGUIItemPouch
---@field get_SelectedItemId fun(self: app.GUI020006): app.ItemDef.ID
---@field get__PartsSlider fun(self: app.GUI020006): app.GUI020006PartsSlider

---@class app.cGUIItemPouch : via.clr.ManagedObject
---@field get_PouchItemCopy fun(self: app.cGUIItemPouch): System.Array<app.savedata.cItemWork>

---@class app.savedata.cItemWork : ace.cSaveDataParam
---@field get_ItemId fun(self: app.savedata.cItemWork): app.ItemDef.ID
---@field Num System.Int16

---@class app.GUI020006PartsAllSlider : app.cGUIPartsBaseApp
---@field startStackState fun(self: app.GUI020006PartsAllSlider)
---@field getCurrentItem fun(self: app.GUI020006PartsAllSlider): app.GUI020006PartsAllSliderItem
---@field callbackOther fun(self: app.GUI020006PartsAllSlider, button_slot: ace.GUIDef.BUTTON_SLOT, fsg_pnl: via.gui.Control, selected_item: via.gui.SelectItem, list_index: System.UInt32)
---@field callbackSelect fun(self: app.GUI020006PartsAllSlider, fsg_pnl: via.gui.Control, selected_item: via.gui.SelectItem, previous_index: System.UInt32, current_index: System.Int32)
---@field get__GridParts fun(self: app.GUI020006PartsAllSlider): System.Array<app.GUI020006PartsAllSliderItem>
---@field getGridPartsFromItemId fun(self: app.GUI020006PartsAllSlider, item_id: app.ItemDef.ID): app.GUI020006PartsAllSliderItem
---@field setPanelActivePanelInfo fun(self: app.GUI020006PartsAllSlider, grid_item: app.GUI020006PartsAllSliderItem)
---@field get__AllSliderCtrl fun(self: app.GUI020006PartsAllSlider): ace.cGUIInputCtrl_FluentScrollGrid
---@field SLOT_ITEM_USE ace.GUIDef.BUTTON_SLOT

---@class app.GUI020006PartsAllSliderItem : via.clr.ManagedObject
---@field get__BaseItem fun(self: app.GUI020006PartsAllSliderItem): via.gui.SelectItem

---@class app.GUI020017 : app.GUIHudBase
---@field get__SetMainAmmoType fun(self: app.GUI020017): app.HunterDef.SLINGER_AMMO_TYPE

---@class app.GameInputManager : ace.GAElement
---@field _PlayerButtonMaskFlagStore System.Array<ace.BIT_FLAG>

---@class app.GUI000006 : app.GUIBaseApp
---@field get_CurrentCursorPosition fun(self: app.GUI000006): via.Point
---@field setCursorPosition fun(self: app.GUI000006, pos: via.Point)

---@class app.ChatDef.SystemMessage : app.ChatDef.MessageElement
---@field get_SystemMsgType fun(self: app.ChatDef.SystemMessage) : app.ChatDef.SYSTEM_MSG_TYPE

---@class app.ChatDef.ChatBase : app.ChatDef.MessageElement
---@field get_SendTarget fun(self: app.ChatDef.ChatBase): app.ChatDef.SEND_TARGET

---@class app.GUI020006PartsSlider : ace.cGUIPartsBase
---@field get__SliderCtrl fun(self: app.GUI020006PartsSlider): ace.cGUIInputCtrl
---@field callbackOther fun(self: app.GUI020006PartsSlider, button: ace.GUIDef.BUTTON_SLOT, ctrl: via.gui.Control?, item: via.gui.SelectItem?, index: System.UInt32)
---@field SLOT_LEFT ace.GUIDef.BUTTON_SLOT

---@class app.GUIAccessIconControl : via.clr.ManagedObject
---@field get_AccessIconInfos fun(self: app.GUIAccessIconControl) : System.Array<app.GUI020001PanelParams>
---@field get_PlayerPosition fun(self: app.GUIAccessIconControl): via.vec3

---@class app.GUI020001PanelParams : via.clr.ManagedObject
---@field get_ObjectCategory fun(self: app.GUI020001PanelParams): app.GUIAccessIconControl.OBJECT_CATEGORY
---@field getCurrentNpcType fun(self: app.GUI020001PanelParams): app.GUI020001PanelParams.NPC_TYPE
---@field getCurrentGossipType fun(self: app.GUI020001PanelParams): app.GUI020001PanelParams.GOSSIP_TYPE
---@field getCurrentPanelType fun(self: app.GUI020001PanelParams): app.GUI020001PanelParams.PANEL_TYPE
---@field get_GameObject fun(self: app.GUI020001PanelParams): via.GameObject
---@field clear fun(self: app.GUI020001PanelParams)
---@field get_MyOwner fun(self: app.GUI020001PanelParams): app.GUI020001

---@class app.PorterCharacter : app.CharacterBase
---@field get_Context fun(self: app.PorterCharacter): app.cPorterContext
---@field get_IsRiding fun(self: app.PorterCharacter): System.Boolean
---@field _MeshFadeController app.cMeshFadeController

---@class app.cMeshFadeController : via.clr.ManagedObject
---@field set_DefaultSpeed fun(self: app.cMeshFadeController, t: System.Single)

---@class app.cPorterManageInfo : via.clr.ManagedObject
---@field get_Character fun(self: app.cPorterManageInfo): app.PorterCharacter
---@field get_ContextHolder fun(self: app.cPorterManageInfo): app.cPorterContextHolder

---@class app.cPorterContextHolder : app.cGameContextHolder
---@field get_Pt fun(self: app.cPorterContextHolder): app.cPorterContext

---@class app.cPorterContext : app.cGameContext
---@field get_PtContinueFlag fun(self: app.cPorterContext): ace.cSafeContinueFlagGroup
---@field get_RideOwner fun(self: app.cPorterContext): app.HunterCharacter
---@field get_CommandInfo fun(self: app.cPorterContext): app.cPorterCommandInfo

---@class app.PorterManager : ace.GAElement
---@field getMasterPlayerPorter fun(self: app.PorterManager)
---@field get_InstancedPorterList fun(self: app.PorterManager): System.Array<app.cPorterManageControl>

---@class app.cPorterManageControl : via.clr.ManagedObject
---@field get_PorterInfo fun(self: app.cPorterManageControl): app.cPorterManageInfo

---@class app.NpcCharacterCore : app.AppBehavior
---@field _Components app.NpcCharacterCore.COMPONENTS
---@field _ContextHolder app.cNpcContextHolder

---@class app.NpcCharacterCore.COMPONENTS : System.ValueType
---@field InteractCtrl app.InteractController

---@class app.InteractController : via.Behavior
---@field get_IsTouch fun(self: app.InteractController): System.Boolean

---@class app.NpcManager : ace.GAElement
---@field findNpcInfo_NpcId fun(self: app.NpcManager, npc_id: app.NpcDef.ID): app.cNpcManageInfo

---@class app.cNpcManageInfo : via.clr.ManagedObject
---@field get_NpcCore fun(self: app.cNpcManageInfo): app.NpcCharacterCore

---@class app.GUI020016PartsBase : app.cGUIPartsBaseApp
---@field get_Type fun(self: app.GUI020016PartsBase): app.cGUIMemberPartsDef.MemberType

---@class app.GUI020007 : app.GUIHudBase
---@field SLOT_UP ace.GUIDef.BUTTON_SLOT
---@field SLOT_DOWN ace.GUIDef.BUTTON_SLOT
---@field callbackOther fun(self: app.GUI020007, button: ace.GUIDef.BUTTON_SLOT, ctrl: via.gui.Control?, sel: via.gui.SelectItem?, idx: System.UInt32)
---@field set__OpenTimer fun(self: app.GUI020007, time: System.Single)
---@field get__SliderStatus fun(self: app.GUI020007): app.GUI020007.BulletSliderStatus
---@field set__SliderStatus fun(self: app.GUI020007, status: app.GUI020007.BulletSliderStatus)
---@field get_IsInput fun(self: app.GUI020007): System.Boolean
---@field get__PanelBulletSlider fun(self: app.GUI020007): via.gui.Panel
---@field setBulletSliderState fun(self: app.GUI020007, play_state: System.String)
---@field get_IsRapidMode fun(self: app.GUI020007): System.Boolean
---@field get__OpenTimer fun(self: app.GUI020007): System.Single

---@class app.cPorterCommandInfo : via.clr.ManagedObject
---@field isExecuted fun(self: app.cPorterCommandInfo, command: app.PorterDef.COMMUNICATOR_COMMAND): System.Boolean

---@class app.GUIMapBeaconManager : ace.GAElement
---@field PaintBallController app.cGUIPaintBallController
---@field get_EmBossBeaconContainer fun(self: app.GUIMapBeaconManager): app.cGUIEMBossBeaconContainer
---@field get_EmZakoBeaconContainer fun(self: app.GUIMapBeaconManager): app.cGUIEMZakoBeaconContainer

---@class app.cGUIPaintBallController : via.clr.ManagedObject
---@field getPaintBallBeaconListAll fun(self: app.cGUIPaintBallController): System.Array<app.cGUIBeaconBase>

---@class app.cGUIEMBossBeaconContainer : app.cGUIBeaconContainerBase
---@field _BeaconListSafe ace.DYNAMIC_ARRAY<app.cGUIBeaconEM>
---@field _BeaconList ace.DYNAMIC_ARRAY<app.cGUIBeaconEM>

---@class app.cGUIEMZakoBeaconContainer : app.cGUIBeaconContainerBase
---@field _BeaconListSafe System.Array<app.cGUIBeaconEM>
---@field _BeaconList ace.DYNAMIC_ARRAY<app.cGUIBeaconEM>

---@class app.cEnemyContext : app.cGameContext
---@field get_ContinueFlag fun(self: app.cEnemyContext): ace.cSafeContinueFlagGroup
---@field get_IsBoss fun(self: app.cEnemyContext): System.Boolean
---@field get_Browser fun(self: app.cEnemyContext): app.cEnemyBrowser
---@field get_IsZako fun(self: app.cEnemyContext): System.Boolean
---@field get_IsAnimal fun(self: app.cEnemyContext): System.Boolean
---@field PaintHitInfoIndex System.Array<app.cEnemyContext.EmPaintHit>

---@class app.cGUIBeaconEM : app.cGUIBeaconBase
---@field getGameContext fun(self: app.cGUIBeaconEM): app.cEnemyContext
---@field get_ContextHolder fun(self: app.cGUIBeaconEM): app.cEnemyContextHolder

---@class app.cGUIBeaconBase : via.clr.ManagedObject
---@field getGameContext fun(self: app.cGUIBeaconBase): app.cGameContext

---@class app.cEnemyContextHolder : app.cGameContextHolder
---@field get_Em fun(self: app.cEnemyContextHolder): app.cEnemyContext
---@field get_Handle fun(self: app.cEnemyContextHolder): app.CONTEXT_HANDLE

---@class app.GUI020201 : app.GUIBaseApp
---@field _StampPanels System.Array<via.gui.Panel>
---@field _CurType app.GUI020201.TYPE
---@field onOpen fun(self: app.GUI020201)

---@class app.GUIFlowQuestResult.cContext : app.cGUIFlowContextBaseApp
---@field getMode fun(self: app.GUIFlowQuestResult.cContext): app.cGUIQuestResultInfo.MODE
---@field set_SkipReward fun(self: app.GUIFlowQuestResult.cContext, val: System.Boolean)
---@field get_IsJudge fun(self: app.GUIFlowQuestResult.cContext): System.Boolean

---@class app.GUIFlowQuestResult.Flow.SeamlessResultList : app.cGUIFlowBaseApp
---@field endFlow fun(self: app.GUIFlowQuestResult.Flow.SeamlessResultList)

---@class app.GUIFlowQuestResult.Flow.FixResultList : app.cGUIFlowBaseApp
---@field endFlow fun(self: app.GUIFlowQuestResult.Flow.FixResultList)

---@class app.cGUI060000Recommend : app.cGUIPartsBaseApp
---@field _RecommendSignParts System.Array<app.cGUI060000Recommend.cRecommendNoticeSign>

---@class app.cGUI060000Recommend.cRecommendNoticeSign : via.clr.ManagedObject
---@field IsActive System.Boolean

---@class app.GUI020400 : app.GUIBaseApp
---@field _SubtitlesCategory app.GUI020400.SUBTITLES_CATEGORY
---@field _ButtonPanel via.gui.Panel

---@class app.DialogueManager : ace.DialogueManagerBase
---@field get_SubtitleManager fun(self: app.DialogueManager): app.cDialogueSubtitleManager

---@class app.cDialogueSubtitleManager : via.clr.ManagedObject
---@field _SubtitlesGUI app.GUI020400
---@field _ChoiceGUI app.GUI020401

---@class app.GUIGaugeHudBase : app.GUIHudBase
---@field _GaugeAmount ace.cGUIParamFloat

---@class ace.cGUIParamFloat : ace.cGUIParameterBase
---@field setValue fun(self: ace.cGUIParamFloat, val: System.Single)
---@field getValue fun(self: ace.cGUIParamFloat): System.Single

---@class app.GUI020004 : app.GUIGaugeHudBase
---@field _CurrentGaugeAmountValue System.Single

---@class app.GUI020014 : app.GUIHudBase
---@field get__PNL_ControlGuide00 fun(self: app.GUI020014): via.gui.Panel

---@class app.cEnemyBrowser : ace.cNonCycleTypeObject
---@field get_EmContext fun(self: app.cEnemyBrowser): app.cEnemyContext
---@field get_IsBoss fun(self: app.cEnemyBrowser): System.Boolean
---@field _Character app.EnemyCharacter

---@class app.EnemyCharacter : app.CharacterBase
---@field _Context app.cEnemyContextHolder

---@class app.cGUI060000OutFrameTarget : app.cGUIPartsBaseApp
---@field _OutFrameIcons System.Array<app.cGUI060000OutFrameTarget.cMapOutFrameIcon>

---@class app.cGUI060000OutFrameTarget.cMapOutFrameIcon : via.clr.ManagedObject
---@field get_TargetBeacon fun(self: app.cGUI060000OutFrameTarget.cMapOutFrameIcon): app.cGUIBeaconBase
---@field setVisible fun(self: app.cGUI060000OutFrameTarget.cMapOutFrameIcon, val: System.Boolean)

---@class app.cEnemyContext.EmPaintHit : System.ValueType
---@field enable System.Boolean

---@class app.EnemyManager : ace.GAElement
---@field _EnemyList app.cManagedArray<app.cEnemyManageInfo>

---@class app.cManagedArray<T> : via.clr.ManagedObject
---@field get_Array fun(self: app.cManagedArray): System.Array<any>

---@class app.cEnemyManageInfo : ace.cNonCycleTypeObject
---@field get_Browser fun(self: app.cEnemyManageInfo): app.cEnemyBrowser
---@field get_Pos fun(self: app.cEnemyManageInfo): Vector3f

---@class app.GUI060010 : app.GUIHudBase
---@field get_IsActive fun(self: app.GUI060010): System.Boolean

---@class app.GUI020020 : app.GUIBaseApp
---@field _DamageInfo System.Array<app.GUI020020.DAMAGE_INFO>
---@field _DamageInfoList System.Array<app.GUI020020.DAMAGE_INFO>

---@class app.GUI600100 : app.GUIBaseApp
---@field _TransitionGuide via.gui.Panel

---@class app.GUI020000 : app.GUIHudBase
---@field get__SetMainAmmoType fun(self: app.GUI020000): app.HunterDef.SLINGER_AMMO_TYPE
---@field _SlingerPanel via.gui.Panel

---@class app.GUI020202 : app.GUIBaseApp
---@field _SkipPanel via.gui.Panel
---@field _Input ace.cGUIInputCtrl

---@class app.GUI020001PanelBase : ace.cGUIPartsBase
---@field get_Params fun(self: app.GUI020001PanelBase): app.GUI020001PanelParams
---@field get_BasePanel fun(self: app.GUI020001PanelBase): via.gui.Panel

---@class app.ChatDef.EnemyMessage : app.ChatDef.SystemMessage
---@field get_EnemyLogType fun(self: app.ChatDef.EnemyMessage): app.ChatDef.ENEMY_LOG_TYPE

---@class app.ChatDef.CampMessage : app.ChatDef.SystemMessage
---@field get_CampLogType fun(self: app.ChatDef.CampMessage): app.ChatDef.CAMP_LOG_TYPE

---@class app.ChatDef.MessageElement : via.clr.ManagedObject
---@field get_MsgType fun(self: app.ChatDef.MessageElement): app.ChatDef.MSG_TYPE
---@field get_ChatLogId fun(self: app.ChatDef.MessageElement): app.ChatDef.LOG_ID

---@class app.NpcCharacter : app.CharacterBase
---@field _ContextHolder app.cNpcContextHolder

---@class app.mcGimmick : ace.mcGimmickBase
---@field get_OwnerGimmick fun(self: app.mcGimmick): app.GimmickBaseApp

---@class app.CharacterBase : app.AppBehavior
---@field get_Pos fun(self: app.CharacterBase): Vector3f

---@class app.GUI020016PartsPlayer : app.GUI020016PartsBase
---@field _PlayerManageInfo app.cPlayerManageInfo
---@field _NpcManageInfo app.cNpcManageInfo

---@class app.GUI020016PartsSeikret : app.GUI020016PartsBase
---@field _PorterManageInfo app.cPorterManageInfo

---@class app.GUI020016PartsOtomo : app.GUI020016PartsBase
---@field _OtomoManageInfo app.cOtomoManageInfo

---@class app.cOtomoManageInfo : via.clr.ManagedObject
---@field get_Character fun(self: app.cOtomoManageInfo): app.OtomoCharacter

---@class app.GUI020015 : app.GUIHudBase
---@field setGaugeModeStatus fun(self: app.GUI020015, status: app.GUI020015.DEFAULT_STATUS)

---@class app.cEnemyLoopEffectHighlight : app.cEnemyEntrustMultipleLoopEffectState
---@field _IsAim System.Boolean

---@class app.TARGET_ACCESS_KEY : System.ValueType
---@field Category app.TARGET_ACCESS_KEY.CATEGORY

---@class app.GuideInsectManager : ace.GAElement
---@field getMasterEntityNavigationController fun(self: app.GuideInsectManager): app.mcGuideInsectNavigationController

---@class app.mcGuideInsectNavigationController : ace.minicomponent.cOrderedActionBase
---@field get_Context fun(self: app.mcGuideInsectNavigationController): app.cGuideInsectContext

---@class app.cGuideInsectContext : app.cGameContext
---@field TargetInfo app.cGuideInsectContext.cTargetInfo

---@class app.cGuideInsectContext.cTargetInfo : via.clr.ManagedObject
---@field get_CurrentNavigationTargetInfoGuideInsect fun(self: app.cGuideInsectContext.cTargetInfo): app.cGuideInsectContext.cTargetInfo.cNavigationTargetInfoGuideInsect

---@class app.cNavigationTargetInfo : via.clr.ManagedObject
---@field getTargetAccessKey fun(self: app.cNavigationTargetInfo): app.TARGET_ACCESS_KEY

---@class app.GUI060002 : app.GUIBaseApp
---@field get_IconController fun(self: app.GUI060002) : app.cGUI3DMapIconModelContoller

---@class app.cGUI3DMapIconModelContoller : app.cGUI3DMapModelContollerBase
---@field _LineCtrl app.cGUILineModelController

---@class app.cGUILineModelController : via.clr.ManagedObject
---@field _Handlers System.Array<app.cGUILineModelController.cGUILineModelHandler>

---@class app.cGUILineModelController.cGUILineModelHandler : via.clr.ManagedObject
---@field clearAll fun(self: app.cGUILineModelController.cGUILineModelHandler)

---@class app.GUI020021 : app.GUIBaseApp
---@field get__Main fun(self: app.GUI020021): via.gui.Panel

---@class app.GUI000005 : app.GUIBaseApp
---@field get_HelpPanel fun(self: app.GUI000005): via.gui.Panel

---@class app.GUI000008 : app.GUIBaseApp
---@field get_Control fun(self: app.GUI000008): via.gui.Panel

---@class app.cGUI020100PanelBase : ace.cGUIPartsBase
---@field get_Log fun(self: app.cGUI020100PanelBase): app.ChatDef.MessageElement
---@field get_LogPanelBase fun(self: app.cGUI020100PanelBase): app.cGUIChatLogPanelBase
---@field get_BasePanel fun(self: app.cGUI020100PanelBase): via.gui.Control
---@field get_IsFix fun(self: app.cGUI020100PanelBase): System.Boolean
---@field get__Timer fun(self: app.cGUI020100PanelBase): System.Single

---@class app.cGUIChatLogPanelBase : via.clr.ManagedObject
---@field get_BasePanel fun(self: app.cGUIChatLogPanelBase): via.gui.Control

---@class app.OtomoCharacter : app.CharacterBase
---@field onOtomoContinueFlag fun(self: app.OtomoCharacter, flag: app.OtomoDef.CONTINUE_FLAG)
---@field get_OwnerHunterCharacter fun(self: app.OtomoCharacter): app.HunterCharacter

---@class app.ContextManager : ace.GAElement
---@field requestRemoveContext_Enemy fun(self: app.ContextManager, handle: app.CONTEXT_HANDLE)

---@class app.GUI020100 : app.GUIHudBase
---@field get__LogPanels  fun(self: app.GUI020100): System.Array<app.cGUI020100PanelBase>

---@class app.user_data.ItemData.cData : ace.user_data.ExcelUserData.cData
---@field get_RawName fun(self: app.user_data.ItemData.cData): System.Guid

---@class app.cReceiveItemInfo : via.clr.ManagedObject
---@field set_Num fun(self: app.cReceiveItemInfo, num: System.Int16)
---@field set_ItemId fun(self: app.cReceiveItemInfo, item_id: app.ItemDef.ID)
-- bool is something accessory related, on quick glance it does not seem to do anything
---@field judge fun(self: app.cReceiveItemInfo, unknown: System.Boolean): System.Boolean
---@field isValid fun(self: app.cReceiveItemInfo): System.Boolean
-- bool is something accessory related, on quick glance it does not seem to do anything
---@field receive fun(self: app.cReceiveItemInfo, unknown: System.Boolean)

---@class app.FacilityManager : ace.GAElement
---@field get_Bowling fun(self: app.FacilityManager): app.FacilityBowling

---@class app.FacilityBowling : app.FacilityBase
---@field getRewardItems fun(self: app.FacilityBowling, rank: app.BowlingDef.RANK): System.Array<app.savedata.cItemWork>

---@class app.GameMiniEventManager : ace.GAElement
---@field get_Bowling fun(self: app.GameMiniEventManager): app.cBowlingUpdater

---@class app.cBowlingUpdater : via.clr.ManagedObject
---@field get_TotalScoreRank fun(self): app.BowlingDef.RANK

---@class app.cBowlingUpdater.cUpdater_ResultEnd : app.cBowlingUpdater.UpdaterBase
---@field _isEnd System.Boolean

---@class app.GUI020600 : app.GUIHudBase
---@field _IsOpen System.Boolean
---@field _Frames System.Array<System.Array<app.GUI020600PartsFrame>>

---@class app.cGUIPartsShortcutFrameBase : ace.cGUIPartsBase
---@field get__ShortcutItem fun(self: app.cGUIPartsShortcutFrameBase): app.cGUIShortcutItem

---@class app.cGUIShortcutItem : via.clr.ManagedObject
---@field get__BasePanel fun(self: app.cGUIShortcutItem): via.gui.Control

---@class app.cGUIMapFlowCtrl : via.clr.ManagedObject
---@field get_Flags fun(self: app.cGUIMapFlowCtrl): System.Collections.BitArray

---@class app.user_data.ChatLogData.cData : ace.user_data.ExcelUserData.cData
---@field get_Title fun(self: app.user_data.ChatLogData.cData): System.Guid
---@field get_Caption fun(self: app.user_data.ChatLogData.cData): System.Guid

---@class app.GUI020002 : app.GUIHudBase
---@field _AimParts app.GUI020002_AimParts

---@class app.GUI020002_AimParts : app.GUI020002_PartsBase
---@field _AimPartsPanelList System.Array<via.gui.Panel>

---@class app.GUI020401 : app.GUIBaseApp
---@field _GroupPanel via.gui.Panel

---@class app.GUI060001 : app.GUIBaseApp
---@field _PanelAll via.gui.Control

---@class app.GUI020101 : app.GUIBaseApp
---@field _PNL_Newmessage via.gui.Panel

---@class app.cGUIFlowBaseApp : ace.cGUIFlowBase
---@field get_Context fun(self: app.cGUIFlowBaseApp): app.GUIFlowQuestResult.cContext

---@class app.cGUISystemModuleQuestResult : ace.cGUISystemModuleBase
---@field get_QuestResult fun(self: app.cGUISystemModuleQuestResult): app.cGUIQuestResultInfo

---@class app.cGUIQuestResultInfo : via.clr.ManagedObject
---@field get_JudgeItems fun(self: app.cGUIQuestResultInfo): app.cGUIRewardItems

---@class app.cGUIRewardItems : via.clr.ManagedObject
---@field get_ItemInfoList fun(self: app.cGUIRewardItems): System.Array<app.cSendItemInfo>

---@class app.cSendItemInfo : app.cReceiveItemInfo
-- bool1 = true, bool2 = false when receiving appraisal items
---@field getReward fun(self: app.cSendItemInfo, bool1: System.Boolean, bool2: System.Boolean)

---@class app.DialogueDef.DialogueVoiceParam : via.clr.ManagedObject
---@field TalkType app.DialogueType.TYPE
