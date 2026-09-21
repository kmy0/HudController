---@class DamageNumbersDamageStateBoxDef : ElementOptionDef<DamageNumbersDamageState, DamageNumbersDamageStateConfig, EnabledBox>

local config = require("HudController.config.init")
local option_gui = require("HudController.gui.option")
local set = require("HudController.gui.set")
local util_game = require("HudController.util.game.init")
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type DamageNumbersDamageStateBoxDef
        box = {
            key = "box",
            lang_key = "hud_element.entry.box_enable_box",
            bindable = false,
            draw = function(_, label, config_key)
                local enabled_key = config_key .. ".enabled"
                local changed = set:checkbox(label, enabled_key)

                util_imgui.tooltip(config.lang:tr("hud_element.entry.tooltip_numbers_box"), true)
                util_imgui.begin_disabled(not config:get(enabled_key))
                imgui.same_line()
                local item_config_key = string.format("__temp.%s.%s", config_key, "preview_box")
                if
                    imgui.button(util_opt.tr("hud_element.entry.box_preview_box", item_config_key))
                then
                    config:set(item_config_key, not config:get(item_config_key))
                end

                if config:get(enabled_key) and config:get(item_config_key) then
                    local ss = util_game.get_screen_size()
                    ss.x = ss.x / 1920
                    ss.y = ss.y / 1080
                    local x = config:get(config_key .. ".x")
                    local y = config:get(config_key .. ".y")
                    local w = config:get(config_key .. ".w")
                    local h = config:get(config_key .. ".h")

                    draw.outline_quad(
                        y * ss.x,
                        y * ss.y,
                        x * ss.x,
                        (y + h) * ss.y,
                        (x + w) * ss.x,
                        (y + h) * ss.y,
                        (x + w) * ss.x,
                        y * ss.y,
                        4294967295
                    )
                end

                changed = option_gui.draw_slider_settings(nil, {
                    { config_key = config_key .. ".x" },
                    { config_key = config_key .. ".y" },
                }, 1, -1920, 1920, 1, "%.0f", config.lang:tr(
                    "hud_element.entry.pos"
                )) or changed
                changed = option_gui.draw_slider_settings(nil, {
                    { config_key = config_key .. ".w" },
                    { config_key = config_key .. ".h" },
                }, 1, -1920, 1920, 1, "%.0f", config.lang:tr(
                    "hud_element.entry.size"
                )) or changed
                util_imgui.end_disabled()
                return changed
            end,
            format = function(_, value)
                if not value.enabled then
                    return config.lang:tr("misc.text_disabled")
                end
                return string.format("x=%d, y=%d, w=%d, h=%d", value.x, value.y, value.w, value.h)
            end,
            apply = function(_, ctx, value)
                ctx.elem:set_box(value)
            end,
        },
    },
}

return this
