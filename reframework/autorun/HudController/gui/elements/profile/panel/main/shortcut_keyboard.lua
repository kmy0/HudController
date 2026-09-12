local config = require("HudController.config.init")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")

local set = state.set

---@param elem ShortcutKeyboard
---@param elem_config ShortcutKeyboardConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(
        config.lang:tr("hud_element.entry.category_shortcut_keyboard_behavior")
    )
    local item_config_key = config_key .. ".no_hide_elements"
    local is_current_profile = operations.is_current_profile(elem)
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_no_hide_elements", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem:set_no_hide_elements(elem_config.no_hide_elements)
    end
    util_imgui.tooltip(
        config.lang:tr("hud_element.entry.tooltip_keyboard_shortcut_only_one_row"),
        true
    )

    item_config_key = config_key .. ".always_visible"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_always_visible", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem:set_always_visible(elem_config.always_visible)
    end
    util_imgui.tooltip(
        config.lang:tr("hud_element.entry.tooltip_keyboard_shortcut_only_one_row"),
        true
    )
end
