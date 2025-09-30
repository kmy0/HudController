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
---@field enemy_continue_flag table<app.EnemyDef.CONTINUE_FLAG, string>
---@field damage_state table<app.GUI020020.State, string>
---@field critical_state table<app.GUI020020.CRITICAL_STATE, string>
---@field slinger_ammo table<app.HunterDef.SLINGER_AMMO_TYPE, string>
---@field page_alignment table<via.gui.PageAlignment, string>
---@field enemy_log table<app.ChatDef.ENEMY_LOG_TYPE, string>
---@field camp_log table<app.ChatDef.CAMP_LOG_TYPE, string>
---@field chat_log table<app.ChatDef.MSG_TYPE, string>
---@field interact_npc_type table<app.GUI020001PanelParams.NPC_TYPE, string>
---@field interact_gossip_type table<app.GUI020001PanelParams.GOSSIP_TYPE, string>
---@field interact_panel_type table<app.GUI020001PanelParams.PANEL_TYPE, string>
---@field scar_state table<app.cEmModuleScar.cScarParts.STATE, string>
---@field sharpness_state table<app.GUI020015.DEFAULT_STATUS, string>
---@field target_access table<app.TARGET_ACCESS_KEY.CATEGORY, string>
---@field otomo_continue_flag table<app.OtomoDef.CONTINUE_FLAG, string>
---@field map_flow_flag table<app.cGUIMapFlowCtrl.FLAG, string>

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
---@field hudless_to_hud table<string, string>
---@field guiid_ignore table<string, boolean>
---@field wp_action_to_index table<string, {category: integer, index: integer}>
---@field key_to_wp_action_name table<string, string>
---@field weapon_binds {
--- additional_weapon: string[],
--- game_mode: string[],
--- pl_state: string[],
--- }

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
        enemy_continue_flag = {},
        damage_state = {},
        critical_state = {},
        slinger_ammo = {},
        page_alignment = {},
        enemy_log = {},
        camp_log = {},
        chat_log = {},
        interact_gossip_type = {},
        interact_npc_type = {},
        interact_panel_type = {},
        scar_state = {},
        sharpness_state = {},
        target_access = {},
        otomo_continue_flag = {},
        map_flow_flag = {},
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
            "DAMAGE_NUMBERS",
            "PREPARE_WINDOW",
            "ROD_RETICLE",
            "TRAINING_ROOM_HUD",
            "ACTION_TUTORIAL",
            "TARGET_RETICLE",
            "MENU_BUTTON_GUIDE",
            "BARREL_BOWLING_SCORE",
            "TU3_DEBUFF",
            "TU3_CANVAS",
        },
        weapon_binds = {
            additional_weapon = { "RANGED", "MELEE", "GLOBAL" },
            game_mode = { "singleplayer", "multiplayer" },
            pl_state = { "combat_in", "combat_out", "camp" },
        },
        additional_hud_to_guiid_name = {
            SLINGER_RETICLE = "UI020000",
            GUN_RETICLE = "UI020019",
            BOW_RETICLE = "UI020031",
            SUBTITLES = "UI020400",
            SUBTITLES_CHOICE = "UI020401",
            DAMAGE_NUMBERS = "UI020020",
            PREPARE_WINDOW = "UI020800",
            ROD_RETICLE = "UI020028",
            TRAINING_ROOM_HUD = "UI600100",
            ACTION_TUTORIAL = "UI600000",
            TARGET_RETICLE = "UI020021",
            MENU_BUTTON_GUIDE = "UI000008",
            BARREL_BOWLING_SCORE = "UI090901",
            TU3_DEBUFF = "UI020901",
            TU3_CANVAS = "UI020902",
            -- GUI020026 qte?
            -- GUI120200 some notification thing?
            -- GUI090902 barrels rewards
        },
        hudless_to_hud = {
            UI020002 = "UI020000", -- focus reticle to slinger reticle
        },
        no_lang_key = { ALL = true },
        guiid_ignore = {
            UI090901 = true, -- barrels score
        },
        wp_action_to_index = {},
        key_to_wp_action_name = {},
    },
}

return this
