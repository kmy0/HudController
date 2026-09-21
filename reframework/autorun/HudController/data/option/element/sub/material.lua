---@class MaterialMaterialVarFloatDef : ElementOptionDef<Material, MaterialConfig, EnabledMaterialVarFloat>

local util_opt = require("HudController.data.option.util")

local draw_var = util_opt.enabled_slider(0.01, 0, 5, 0.01, "%.2f")

local this = {
    opt = {
        ---@type MaterialMaterialVarFloatDef
        var0 = {
            key = "var0",
            lang_key = "hud_element.entry.var",
            bindable = true,
            format = util_opt.format_enabled_number("%.2f"),
            draw = draw_var,
            apply = function(_, ctx, value)
                ctx.elem:set_var(value)
            end,
        },
        ---@type MaterialMaterialVarFloatDef
        var1 = {
            key = "var1",
            lang_key = "hud_element.entry.var",
            bindable = true,
            format = util_opt.format_enabled_number("%.2f"),
            draw = draw_var,
            apply = function(_, ctx, value)
                ctx.elem:set_var(value)
            end,
        },
        ---@type MaterialMaterialVarFloatDef
        var2 = {
            key = "var2",
            lang_key = "hud_element.entry.var",
            bindable = true,
            format = util_opt.format_enabled_number("%.2f"),
            draw = draw_var,
            apply = function(_, ctx, value)
                ctx.elem:set_var(value)
            end,
        },
        ---@type MaterialMaterialVarFloatDef
        var3 = {
            key = "var3",
            lang_key = "hud_element.entry.var",
            bindable = true,
            format = util_opt.format_enabled_number("%.2f"),
            draw = draw_var,
            apply = function(_, ctx, value)
                ctx.elem:set_var(value)
            end,
        },
        ---@type MaterialMaterialVarFloatDef
        var4 = {
            key = "var4",
            lang_key = "hud_element.entry.var",
            bindable = true,
            format = util_opt.format_enabled_number("%.2f"),
            draw = draw_var,
            apply = function(_, ctx, value)
                ctx.elem:set_var(value)
            end,
        },
    },
}

return this
