local config = require("HudController.config.init")
local option = require("HudController.data.option.init")
local set = require("HudController.gui.set")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")

local mod_def = option.mod

local this = {}

local function draw_canvas_menu()
    imgui.spacing()
    imgui.indent(2)

    option.draw(mod_def.opt.canvas_draw)
    option.draw(mod_def.opt.canvas_display_name)
    option.draw(mod_def.opt.canvas_display_value)
    option.draw(mod_def.opt.canvas_display_keybinds)
    util_imgui.tooltip(config.lang:tr("canvas.tooltip_box_display_keybinds"), true)
    option.draw(mod_def.opt.canvas_hide_elem_disabled)
    option.draw(mod_def.opt.canvas_hide_elem_not_present)
    util_imgui.tooltip(config.lang:tr("canvas.tooltip_box_hide_elem_not_present"), true)

    imgui.separator()

    option.draw(mod_def.opt.canvas_color_default)
    option.draw(mod_def.opt.canvas_color_hover)
    option.draw(mod_def.opt.canvas_color_select)
    option.draw(mod_def.opt.canvas_color_outline)

    imgui.separator()

    option.draw(mod_def.opt.canvas_anchor_radius)
    set:drag_float2(
        util_gui.tr("canvas.slider_anchor_offset"),
        option.get_config_key(mod_def.opt.canvas_anchor_offset_x),
        option.get_config_key(mod_def.opt.canvas_anchor_offset_y),
        0.5,
        -1920,
        1920
    )

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    util_menubar.draw_menu(util_gui.tr("canvas.name"), draw_canvas_menu)
end

return this
