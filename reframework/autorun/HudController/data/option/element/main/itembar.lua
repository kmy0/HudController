---@class ItembarBooleanDef : ElementOptionDef<Itembar, ItembarConfig, boolean>
---@class ItembarIntegerDef : ElementOptionDef<Itembar, ItembarConfig, integer>
---@class ItembarStringDef : ElementOptionDef<Itembar, ItembarConfig, string>
---@class ItembarSliderBooleanDef : ElementOptionDef<ItembarSlider, ItembarSliderConfig, boolean>
---@class ItembarMantleBooleanDef : ElementOptionDef<ItembarMantle, ItembarMantleConfig, boolean>
---@class ItembarAllSliderBooleanDef : ElementOptionDef<ItembarAllSlider, ItembarAllSliderConfig, boolean>
---@class ItembarAllSliderExpandedItembarControlDef : ElementOptionDef<ItembarAllSlider, ItembarAllSliderConfig, ExpandedItembarControl>
---@class ItembarAllSliderStringDef : ElementOptionDef<ItembarAllSlider, ItembarAllSliderConfig, string>

local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local option_gui = require("HudController.gui.option")
local set = require("HudController.gui.set")
local util_opt = require("HudController.data.option.util")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

local this = {
    opt = {
        ---@type ItembarSliderBooleanDef
        slider_appear_open = {
            key = "appear_open",
            lang_key = "hud_element.entry.box_appear_open",
            bindable = true,
            format = util_opt.format_checkbox,
            draw = util_opt.checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_appear_open(value)
            end,
        },
        ---@type ItembarSliderBooleanDef
        slider_move_next = {
            key = "move_next",
            lang_key = "hud_element.entry.box_move_next",
            bindable = true,
            format = util_opt.format_checkbox,
            draw = util_opt.checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_move_next(value)
            end,
        },
        ---@type ItembarBooleanDef
        start_expanded = {
            key = "start_expanded",
            lang_key = "hud_element.entry.box_start_expanded",
            bindable = true,
            format = util_opt.format_checkbox,
            draw = util_opt.checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_start_expanded(value)
            end,
        },
        ---@type ItembarMantleBooleanDef
        mantle_always_visible = {
            key = "always_visible",
            lang_key = "hud_element.entry.box_always_visible",
            bindable = true,
            format = util_opt.format_checkbox,
            draw = util_opt.checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_always_visible(value)
            end,
        },
        ---@type ItembarMantleBooleanDef
        mantle_timer_visible = {
            key = "timer_visible",
            lang_key = "hud_element.entry.box_timer_visible",
            bindable = true,
            format = util_opt.format_checkbox,
            draw = util_opt.checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_timer_visible(value)
            end,
        },
        ---@type ItembarAllSliderBooleanDef
        all_slider_appear_open = {
            key = "appear_open",
            lang_key = "hud_element.entry.box_appear_open",
            bindable = true,
            format = util_opt.format_checkbox,
            draw = util_opt.checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_appear_open(value)
            end,
        },
        ---@type ItembarAllSliderBooleanDef
        all_slider_ammo_visible = {
            key = "ammo_visible",
            lang_key = "hud_element.entry.box_itembar_ammo_visible",
            bindable = true,
            format = util_opt.format_checkbox,
            draw = util_opt.checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_ammo_visible(value)
            end,
        },
        ---@type ItembarAllSliderBooleanDef
        all_slider_slinger_visible = {
            key = "slinger_visible",
            lang_key = "hud_element.entry.box_itembar_slinger_visible",
            bindable = true,
            format = util_opt.format_checkbox,
            draw = util_opt.checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_slinger_visible(value)
            end,
        },
        ---@type ItembarAllSliderBooleanDef
        all_slider_disable_right_stick = {
            key = "disable_right_stick",
            lang_key = "hud_element.entry.box_itembar_disable_right_stick",
            bindable = true,
            format = util_opt.format_checkbox,
            draw = util_opt.checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_disable_right_stick(value)
            end,
        },
        ---@type ItembarAllSliderBooleanDef
        all_slider_enable_mouse_control = {
            key = "enable_mouse_control",
            lang_key = "hud_element.entry.box_itembar_enable_mouse_control",
            bindable = true,
            format = util_opt.format_checkbox,
            draw = util_opt.checkbox,
            apply = function(_, ctx, value)
                ctx.elem:set_enable_mouse_control(value)
            end,
        },
        ---@type ItembarAllSliderExpandedItembarControlDef
        all_slider_control = {
            key = "control",
            lang_key = "hud_element.entry.slider_expanded_itembar_control",
            bindable = true,
            draw = function(_, label, config_key)
                local values = util_table.extend(
                    { config.lang:tr("hud.option_disable") },
                    util_table.values(mod.map.slider_expanded_itembar_control, function(o)
                        return config.lang:tr("hud_element.entry." .. o)
                    end)
                )
                return set:slider_list(
                    util_opt.get_label(label, config_key),
                    config_key,
                    -1,
                    #mod.map.slider_expanded_itembar_control - 1,
                    values
                )
            end,
            apply = function(_, ctx, value)
                ctx.elem:set_control(value)
            end,
            format = function(_, value)
                if value == -1 then
                    return config.lang:tr("hud.option_disable")
                end
                local k = mod.map.slider_expanded_itembar_control[value + 1]
                return config.lang:tr("hud_element.entry." .. k)
            end,
        },
        ---@type ItembarAllSliderStringDef
        all_slider_decide_key = {
            key = "decide_key",
            lang_key = "hud_element.entry.combo_expanded_itembar_decide_key",
            bindable = true,
            draw = function(_, label, config_key)
                local changed = option_gui.draw_combo(
                    nil,
                    config_key,
                    util_opt.get_label(label, config_key),
                    cd.combo.item_decide
                )
                if changed then
                    config:set(config_key, changed.key)
                    return true
                end
                return false
            end,
            format = function(_, value)
                ---@diagnostic disable-next-line: param-type-mismatch
                local index = cd.combo.item_decide:get_index(nil, value) --[[@as integer]]
                return cd.combo.item_decide:get_value(index)
            end,
            apply = function(_, ctx, value)
                ctx.elem:set_decide_key(value)
            end,
        },
    },
}

return this
