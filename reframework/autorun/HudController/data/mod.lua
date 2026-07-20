---@class ModData
---@field map ModMap
---@field enum ModEnum
---@field pause boolean
---@field initialized boolean
---@field is_reset boolean
---@field is_title_request boolean

---@class (exact) ModMap
---@field options_hud table<string, string>
---@field options_mod table<string, string>
---@field slider_grid_ratio string[]
---@field slider_expanded_itembar_control string[]
---@field slider_sharpness_state string[]
---@field combo_item_decide table<string, {value: string, sort: integer}>
---@field combo_map_filter_init table<string, integer>
---@field combo_map_filter table<string, integer>

---@class (exact) ModEnum
---@field hud_type HudType.*
---@field hud_sub_type HudSubType.*
---@field colors GuiColors.*

local ace = require("HudController.data.ace")
local ace_misc = require("HudController.util.ace.misc")
local s = require("HudController.util.ref.singletons")
local util_table = require("HudController.util.misc.table")

---@class ModData
local this = {
    ---@diagnostic disable-next-line: missing-fields
    enum = {},
    map = {
        options_hud = {
            mute_gui = "box_mute_gui",
            hide_subtitles = "box_hide_subtitles",
            disable_scoutflies = "box_disable_scoutflies",
            disable_porter_call = "box_disable_porter_call",
            hide_porter = "box_hide_porter",
            hide_handler = "box_hide_handler",
            hide_danger = "box_hide_danger",
            disable_area_intro = "box_disable_area_intro",
            disable_quest_intro = "box_disable_quest_intro",
            disable_quest_end_camera = "box_disable_quest_end_camera",
            hide_monster_icon = "box_hide_monster_icon",
            disable_quest_end_outro = "box_disable_quest_end_outro",
            skip_quest_end_timer = "box_skip_quest_end_timer",
            hide_lock_target = "box_hide_lock_target",
            hide_quest_end_timer = "box_hide_quest_end_timer",
            hide_no_talk_npc = "box_hide_no_talk_npc",
            hide_no_facility_npc = "box_hide_no_facility_npc",
            monster_ignore_camp = "box_monster_ignore_camp",
            hide_small_monsters = "box_hide_small_monsters",
            disable_scar = "box_disable_scar",
            skip_quest_result = "box_skip_quest_result",
            hide_scar = "box_hide_scar",
            show_scar = "box_show_scar",
            disable_porter_tracking = "box_disable_porter_tracking",
            hide_weapon = "box_hide_weapon",
            hide_pet = "box_hide_pet",
            mute_gossip = "box_mute_gossip",
            hide_aggro = "box_hide_aggro",
        },
        options_mod = {
            enable_fade = "enable_fade",
            enable_notification = "enable_notification",
            enable_key_binds = "enable_key_binds",
            disable_condition_binds_timed = "disable_condition_binds_timed",
            disable_condition_binds_held = "disable_condition_binds_held",
            enable_condition_binds = "enable_condition_binds",
        },
        slider_grid_ratio = {
            "1",
            "2",
            "4",
            "8",
            "16",
        },
        slider_expanded_itembar_control = {
            "expanded_itembar_disable_dpad",
            "expanded_itembar_disable_face",
        },
        slider_sharpness_state = {
            "small",
            "big",
        },
        combo_item_decide = {
            ["option_disable"] = { value = "option_disable", sort = -1 },
            ["LIST_TRIGGER_L_UP"] = { value = "L_UP", sort = 0 },
            ["LIST_TRIGGER_L_DOWN"] = { value = "L_DOWN", sort = 1 },
            ["LIST_TRIGGER_L_LEFT"] = { value = "L_LEFT", sort = 2 },
            ["LIST_TRIGGER_L_RIGHT"] = { value = "L_RIGHT", sort = 3 },
            ["LIST_TRIGGER_L1"] = { value = "L1", sort = 4 },
            ["LIST_TRIGGER_L2"] = { value = "L2", sort = 5 },
            ["OPEN_MYSET"] = { value = "L3", sort = 6 },
            ["OPEN_DEPARTURE_WINDOW_TRIGGER"] = { value = "C_LEFT", sort = 7 },
            ["MAP3D_CLOSE"] = { value = "C_CENTER", sort = 8 },
            ["CLOSE_ALL_MENU"] = { value = "C_RIGHT", sort = 9 },
            ["MAP3D_LOCK_TARGET"] = { value = "R3", sort = 10 },
            ["LIST_TRIGGER_R2"] = { value = "R2", sort = 11 },
            ["LIST_TRIGGER_R1"] = { value = "R1", sort = 12 },
            ["LIST_TRIGGER_RRIGHT"] = { value = "R_RIGHT", sort = 13 },
            ["LIST_TRIGGER_RLEFT"] = { value = "R_LEFT", sort = 14 },
            ["LIST_TRIGGER_RDOWN"] = { value = "R_DOWN", sort = 15 },
            ["LIST_TRIGGER_RUP"] = { value = "R_UP", sort = 16 },
        },
        combo_map_filter_init = util_table.merge_t(
            util_table.deep_copy(ace.map.map_icon_filter_name_guid_to_index),
            { option_disable = -1 }
        ),
        combo_map_filter = {},
    },
    initialized = false,
    is_reset = false,
    pause = false,
    is_title_request = false,
}
---@enum HudType
this.enum.hud_type = { ---@class HudType.*
    BASE = 1,
    HEALTH = 2,
    WEAPON = 3,
    MINIMAP = 5,
    ITEMBAR = 6,
    PROGRESS = 7,
    TARGET = 8,
    AMMO = 9,
    RADIAL = 10,
    CONTROL = 11,
    SHARPNESS = 12,
    COMPANION = 13,
    STAMINA = 14,
    CLOCK = 15,
    SLINGER = 16,
    NOTICE = 17,
    NAME_ACCESS = 18,
    NAME_OTHER = 19,
    SLINGER_RETICLE = 20,
    GUN_RETICLE = 21,
    BOW_RETICLE = 22,
    SUBTITLES = 23,
    SUBTITLES_CHOICE = 24,
    DAMAGE_NUMBERS = 25,
    ROD_RETICLE = 26,
    TRAINING_ROOM_HUD = 27,
    MENU_BUTTON_GUIDE = 28,
    TARGET_RETICLE = 29,
    SHORTCUT_KEYBOARD = 30,
    BARREL_BOWLING_SCORE = 31,
    CHAT_LOG = 32,
    QUEST_END_TIMER = 33,
}
---@enum HudSubType
this.enum.hud_sub_type = { ---@class HudSubType.*
    BASE = 1,
    MATERIAL = 2,
    SCALE9 = 3,
    TEXT = 4,
    DAMAGE_NUMBERS = 5,
    CTRL_CHILD = 6,
    PROGRESS_TEXT = 7,
    PROGRESS_PART = 8,
}
---@enum GuiColors
this.enum.colors = { ---@class GuiColors.*
    bad = 0xff1947ff,
    good = 0xff47ff59,
    info = 0xff27f3f5,
}

---@return boolean
function this.is_ok()
    this.is_title_request = ace_misc.is_title_request()

    if
        not this.initialized
        or not s.get("app.GUIManager")
        or not ace_misc.get_hud_manager()
        or this.is_title_request
    then
        return false
    end

    return ace_misc.get_hud_manager()._DisplayControls:get_Count() > 0
end

---@return boolean
function this.init()
    this.initialized = true
    return true
end

return this
