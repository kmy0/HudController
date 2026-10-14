local bind_manager = require("HudController.hud.bind.key.init")
local config = require("HudController.config.init")
local option = require("HudController.data.option.init")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")

local mod_def = option.mod

local this = {}

local function draw_key_option_menu()
    imgui.spacing()
    imgui.indent(2)

    if option.draw(mod_def.opt.key_buffer) then
        bind_manager.monitor:set_max_buffer_frame(
            config:get(option.get_config_key(mod_def.opt.key_buffer))
        )
    end

    util_imgui.tooltip(config.lang:tr("menu.bind.key.tooltip_buffer"))

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    util_menubar.draw_menu(util_gui.tr("menu.bind.key_option.name"), draw_key_option_menu)
end

return this
