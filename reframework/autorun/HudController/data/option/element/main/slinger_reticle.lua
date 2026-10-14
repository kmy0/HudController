---@class SlingerReticleSlingerBooleanDef : ElementOptionDef<SlingerReticleSlinger, SlingerReticleSlingerConfig, boolean>

local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type SlingerReticleSlingerBooleanDef
        hide_slinger_empty = {
            key = "hide_slinger_empty",
            lang_key = "hud_element.entry.box_hide_slinger_empty",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_hide_slinger_empty(value)
            end,
        },
    },
}

return this
