---@class SubtitlesBooleanDef : ElementOptionDef<Subtitles, SubtitlesConfig, boolean>
---@class SubtitlesIntegerDef : ElementOptionDef<Subtitles, SubtitlesConfig, integer>

local config = require("HudController.config.init")
local set = require("HudController.gui.set")
local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type SubtitlesBooleanDef
        cache_subtitles = {
            key = "cache_subtitles",
            lang_key = "hud_element.entry.box_cache_subtitles",
            bindable = false,
            format = util_opt.format_checkbox,
            draw = util_opt.checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_cache_subtitles(value)
            end,
        },
        ---@type SubtitlesBooleanDef
        cache_sfx = {
            key = "cache_sfx",
            lang_key = "hud_element.entry.box_cache_sfx",
            bindable = false,
            format = util_opt.format_checkbox,
            draw = util_opt.checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_cache_sfx(value)
            end,
        },
        ---@type SubtitlesIntegerDef
        cache_sfx_cooldown = {
            key = "cache_sfx_cooldown",
            lang_key = "hud_element.entry.drag_sfx_cooldown",
            bindable = false,
            format = util_opt.format_value,
            draw = function(_, label, key)
                return set:drag_int(util_opt.get_label(label, key), key, 0.1, 0, 120)
            end,
            apply = function(_, ctx, value)
                config:set(ctx.config_key, value)
            end,
        },
    },
}

return this
