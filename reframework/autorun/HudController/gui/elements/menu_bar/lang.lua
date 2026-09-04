local config = require("HudController.config.init")
local gui_util = require("HudController.gui.util")
local state = require("HudController.gui.state")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")

local set = state.set
local this = {}

local function draw_lang_menu()
    local config_lang = config.current.mod.lang
    imgui.push_style_var(14, Vector2f.new(0, 2))

    for i = 1, #config.lang.sorted do
        local menu_item = config.lang.sorted[i]
        if
            util_imgui.menu_item(menu_item, config_lang.file == menu_item)
            and config_lang.file ~= menu_item
        then
            config_lang.file = menu_item
            config.lang:change()
            state.translate_combo()
            config:save()
        end
    end

    imgui.separator()

    set:menu_item(gui_util.tr("menu.language.fallback"), "mod.lang.fallback")
    util_imgui.tooltip(config.lang:tr("menu.language.fallback_tooltip"))

    imgui.indent(2)
    util_menubar.draw_menu(gui_util.tr("menu.language.font_size.name"), function()
        imgui.spacing()

        if set:slider_int("##font_size_slider", "mod.lang.font_size", 8, 48) then
            config_lang.font_size = math.min(math.max(config_lang.font_size, 8), 48)
        end

        imgui.same_line()

        if imgui.button(gui_util.tr("menu.language.font_size.button_apply")) then
            config.lang:change(nil, config_lang.font_size)
        end

        imgui.spacing()
    end)
    imgui.unindent(2)

    imgui.pop_style_var(1)
end

function this.draw()
    util_menubar.draw_menu(gui_util.tr("menu.language.name"), draw_lang_menu)
end

return this
