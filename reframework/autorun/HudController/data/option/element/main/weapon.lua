---@class WeaponBooleanDef : ElementOptionDef<Weapon, WeaponConfig, boolean>

local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type WeaponBooleanDef
        no_focus = {
            key = "no_focus",
            lang_key = "hud_element.entry.box_weapon_no_focus",
            bindable = true,
            draw = util_opt.checkbox,
            format = util_opt.format_checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_no_focus(value)
            end,
        },
    },
}

return this
