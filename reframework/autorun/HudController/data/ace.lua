---@class (exact) AceData
---@field enum AceEnum
---@field map AceMap

---@class (exact) AceEnum
---@field hud table<app.GUIHudDef.TYPE, string>
---@field guide_panel table<app.GUI020018.GUIDE_PANEL_TYPE, string>
---@field region_fit table<via.gui.RegionFitType, string>
---@field weapon table<app.WeaponDef.TYPE, string>
---@field option table<app.Option.ID, string>
---@field hud_display table<app.GUIHudDef.DISPLAY, string>
---@field dialog table<app.DialogueType.TYPE, string>
---@field hunter_continue_flag table<app.HunterDef.CONTINUE_FLAG, string>
---@field input_device table<ace.GUIDef.INPUT_DEVICE, string>
---@field gui_func table<app.GUIFunc.TYPE, string>
---@field button_mask table<app.PlayerDef.ButtonMask.USER, string>
---@field kb_btn table<ace.ACE_MKB_KEY.INDEX, string>
---@field system_msg table<app.ChatDef.SYSTEM_MSG_TYPE, string>
---@field send_target table<app.ChatDef.SEND_TARGET, string>
---@field control_point table<via.gui.ControlPoint, string>
---@field blend table<via.gui.BlendType, string>
---@field alpha_channel table<via.gui.AlphaChannelType, string>
---@field stock_type table<app.ItemUtil.STOCK_TYPE, string>
---@field object_access_category table<app.GUIAccessIconControl.OBJECT_CATEGORY, string>
---@field porter_continue_flag table<app.PorterDef.CONTINUE_FLAG, string>
---@field action_update_result table<ace.ActionDef.UPDATE_RESULT, string>
---@field npc_id table<app.NpcDef.ID, string>
---@field npc_continue_flag table<app.NpcDef.CHARA_CONTINUE_FLAG, string>
---@field quest_gui_type table<app.GUI020201.TYPE, string>
---@field nameplate_type table<app.cGUIMemberPartsDef.MemberType, string>
---@field bullet_slider_status table<app.GUI020007.BulletSliderStatus, string>
---@field draw_segment table<table<app.GUIDefApp.DRAW_SEGMENT, string>, string>
---@field quest_result_mode table<app.cGUIQuestResultInfo.MODE, string>
---@field gui_continue_flag table<app.GUIManager.APP_CONTINUE_FLAG, string>
---@field gui_id table<app.GUIID.ID, string>
---@field subtitles_category table<app.GUI020400.SUBTITLES_CATEGORY, string>
---@field icon_move_pattern table<app.cGUIMapEmBossIconDrawUpdater.MOVE_PATTERN, string>

---@class (exact) AceMap
---@field hudid_to_guiid table<app.GUIHudDef.TYPE, app.GUIID.ID[]>
---@field guiid_to_hudid table<app.GUIID.ID, app.GUIHudDef.TYPE>
---@field hudid_name_to_local_name table<string, string>
---@field weaponid_name_to_local_name table<string, string>
---@field option table<string, AceOption>
---@field hudid_to_can_hide table<app.GUIHudDef.TYPE, boolean>
---@field additional_hud string[]
---@field additional_hud_to_guiid_name table<string, string>
---@field hud_tr_flag string
---@field additional_hud_index integer
---@field no_lang_key table<string, boolean>

---@class (exact) AceOptionItem
---@field name_local string
---@field id integer

---@class (exact) AceOption
---@field name_local string
---@field id app.Option.ID
---@field items AceOptionItem[]

---@class AceData
local this = {
    enum = {
        hud = {},
        guide_panel = {},
        region_fit = {},
        weapon = {},
        option = {},
        hud_display = {},
        dialog = {},
        hunter_continue_flag = {},
        input_device = {},
        gui_func = {},
        button_mask = {},
        kb_btn = {},
        system_msg = {},
        send_target = {},
        control_point = {},
        blend = {},
        alpha_channel = {},
        stock_type = {},
        object_access_category = {},
        porter_continue_flag = {},
        action_update_result = {},
        npc_id = {},
        npc_continue_flag = {},
        quest_gui_type = {},
        nameplate_type = {},
        bullet_slider_status = {},
        draw_segment = {},
        quest_result_mode = {},
        gui_continue_flag = {},
        gui_id = {},
        subtitles_category = {},
        icon_move_pattern = {},
    },
    map = {
        hudid_to_guiid = {},
        hudid_to_can_hide = {},
        guiid_to_hudid = {},
        hudid_name_to_local_name = {},
        weaponid_name_to_local_name = {},
        option = {},
        hud_tr_flag = "NEED_TR",
        additional_hud_index = 1000,
        additional_hud = {
            "SLINGER_RETICLE",
            "GUN_RETICLE",
            "BOW_RETICLE",
            "SUBTITLES",
            "SUBTITLES_CHOICE",
        },
        additional_hud_to_guiid_name = {
            SLINGER_RETICLE = "UI020000",
            GUN_RETICLE = "UI020019",
            BOW_RETICLE = "UI020031",
            SUBTITLES = "UI020400",
            SUBTITLES_CHOICE = "UI020401",
        },
        no_lang_key = {},
    },
}

return this
