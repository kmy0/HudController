local bind_condition = require("HudController.hud.bind_condition.init")
local config = require("HudController.config.init")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_table = require("HudController.util.misc.table")

local set = state.set

local this = {}

local function draw_condition_option_menu()
    imgui.spacing()
    imgui.indent(2)

    util_imgui.separator_text(config.lang:tr("menu.bind.condition_option.category_general"))
    set:checkbox(
        util_gui.tr("menu.bind.condition_option.box_switchback"),
        "mod.bind.condition.switchback"
    )
    util_imgui.tooltip(config.lang:tr("menu.bind.condition_option.tooltip_switchback"), true)
    set:checkbox(
        util_gui.tr("menu.bind.condition_option.box_highlight_pass"),
        "mod.bind.condition.highlight_pass"
    )

    local conditions = util_table.filter(bind_condition.conditions, function(_, value)
        return value:has_additional_options()
    end)
    local sorted = util_table.sort(util_table.keys(conditions))

    for _, key in ipairs(sorted) do
        local cond = conditions[key]
        util_imgui.separator_text(cond:get_display_name())
        cond:draw_additional_options()
    end

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    util_menubar.draw_menu(
        util_gui.tr("menu.bind.condition_option.name"),
        draw_condition_option_menu
    )
end

return this
