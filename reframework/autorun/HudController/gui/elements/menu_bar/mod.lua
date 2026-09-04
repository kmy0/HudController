local config = require("HudController.config.init")
local fade_manager = require("HudController.hud.fade.init")
local hud = require("HudController.hud.init")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")

local set = state.set

local this = {}

local function draw_mod_menu()
    local config_mod = config.current.mod
    imgui.push_style_var(14, Vector2f.new(0, 2))

    if set:menu_item(util_gui.tr("menu.config.enabled"), "mod.enabled") then
        hud.reset_elements()
    end

    if set:menu_item(util_gui.tr("menu.config.enable_fade"), "mod.enable_fade") then
        fade_manager.abort()
    end

    set:menu_item(util_gui.tr("menu.config.enable_notification"), "mod.enable_notification")
    set:menu_item(util_gui.tr("menu.config.enable_condition_binds"), "mod.enable_condition_binds")
    set:menu_item(util_gui.tr("menu.config.enable_key_binds"), "mod.enable_key_binds")

    imgui.separator()

    set:menu_item(
        util_gui.tr("menu.config.disable_condition_binds_timed"),
        "mod.disable_condition_binds_timed"
    )
    util_imgui.tooltip(config.lang:tr("menu.config.disable_condition_binds_timed_tooltip"))

    imgui.begin_disabled(not config_mod.disable_condition_binds_timed)
    imgui.indent(2)
    local item_config_key = "mod.disable_condition_binds_time"
    local item_value = config:get(item_config_key)
    set:slider_int(
        "##" .. item_config_key,
        item_config_key,
        1,
        300,
        util_gui.seconds_to_minutes_string(item_value, "%.0f")
    )

    imgui.end_disabled()
    imgui.unindent(2)

    set:menu_item(
        util_gui.tr("menu.config.disable_condition_binds_held"),
        "mod.disable_condition_binds_held"
    )
    util_imgui.tooltip(config.lang:tr("menu.config.disable_condition_binds_held_tooltip"))

    imgui.pop_style_var(1)
end

function this.draw()
    util_menubar.draw_menu(util_gui.tr("menu.config.name"), draw_mod_menu)
end

return this
