local config = require("HudController.config.init")
local def = require("HudController.data.option.element.main.itembar").opt
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")

---@param elem Itembar
---@param elem_config ItembarConfig
---@param config_key string
return function(elem, elem_config, config_key)
    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }
    local slider_ctx = util_opt.resolve_elem_ctx(ctx, "children.slider") --[[@as  ElementOptionContext<ItembarSlider, ItembarSliderConfig>]]
    local mantle_ctx = util_opt.resolve_elem_ctx(ctx, "children.mantle") --[[@as  ElementOptionContext<ItembarMantle, ItembarMantleConfig>]]
    local all_slider_ctx = util_opt.resolve_elem_ctx(ctx, "children.all_slider") --[[@as  ElementOptionContext<ItembarAllSlider, ItembarAllSliderConfig>]]

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_itembar_behavior"))
    util_opt.draw_apply_elem(def.slider_appear_open, slider_ctx)
    util_opt.draw_apply_elem(def.slider_move_next, slider_ctx)
    util_imgui.tooltip(config.lang:tr("hud_element.entry.tooltip_itembar_move_next"), true)
    util_opt.draw_apply_elem(def.start_expanded, ctx)

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_mantle_behavior"))
    util_opt.draw_apply_elem(def.mantle_always_visible, mantle_ctx)
    util_opt.draw_apply_elem(def.mantle_timer_visible, mantle_ctx)

    util_imgui.separator_text(
        config.lang:tr("hud_element.entry.category_expanded_itembar_behavior")
    )
    util_opt.draw_apply_elem(def.all_slider_appear_open, all_slider_ctx)
    util_opt.draw_apply_elem(def.all_slider_ammo_visible, all_slider_ctx)
    util_opt.draw_apply_elem(def.all_slider_slinger_visible, all_slider_ctx)
    util_opt.draw_apply_elem(def.all_slider_disable_right_stick, all_slider_ctx)
    util_opt.draw_apply_elem(def.all_slider_enable_mouse_control, all_slider_ctx)
    util_opt.draw_apply_elem(def.all_slider_control, all_slider_ctx)
    util_opt.draw_apply_elem(def.all_slider_decide_key, all_slider_ctx)
end
