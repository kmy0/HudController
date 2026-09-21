---@class (exact) ModProfileConfig
---@field name string
---@field key integer
---@field elements table<string, HudBaseConfig>
---@field options table<string, integer>
---@field mute_gui boolean
---@field fade_in number
---@field fade_out number
---@field show_notification boolean
---@field fade_opacity boolean
---@field disable_scoutflies boolean
---@field disable_porter_call boolean
---@field hide_porter boolean
---@field hide_handler boolean
---@field hide_danger boolean
---@field disable_area_intro boolean
---@field disable_quest_intro boolean
---@field disable_quest_end_camera boolean
---@field disable_quest_end_outro boolean
---@field hide_monster_icon boolean
---@field hide_lock_target boolean
---@field monster_ignore_camp boolean
---@field hide_small_monsters boolean
---@field skip_quest_result boolean
---@field disable_porter_tracking boolean
---@field hide_weapon boolean
---@field hide_pet boolean
---@field hide_aggro boolean
---@field hide_porter_timeout integer
---@field hide_handler_timeout integer
---@field monster_icon EmIcon
---@field monster_wound EmScar
---@field hide_npc HideNpc
---@field profile HudBaseConfigProfileForShow[]
---@field user_options table<string, any>

local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local hud_elements = require("HudController.hud.elements.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.manager.op.init"
local op = util_misc.lazy_require("HudController.hud.manager.op.init")

local mod = data.mod

local this = {}

---@param key integer
---@param name string
---@return ModProfileConfig
function this.get_hud_profile_config(key, name)
    local ret = {
        key = key,
        name = name,
        mute_gui = false,
        disable_area_intro = false,
        hide_danger = false,
        hide_aggro = false,
        disable_scoutflies = false,
        hide_weapon = false,
        hide_handler = false,
        hide_handler_timeout = 5,
        hide_pet = false,
        hide_small_monsters = false,
        monster_ignore_camp = false,
        disable_quest_intro = false,
        disable_quest_end_camera = false,
        disable_quest_end_outro = false,
        skip_quest_result = false,
        disable_porter_call = false,
        hide_porter = false,
        hide_porter_timeout = 3,
        disable_porter_tracking = false,
        show_notification = true,
        hide_npc = mod.enum.hide_npc.DISABLED,
        monster_wound = mod.enum.em_scar.DISABLED,
        monster_icon = mod.enum.em_icon.DISABLED,
        fade_opacity = false,
        fade_in = 0,
        fade_out = 0,
        elements = {},
        options = {},
        profile = {
            { key = 0, name = "__placeholder_default", protected = true },
        },
        user_options = {},
    }
    ---@cast ret ModProfileConfig

    op.user.merge_hud_user_options(ret)
    return ret
end

---@param hud_id app.GUIHudDef.TYPE
---@return HudBaseConfig
function this.get_config(hud_id)
    local hud_name = e.get("app.GUIHudDef.TYPE")[hud_id]
    local cls = hud_elements[hud_name]
    ---@type HudBaseConfig
    local ret
    if not cls then
        cls = hud_elements[mod.enum.hud_type.BASE]
        ret = cls.get_config(hud_id, hud_name)
    else
        ret = cls.get_config()
    end

    op.user.merge_elem_user_options(ret)
    return ret
end

---@param hud_elem HudBaseConfig
---@return HudBaseConfig
function this.merge(hud_elem)
    local protected = { "hud_type", "name_key", "hud_id", "hud_sub_type" }
    local profiles = hud_elem.profile
    hud_elem.profile = nil

    local ret =
        util_table.merge_protected(protected, true, this.get_config(hud_elem.hud_id), hud_elem)

    for key, profile in pairs(profiles or {}) do
        ---@diagnostic disable-next-line: no-unknown
        profile[key] = util_table.merge_protected(
            protected,
            true,
            this.get_config(hud_elem.hud_id) --[[@as HudBaseConfigProfile]],
            profile
        )
    end
    ret.profile = profiles or {}

    return ret
end

---@overload fun(target: HudBaseConfig, source: HudBaseConfig | HudBaseConfigProfile): HudBaseConfig
---@overload fun(target: HudBaseConfigProfile, source: HudBaseConfig | HudBaseConfigProfile): HudBaseConfigProfile
function this.merge_profile(target, source)
    local protected = {
        "hud_type",
        "name_key",
        "hud_id",
        "hud_sub_type",
        "current_profile",
        "current_profile_gui",
        "enabled",
        "profile",
        "profile_key",
        "default_profile",
    }

    return util_table.merge_protected(protected, true, target, source)
end

---@param elements table<string, HudBaseConfig>
---@return table<string, HudBaseConfig>
function this.verify_elements(elements)
    for key, elem in pairs(elements) do
        if
            not elem.hud_id
            or not elem.hud_type
            or not elem.name_key
            or e.get("app.GUIHudDef.TYPE")[elem.hud_id] ~= elem.name_key
        then
            elements[key] = nil
        else
            elements[key] = this.merge(elem)
        end
    end

    return elements
end

---@param hud_config ModProfileConfig
---@return ModProfileConfig
function this.verify_hud(hud_config)
    return util_table.merge_protected(
        nil,
        false,
        this.get_hud_profile_config(hud_config.key, hud_config.name),
        hud_config
    )
end

---@param hud_elem HudBaseConfig
---@return HudBase
function this.new_elem(hud_elem)
    local cls = hud_elements[hud_elem.hud_type]
    return cls:new(hud_elem)
end

return this
