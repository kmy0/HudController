local config = require("HudController.config.init")
local gui_util = require("HudController.gui.util")
local state = require("HudController.gui.state")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")

local set = state.set

local this = {}

local function draw_canvas_menu()
    imgui.spacing()
    imgui.indent(2)

    set:checkbox(gui_util.tr("canvas.box_draw"), "mod.canvas.draw")
    set:checkbox(gui_util.tr("canvas.box_display_name"), "mod.canvas.display_name")
    set:checkbox(gui_util.tr("canvas.box_display_value"), "mod.canvas.display_value")
    set:checkbox(gui_util.tr("canvas.box_display_keybinds"), "mod.canvas.keybinds.draw")
    util_imgui.tooltip(config.lang:tr("canvas.tooltip_box_display_keybinds"), true)
    set:checkbox(gui_util.tr("canvas.box_hide_elem_disabled"), "mod.canvas.hide_elem_disabled")
    set:checkbox(
        gui_util.tr("canvas.box_hide_elem_not_present"),
        "mod.canvas.hide_elem_not_present"
    )
    util_imgui.tooltip(config.lang:tr("canvas.tooltip_box_hide_elem_not_present"), true)

    imgui.separator()

    set:color_edit(gui_util.tr("canvas.color_default"), "mod.canvas.color_default")
    set:color_edit(gui_util.tr("canvas.color_hover"), "mod.canvas.color_hover")
    set:color_edit(gui_util.tr("canvas.color_select"), "mod.canvas.color_select")
    set:color_edit(gui_util.tr("canvas.color_outline"), "mod.canvas.color_outline")

    imgui.separator()

    set:slider_int(gui_util.tr("canvas.slider_anchor_radius"), "mod.canvas.anchor.radius", 1, 40)
    set:drag_float2(
        gui_util.tr("canvas.slider_anchor_offset"),
        "mod.canvas.anchor.offset_x",
        "mod.canvas.anchor.offset_y",
        0.5,
        -1920,
        1920
    )

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    util_menubar.draw_menu(gui_util.tr("canvas.name"), draw_canvas_menu)
end

return this
