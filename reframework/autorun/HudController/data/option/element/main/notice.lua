---@class NoticeBooleanDef : ElementOptionDef<Notice, NoticeConfig, boolean>

local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type NoticeBooleanDef
        cache_msg = {
            key = "cache_msg",
            lang_key = "hud_element.entry.box_cache_messages",
            bindable = false,
            format = util_opt.format_checkbox,
            draw = util_opt.checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_cache_msg(value)
            end,
        },
    },
}

return this
