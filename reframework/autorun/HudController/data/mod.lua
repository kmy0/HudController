---@class ModData
---@field map ModMap

---@class (exact) ModMap
---@field hud_options string[]

local ace_misc = require("HudController.util.ace.misc")
local s = require("HudController.util.ref.singletons")

---@class ModData
local this = {
    enum = {},
    map = {
        hud_options = {
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
        },
    },
    initialized = false,
}
---@enum HudType
this.enum.hud_type = {
    BASE = 1,
    HEALTH = 2,
    WEAPON = 3,
    VITAL = 4,
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
}
---@enum HudSubType
this.enum.hud_sub_type = {
    BASE = 1,
    MATERIAL = 2,
    SCALE9 = 3,
    TEXT = 4,
    DAMAGE_NUMBERS = 5,
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
