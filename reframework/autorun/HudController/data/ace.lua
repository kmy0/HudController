---@class (exact) AceData
---@field map AceMap

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
---@field log_id_to_text table<app.ChatDef.LOG_ID, string>
---@field auto_id_to_text table<app.Communication.AUTO_ID, string>
---@field weapon_binds {
--- additional_weapon: string[],
--- game_mode: string[],
--- pl_state: string[],
--- }
---@field map_icon_filter_name_guid_to_index table<string, integer>

---@class (exact) AceOptionItem
---@field name_local string
---@field id integer

---@class (exact) AceOption
---@field name_local string
---@field id app.Option.ID
---@field items AceOptionItem[]

---@class AceData
local this = {
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
            "CHAT_LOG",
            "QUEST_END_TIMER",
            "BUTTON_PRESS",
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
            CHAT_LOG = "UI020101",
            QUEST_END_TIMER = "UI020202",
            BUTTON_PRESS = "UI020026",
            -- GUI120200 some notification thing?
            -- GUI090902 barrels rewards
        },
        hudless_to_hud = {
            UI020002 = "UI020000", -- focus reticle to slinger reticle
        },
        no_lang_key = { ALL = true },
        guiid_ignore = {
            UI090901 = true, -- barrels score
            UI020902 = true,
        },
        log_id_to_text = {},
        map_icon_filter_name_guid_to_index = {
            ["a4bc964b-b3e8-4701-8bac-f693dde2321a"] = 0,
            ["9ed781c6-9349-44b5-816c-fee02980792f"] = 1,
            ["816f3ad4-d696-445a-b088-6a5461fd0842"] = 2,
            ["a5539fcf-e6f6-47ae-89d8-ce840ee1b7a1"] = 3,
            ["e79aa493-b68d-45fe-8d5e-6ff90f26cb27"] = 4,
            ["401ea0fa-2c9e-4617-9dc8-227d847ec67a"] = 5,
            ["c15bd652-ea60-4614-a026-a3298013719a"] = 6,
            ["79ca0978-1697-44ef-918f-b5e5e513a2e5"] = 7,
        },
        auto_id_to_text = {},
    },
}

return this
