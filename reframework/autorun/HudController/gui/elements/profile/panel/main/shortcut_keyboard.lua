local config = require("HudController.config.init")
local def = require("HudController.data.option.element.main.shortcut_keyboard")
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")

---@param elem ShortcutKeyboard
---@param elem_config ShortcutKeyboardConfig
---@param config_key string
return function(elem, elem_config, config_key)
    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }
    util_imgui.separator_text(
        config.lang:tr("hud_element.entry.category_shortcut_keyboard_behavior")
    )
    util_opt.draw_apply_elem(def.opt.no_hide_elements, ctx)
    util_imgui.tooltip(
        config.lang:tr("hud_element.entry.tooltip_keyboard_shortcut_only_one_row"),
        true
    )
    util_opt.draw_apply_elem(def.opt.always_visible, ctx)
    util_imgui.tooltip(
        config.lang:tr("hud_element.entry.tooltip_keyboard_shortcut_only_one_row"),
        true
    )
end
