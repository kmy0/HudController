local config = require("HudController.config.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_game = require("HudController.util.game.init")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")

local set = state.set

---@param elem DamageNumbersDamageState
---@param elem_config DamageNumbersDamageStateConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_numbers_behavior"))

    local item_config_key = config_key .. ".enabled_box"
    local changed = false
    local is_current_profile = operations.is_current_profile(elem)

    item_config_key = config_key .. ".enabled_box"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_enable_box", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem:set_box(elem_config.enabled_box and {
            x = elem_config.box.x,
            y = elem_config.box.y,
            w = elem_config.box.w,
            h = elem_config.box.h,
        } or nil)
    end
    util_imgui.tooltip(config.lang:tr("hud_element.entry.tooltip_numbers_box"), true)

    util_imgui.begin_disabled(not elem_config.enabled_box)
    imgui.same_line()

    item_config_key = config_key .. ".preview_box"
    if config:get(item_config_key) == nil then
        config:set(item_config_key, false)
    end

    if imgui.button(util_gui.tr("hud_element.entry.box_preview_box", item_config_key)) then
        config:set(item_config_key, not config:get(item_config_key))
    end

    if elem_config.enabled_box and config:get(item_config_key) and is_current_profile then
        local ss = util_game.get_screen_size()
        ss.x = ss.x / 1920
        ss.y = ss.y / 1080

        draw.outline_quad(
            elem_config.box.x * ss.x,
            elem_config.box.y * ss.y,
            elem_config.box.x * ss.x,
            (elem_config.box.y + elem_config.box.h) * ss.y,
            (elem_config.box.x + elem_config.box.w) * ss.x,
            (elem_config.box.y + elem_config.box.h) * ss.y,
            (elem_config.box.x + elem_config.box.w) * ss.x,
            elem_config.box.y * ss.y,
            4294967295
        )
    end

    changed = generic.draw_slider_settings(nil, {
        {
            config_key = config_key .. ".box.x",
        },
        {
            config_key = config_key .. ".box.y",
        },
    }, 1, -1920, 1920, 1, "%.0f", config.lang:tr("hud_element.entry.pos"))
    changed = generic.draw_slider_settings(nil, {
        {
            config_key = config_key .. ".box.w",
        },
        {
            config_key = config_key .. ".box.h",
        },
    }, 1, -1920, 1920, 1, "%.0f", config.lang:tr("hud_element.entry.size")) or changed

    if changed and is_current_profile then
        elem:set_box({
            x = elem_config.box.x,
            y = elem_config.box.y,
            w = elem_config.box.w,
            h = elem_config.box.h,
        })
    end

    util_imgui.end_disabled()
end
