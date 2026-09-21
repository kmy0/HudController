---@class ProgressPartTextBooleanDef : ElementOptionDef<ProgressPartText, ProgressPartTextConfig, boolean>

local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type ProgressPartTextBooleanDef
        align_left = {
            key = "align_left",
            lang_key = "hud_element.entry.box_align_left",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_align_left(value)
            end,
        },
    },
}

return this
