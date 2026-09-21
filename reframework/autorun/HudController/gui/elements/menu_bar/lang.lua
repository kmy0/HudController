local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local option = require("HudController.data.option.init")
local placeholder = require("HudController.data.placeholder")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")

local mod_def = option.mod

local this = {}

local function draw_lang_menu()
    local config_lang = config.current.mod.lang

    for i = 1, #config.lang.sorted do
        local menu_item = config.lang.sorted[i]
        if
            util_imgui.menu_item(menu_item, config_lang.file == menu_item)
            and config_lang.file ~= menu_item
        then
            config_lang.file = menu_item
            config.lang:change()
            cd.translate_combo()
            option.elem.make_tree()
            placeholder.inject_literals()
            config:save()
        end
    end

    --FIXME: some padding from somwhere is fuckin shit up
    util_imgui.adjust_pos(0, -2)
    imgui.separator()
    util_imgui.adjust_pos(0, -3)

    option.draw_menu(mod_def.opt.lang_fallback)
    util_imgui.tooltip(config.lang:tr("menu.language.fallback_tooltip"))

    imgui.indent(2)
    util_menubar.draw_menu(util_gui.tr("menu.language.font_size.name"), function()
        imgui.indent(2)

        imgui.spacing()
        imgui.push_style_var(14, Vector2f.new(0, 0))
        if option.draw(mod_def.opt.lang_font_size, { label = false }) then
            config_lang.font_size = math.min(math.max(config_lang.font_size, 8), 48)
        end

        imgui.push_style_var(14, Vector2f.new(2, 0))
        imgui.same_line()
        if imgui.button(util_gui.tr("menu.language.font_size.button_apply")) then
            config.lang:change(nil, config_lang.font_size)
        end
        imgui.pop_style_var(2)
        imgui.unindent(2)
        imgui.spacing()
        imgui.spacing()
    end)

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    util_menubar.draw_menu(util_gui.tr("menu.language.name"), draw_lang_menu)
end

return this
