local bind_condition = require("HudController.hud.bind.condition.init")
local breadcrumbs = require("HudController.gui.elements.menu_bar.bind.condition.breadcrumbs")
local cond_draw = require("HudController.gui.elements.menu_bar.bind.condition.cond_draw")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local managers = require("HudController.gui.elements.menu_bar.bind.condition.managers.init")
local op = require("HudController.hud.manager.op.init")
local tree = require("HudController.gui.elements.menu_bar.bind.condition.tree")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_table = require("HudController.util.misc.table")

local mod_enum = data.mod.enum

local this = {
    ---@type table<BindCondType, GuiCondManagerBase>
    managers = {},
}

---@return number
local function get_width()
    return util_imgui.scale_w_font_size(300) * 3 + 6 * 4 + config.lang.font_size + 6
end

---@param config_key string
---@return boolean
local function any_rules(config_key)
    local sets = config:get(config_key .. ".sets") --[[@as table<BindCondType, ConditionBindRuleSet>]]
    local set = sets[config:get(config_key .. ".cond_type_selection")] --[[@as ConditionBindRuleSet]]
    return set and not util_table.empty(set.rules)
end

local function draw_condition_bind_menu()
    imgui.spacing()
    imgui.indent(2)

    local config_mod = config.current.mod
    local path = config_mod.bind.condition.path

    op.bind.evaluate_conditions(config_mod.bind.condition)

    local new_path = tree.draw(tree.make_tree(path))

    local function check_new_path()
        if new_path then
            path = new_path
            config:set("mod.bind.condition.path", path)
        end
    end

    check_new_path()
    imgui.same_line()
    new_path = breadcrumbs.draw(breadcrumbs.make_breadcrumbs(path))
    check_new_path()

    local has_rules = any_rules(path)
    local buttons, button_width = cond_draw.get_buttons()
    local size_y = util_imgui.scale_w_font_size(300)

    util_imgui.adjust_pos(0, -2)
    if
        imgui.begin_table(
            "bind_cond_main_table",
            has_rules and 3 or 2,
            imgui.TableFlags.BordersInnerV | imgui.TableFlags.Resizable --[[@as ImGuiTableFlags]],
            Vector2f.new(get_width(), size_y)
        )
    then
        imgui.table_setup_column(
            "##buttons",
            imgui.ColumnFlags.WidthFixed | imgui.ColumnFlags.NoResize --[[@as ImGuiTableColumnFlags]],
            button_width
        )
        imgui.table_setup_column("##content", imgui.ColumnFlags.WidthStretch, 0.3)
        if has_rules then
            imgui.table_setup_column("##content2", imgui.ColumnFlags.WidthStretch, 0.7)
        end

        imgui.table_next_row()
        imgui.table_set_column_index(0)
        local type_selection = cond_draw.draw_buttons(buttons, button_width, path)

        if type_selection and has_rules then
            local manager = managers[type_selection]
            local set_path = string.format("%s.sets.%s", path, type_selection)

            imgui.table_set_column_index(1)
            imgui.begin_child_window("##content", Vector2f.new(0, size_y), false)
            local rule_selection = cond_draw.draw_target(manager, set_path)
            imgui.end_child_window()

            if rule_selection then
                local rule_path = string.format("%s.rules.int:%s", set_path, rule_selection)
                imgui.table_set_column_index(2)
                imgui.begin_child_window("##content2", Vector2f.new(0, size_y), false)
                cond_draw.draw_condition_target(manager, rule_path)
                imgui.end_child_window()
            end
        else
            imgui.table_set_column_index(1)
            imgui.push_font(config.lang.font_header)
            util_imgui.text_info(config.lang:tr("menu.bind.condition.text_no_conditions"))
            imgui.pop_font()
        end

        imgui.end_table()
    end

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    util_menubar.draw_menu(
        util_gui.tr("menu.bind.condition.name"),
        draw_condition_bind_menu,
        nil,
        bind_condition.check_invalid() and mod_enum.colors.bad or nil
    )
end

return this
