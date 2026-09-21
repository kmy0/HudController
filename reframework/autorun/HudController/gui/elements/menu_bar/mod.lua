local config = require("HudController.config.init")
local fade_manager = require("HudController.hud.fade.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local hud = require("HudController.hud.init")
local option = require("HudController.data.option.init")
local mod_def = option.mod
local user_option = require("HudController.hud.user.option")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_table = require("HudController.util.misc.table")

local this = {}

local function draw_mod_menu()
    imgui.push_style_var(14, Vector2f.new(0, 2))

    if option.draw_menu(mod_def.opt.enabled) then
        hud.reset_elements()
    end

    if option.draw_menu(mod_def.opt.enable_fade) then
        fade_manager.abort()
    end

    option.draw_menu(mod_def.opt.enable_notification)
    option.draw_menu(mod_def.opt.enable_condition_binds)
    option.draw_menu(mod_def.opt.enable_key_binds)
    option.draw_menu(mod_def.opt.display_active_element_profile_name)

    imgui.separator()
    util_imgui.adjust_pos(0, -1)

    option.draw_menu(mod_def.opt.disable_condition_binds_timed)
    util_imgui.tooltip(config.lang:tr("menu.config.disable_condition_binds_timed_tooltip"))

    util_imgui.begin_disabled(
        not config:get(option.get_config_key(mod_def.opt.disable_condition_binds_timed))
    )
    imgui.set_next_item_width(-1)
    option.draw(mod_def.opt.disable_condition_binds_time, { label = false })
    util_imgui.end_disabled()

    util_imgui.adjust_pos(0, -3)
    option.draw_menu(mod_def.opt.disable_condition_binds_held)
    util_imgui.tooltip(config.lang:tr("menu.config.disable_condition_binds_held_tooltip"))

    if not util_table.empty(user_option.mod) then
        imgui.separator()
        generic.draw_user_options(user_option.mod, "mod.user_options")
    end

    imgui.pop_style_var(1)
end

function this.draw()
    util_menubar.draw_menu(util_gui.tr("menu.config.name"), draw_mod_menu, nil, nil, -3)
end

return this
