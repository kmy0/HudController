local bind_manager = require("HudController.hud.bind.key.init")
local config = require("HudController.config.init")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")

local set = state.set

local this = {}

local function draw_key_option_menu()
    imgui.spacing()
    imgui.indent(2)

    local config_mod = config.current.mod
    local buffer = config_mod.bind.key.buffer - 1
    local display_value = config.lang:tr("misc.text_disabled")
    if buffer == 1 then
        display_value = string.format("%s %s", buffer, config.lang:tr("misc.text_frame"))
    elseif buffer > 1 then
        display_value = string.format("%s %s", buffer, config.lang:tr("misc.text_frame_plural"))
    end

    if
        set:slider_int(
            util_gui.tr("menu.bind.key.slider_buffer"),
            "mod.bind.key.buffer",
            1,
            11,
            display_value
        )
    then
        bind_manager.monitor:set_max_buffer_frame(config_mod.bind.key.buffer)
    end

    util_imgui.tooltip(config.lang:tr("menu.bind.key.tooltip_buffer"))

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    util_menubar.draw_menu(util_gui.tr("menu.bind.key_option.name"), draw_key_option_menu)
end

return this
