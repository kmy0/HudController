---@class ModData
---@field map ModMap
---@field enum ModEnum
---@field pause boolean
---@field initialized boolean

---@class (exact) ModMap
---@field options_hud table<string, string>
---@field options_mod table<string, string>

---@class (exact) ModEnum
---@field hud_type HudType.*
---@field hud_sub_type HudSubType.*

local ace_misc = require("HudController.util.ace.misc")
local s = require("HudController.util.ref.singletons")

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
            disable_weapon_binds_timed = "disable_weapon_binds_timed",
            disable_weapon_binds_held = "disable_weapon_binds_held",
            enable_weapon_binds = "enable_weapon_binds",
        },
    },
    initialized = false,
    pause = false,
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

---@return boolean
function this.is_ok()
    if not this.initialized or not s.get("app.GUIManager") or not ace_misc.get_hud_manager() then
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
