---@class StaminaExBooleanDef : ElementOptionDef<StaminaEx, StaminaExConfig, boolean>

local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type StaminaExBooleanDef
        hide_pulse = {
            key = "hide_pulse",
            lang_key = "hud_element.entry.box_hide_pulse",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_hide_pulse(value)
            end,
        },
    },
}

return this
