local bind_condition = require("HudController.hud.bind.condition.init")
local config = require("HudController.config.init")
local set = require("HudController.gui.set")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_table = require("HudController.util.misc.table")

local this = {}

local function draw_condition_option_menu()
    imgui.spacing()
    imgui.indent(2)

    util_imgui.separator_text(config.lang:tr("menu.bind.condition_option.category_general"))
    set:checkbox(
        util_gui.tr("menu.bind.condition_option.box_highlight_pass"),
        "mod.bind.condition.highlight_pass"
    )

    local conditions = util_table.filter(bind_condition.conditions, function(_, value)
        return value:has_additional_options()
    end)

    ---@type table<string, table<string, ConditionBase>>
    local categories = {}
    ---@type table<string, ConditionBase>
    local uncategorized = {}

    for key, cond in pairs(conditions) do
        local category = cond:get_options_category()

        if category then
            util_table.set_nested_value(categories, { category, key }, cond)
        else
            uncategorized[key] = cond
        end
    end

    local sorted_categories = util_table.sort(util_table.keys(categories))
    for _, category in ipairs(sorted_categories) do
        util_imgui.separator_text(category)

        local category_conditions = categories[category]
        local sorted = util_table.sort(util_table.keys(category_conditions))

        for _, key in ipairs(sorted) do
            category_conditions[key]:draw_additional_options()
        end
    end

    local sorted = util_table.sort(util_table.keys(uncategorized))
    for _, key in ipairs(sorted) do
        local cond = uncategorized[key]

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
