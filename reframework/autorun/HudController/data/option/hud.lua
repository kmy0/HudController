local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local factory = require("HudController.hud.factory")
local mod = require("HudController.data.mod")
local util_gui = require("HudController.gui.util")
local util_opt = require("HudController.data.option.util")
local util_table = require("HudController.util.misc.table")

local CONFIG_KEY_FORMAT = "mod.hud.int:%s.%s"

---@param key string
---@param hud_index integer
---@return string
local function make_config_key_from_key(key, hud_index)
    return CONFIG_KEY_FORMAT:format(hud_index, key)
end

---@param key string
---@return fun(self: OptionDef, hud_index: integer): string
local function make_config_key(key)
    return function(_, hud_index)
        return make_config_key_from_key(key, hud_index)
    end
end

---@generic T
---@param self OptionDef<T>
---@param value T
---@diagnostic disable-next-line: unused-local
local function fade_format(self, value)
    return value == 0 and config.lang:tr("misc.text_disabled")
        or util_gui.seconds_to_minutes_string(value, "%.1f")
end

---@class HudOptionDefinitions
local this = {
    opt = {
        ---@type OptionDef<boolean>
        mute_gui = {
            lang_key = "hud.box_mute_gui",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        disable_area_intro = {
            lang_key = "hud.box_disable_area_intro",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        hide_danger = {
            lang_key = "hud.box_hide_danger",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        hide_aggro = {
            lang_key = "hud.box_hide_aggro",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        disable_scoutflies = {
            lang_key = "hud.box_disable_scoutflies",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        hide_weapon = {
            lang_key = "hud.box_hide_weapon",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        hide_handler = {
            lang_key = "hud.box_hide_handler",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<integer>
        hide_handler_timeout = {
            lang_key = "hud.drag_hide_handler",
            bindable = true,
            draw = util_opt.drag_int(0.1, 0, 30),
            format = util_opt.format_seconds_short,
        },
        ---@type OptionDef<boolean>
        hide_pet = {
            lang_key = "hud.box_hide_pet",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        hide_small_monsters = {
            lang_key = "hud.box_hide_small_monsters",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        monster_ignore_camp = {
            lang_key = "hud.box_monster_ignore_camp",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        disable_quest_intro = {
            lang_key = "hud.box_disable_quest_intro",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        disable_quest_end_camera = {
            lang_key = "hud.box_disable_quest_end_camera",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        disable_quest_end_outro = {
            lang_key = "hud.box_disable_quest_end_outro",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        skip_quest_result = {
            lang_key = "hud.box_skip_quest_result",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        disable_porter_call = {
            lang_key = "hud.box_disable_porter_call",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        hide_porter = {
            lang_key = "hud.box_hide_porter",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<integer>
        hide_porter_timeout = {
            lang_key = "hud.drag_hide_porter",
            bindable = true,
            draw = util_opt.drag_int(0.1, 0, 30),
            format = util_opt.format_seconds_short,
        },
        ---@type OptionDef<boolean>
        disable_porter_tracking = {
            lang_key = "hud.box_disable_porter_tracking",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            active = util_opt.active_checkbox,
        },
        ---@type OptionDef<boolean>
        show_notification = {
            lang_key = "hud.box_show_notification",
            bindable = false,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<integer>
        hide_npc = {
            lang_key = "hud.slider_hide_npc",
            bindable = true,
            combo = cd.combo.hide_npc,
            draw = util_opt.slider_list,
            format = util_opt.format_combo,
            active = function(_, value)
                return value ~= mod.enum.hide_npc.DISABLED
            end,
        },
        ---@type OptionDef<integer>
        monster_wound = {
            lang_key = "hud.slider_em_scar",
            bindable = true,
            combo = cd.combo.em_scar,
            draw = util_opt.slider_list,
            format = util_opt.format_combo,
            active = function(_, value)
                return value ~= mod.enum.em_scar.DISABLED
            end,
        },
        ---@type OptionDef<integer>
        monster_icon = {
            lang_key = "hud.slider_em_icon",
            bindable = true,
            combo = cd.combo.em_icon,
            draw = util_opt.slider_list,
            format = util_opt.format_combo,
            active = function(_, value)
                return value ~= mod.enum.em_icon.DISABLED
            end,
        },
        ---@type OptionDef<boolean>
        fade_opacity = {
            lang_key = "hud.box_fade_opacity",
            bindable = false,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
        },
        ---@type OptionDef<number>
        fade_in = {
            lang_key = "hud.slider_fade_in",
            bindable = false,
            draw = util_opt.slider_float(0, 10),
            format = fade_format,
        },
        ---@type OptionDef<number>
        fade_out = {
            lang_key = "hud.slider_fade_out",
            bindable = false,
            draw = util_opt.slider_float(0, 10),
            format = fade_format,
        },
    },
}

---@generic T
---@param opt OptionDef<T>
---@return T
function this.get_default(opt)
    local default = factory.get_hud_profile_config(0, "")
    return util_table.deep_copy(default[opt.key])
end

---@param key string
---@param hud_index integer
---@return string
function this.make_config_key_from_key(key, hud_index)
    return make_config_key_from_key(key, hud_index)
end

for key, opt in pairs(this.opt) do
    opt.key = key
    opt.config_key = make_config_key(key)
end

return this
