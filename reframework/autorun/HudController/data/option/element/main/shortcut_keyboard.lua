---@class ShortcutKeyboardBooleanDef : ElementOptionDef<ShortcutKeyboard, ShortcutKeyboardConfig, boolean>

local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type ShortcutKeyboardBooleanDef
        no_hide_elements = {
            key = "no_hide_elements",
            lang_key = "hud_element.entry.box_no_hide_elements",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_no_hide_elements(value)
            end,
        },
        ---@type ShortcutKeyboardBooleanDef
        always_visible = {
            key = "always_visible",
            lang_key = "hud_element.entry.box_always_visible",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_always_visible(value)
            end,
        },
    },
}

return this
