---@class (exact) HudProfileConfig
---@field name string
---@field key integer
---@field elements table<string, HudBaseConfig>
---@field options table<string, integer>
---@field mute_gui boolean
---@field fade_in number
---@field fade_out number
---@field hide_subtitles boolean
---@field show_notification boolean
---@field fade_opacity boolean
---@field fade_opacity_both boolean
---@field disable_scoutflies boolean
---@field disable_porter_call boolean
---@field hide_porter boolean
---@field hide_handler boolean
---@field hide_danger boolean
---@field disable_area_intro boolean
---@field disable_quest_intro boolean
---@field disable_quest_end_camera boolean
---@field hide_quest_end_timer boolean
---@field skip_quest_end_timer boolean
---@field disable_quest_end_outro boolean
---@field hide_monster_icon boolean
---@field hide_lock_target boolean
---@field hide_no_talk_npc boolean
---@field hide_no_facility_npc boolean
---@field monster_ignore_camp boolean

local data = require("HudController.data")
local hud_elements = require("HudController.hud.elements")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local mod = data.mod

local this = {}

---@param key integer
---@param name string
---@return HudProfileConfig
function this.get_hud_profile_config(key, name)
    return {
        key = key,
        name = name,
        elements = {},
        options = {
            DAMAGE_DISPLAY = -1,
            SKILL_EFFECT = -1,
            TALISMAN_EFFECT = -1,
        },
        mute_gui = false,
        fade_in = 0,
        fade_out = 0,
        hide_subtitles = false,
        show_notification = true,
        fade_opacity = false,
        fade_opacity_both = false,
        disable_scoutflies = false,
        disable_porter_call = false,
        hide_porter = false,
        hide_handler = false,
        hide_danger = false,
        disable_area_intro = false,
        disable_quest_intro = false,
        disable_quest_end_camera = false,
        hide_monster_icon = false,
        hide_lock_target = false,
        disable_quest_end_outro = false,
        skip_quest_end_timer = false,
        hide_quest_end_timer = false,
        hide_no_talk_npc = false,
        hide_no_facility_npc = false,
        monster_ignore_camp = false,
    }
end

---@param hud_id app.GUIHudDef.TYPE
---@return HudBaseConfig
function this.get_config(hud_id)
    local hud_name = ace_enum.hud[hud_id]
    local cls = hud_elements[hud_name]

    if not cls then
        cls = hud_elements[mod.enum.hud_type.BASE]
        return cls.get_config(hud_id, hud_name)
    end

    return cls.get_config()
end

---@param hud_elem HudBaseConfig
---@return HudBaseConfig
function this.merge(hud_elem)
    return util_table.merge2_t(
        { "hud_type", "name_key", "hud_id", "hud_sub_type" },
        true,
        this.get_config(hud_elem.hud_id),
        hud_elem
    )
end

---@param elements table<string, HudBaseConfig>
---@return table<string, HudBaseConfig>
function this.verify_elements(elements)
    for key, elem in pairs(elements) do
        if not elem.hud_id or not elem.hud_type or not elem.name_key or ace_enum.hud[elem.hud_id] ~= elem.name_key then
            elements[key] = nil
        else
            elements[key] = this.merge(elem)
        end
    end

    return elements
end

---@param hud_config HudProfileConfig
---@return HudProfileConfig
function this.verify_hud(hud_config)
    return util_table.merge2_t(nil, false, this.get_hud_profile_config(hud_config.key, hud_config.name), hud_config)
end

---@param hud_elem HudBaseConfig
---@return HudBase
function this.new_elem(hud_elem)
    local cls = hud_elements[hud_elem.hud_type]
    return cls:new(hud_elem)
end

return this
