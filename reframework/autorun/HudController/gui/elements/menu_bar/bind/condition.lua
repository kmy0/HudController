---@class ConditionSetDrawParams
---@field index integer
---@field cond_set ConditionSetConfig
---@field config_key string
---@field dragger Drag
---@field collapse_id string
---@field remove_label string
---@field duplicate_label string
---@field highlight boolean
---@field pass_path any[]
---@field condition_path_fn fun(k: integer): any[]
---@field draw_selector fun()
---@field draw_expanded fun()?

local bind_condition = require("HudController.hud.bind_condition.init")
local config = require("HudController.config.init")
local drag_util = require("HudController.gui.drag")
local mod = require("HudController.data.mod")
local state = require("HudController.gui.state")
local util_bind = require("HudController.gui.elements.menu_bar.bind.util")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_table = require("HudController.util.misc.table")

local set = state.set
local drag = drag_util:new()
local elem_drag = drag_util:new()

local this = {}

local COLOR_PASS = 0xff3eb231
local COLOR_FAIL = 0xff6a6a6a
local COLOR_NONE = 0
local TABLE_FLAGS = 1 << 9
local TABLE_COLUMNS = 3

---@param color integer
---@param rounding integer
local function end_rect_colored(color, rounding)
    imgui.push_style_color(5, color)
    imgui.end_rect(rounding, 0)
    imgui.pop_style_color(1)
end

---@param highlight boolean
---@param path any[]
---@param fallback integer
---@return integer
local function resolve_highlight_color(highlight, path, fallback)
    if highlight and util_table.get_nested_value(bind_condition.passing_sets, path) then
        return COLOR_PASS
    end
    return fallback
end

---@param conditions ConditionConfigBase[]
---@param config_key string
---@return string
local function build_condition_tooltip(conditions, config_key)
    local text = {}
    for k, cond in ipairs(conditions) do
        local cond_class = bind_condition.conditions[cond.class]
        if not cond_class then
            goto continue
        end

        local str = cond_class:get_display_name()

        if cond_class:has_custom_options() then
            str = cond_class:get_selected_option_string()
        elseif cond_class.options then
            local index = config:get(
                string.format("%s.conditions.int:%s.%s", config_key, k, "combo")
            ) or 1
            str = string.format(
                "%s - %s",
                str,
                state.bind_condition_options[cond.class]:get_value(index)
            )
        end

        table.insert(text, str)
        ::continue::
    end

    if util_table.empty(text) then
        return config.lang:tr("misc.text_none")
    end
    return table.concat(text, "\n")
end

---@param combo_key string
---@param combo Combo
local function advance_combo_index(combo_key, combo)
    local index = (config:get(combo_key) or 1) + 1 --[[@as integer]]
    if index > combo:size() then
        index = 1
    end
    config:set(combo_key, index)
end

---@param conditions ConditionConfigBase[]
---@param config_key string
---@param highlight boolean
---@param path_fn fun(k: integer): any[]
---@return integer[]
local function draw_condition_rows(conditions, config_key, highlight, path_fn)
    local cond_remove = {}

    if util_table.empty(conditions) then
        imgui.text(config.lang:tr("menu.bind.condition.text_no_condition"))
    end

    if imgui.begin_table("conditions_" .. config_key, TABLE_COLUMNS, TABLE_FLAGS) then
        for k, cond in ipairs(conditions) do
            local cond_class = bind_condition.conditions[cond.class]
            if not cond_class then
                goto continue
            end

            imgui.table_next_row()
            imgui.table_set_column_index(0)
            imgui.begin_rect()

            if
                imgui.button(
                    util_gui.tr("menu.bind.condition.button_remove", "hud_condition", config_key, k)
                )
            then
                table.insert(cond_remove, k)
            end

            imgui.table_set_column_index(1)
            imgui.text(cond_class:get_display_name())

            imgui.table_set_column_index(2)
            if cond_class:has_custom_options() then
                cond_class:draw_options()
            elseif cond_class.options then
                imgui.push_item_width(util_gui.get_item_size())
                set:combo(
                    string.format("##cond_opt.%s.%s", config_key, k),
                    string.format("%s.conditions.int:%s.combo", config_key, k),
                    state.bind_condition_options[cond.class].values
                )
                imgui.pop_item_width()
            else
                imgui.invisible_button("i_button3" .. config_key .. k, { 200, 0 })
            end

            end_rect_colored(resolve_highlight_color(highlight, path_fn(k), COLOR_NONE), 1)

            ::continue::
        end

        imgui.end_table()
    end

    return cond_remove
end

---@param conditions ConditionConfigBase[]
---@param config_key string
---@param combo_condition_key string
local function draw_add_condition(conditions, config_key, combo_condition_key)
    imgui.push_item_width(util_gui.get_item_size())
    set:combo("##conditions." .. config_key, combo_condition_key, state.combo.condition.values)
    imgui.pop_item_width()
    imgui.same_line()

    local combo = state.combo.condition
    imgui.begin_disabled(combo:size() == #conditions)

    if imgui.button(util_gui.tr("menu.bind.condition.button_add", "condition", config_key)) then
        local index = config:get(combo_condition_key) --[[@as integer]]
        local cond_key = combo:get_key(index) --[[@as string]]

        if
            not util_table.any(conditions, function(_, v)
                return cond_key == v.class
            end)
        then
            table.insert(conditions, bind_condition.conditions[cond_key]:new_config())
            config:save()
        end

        advance_combo_index(combo_condition_key, combo)
    end

    imgui.end_disabled()
end

---@param items ConditionSetConfig[]
---@param remove integer[]
---@return ConditionSetConfig[]
local function remove_sets(items, remove)
    if util_table.empty(remove) then
        return items
    end

    return util_table.filter_array(items, function(key, _)
        return not util_table.contains(remove, key)
    end)
end

---@param items ConditionSetConfig[]
---@param dragger any
---@param remove integer[]
---@param duplicate ConditionSetConfig?
---@return ConditionSetConfig[]
local function finalize_set_list(items, dragger, remove, duplicate)
    if dragger:is_released() then
        config:save()
    elseif dragger:is_drag() then
        util_table.sort(items, function(a, b)
            return dragger.item_pos[a] < dragger.item_pos[b]
        end)
    end

    if not util_table.empty(remove) then
        items = remove_sets(items, remove)
        config:save()
    end

    if duplicate then
        table.insert(items, util_table.deep_copy(duplicate))
        config:save()
    end

    return items
end

---@param cond_set ConditionSetConfig
---@param config_key string
---@param highlight boolean
---@param path_fn fun(k: integer): any[]
local function draw_condition_editor(cond_set, config_key, highlight, path_fn)
    local combo_condition_key = string.format("%s.combo_condition", config_key)
    draw_add_condition(cond_set.conditions, config_key, combo_condition_key)

    if not util_table.empty(cond_set.conditions) then
        imgui.separator()
    end

    local remove = draw_condition_rows(cond_set.conditions, config_key, highlight, path_fn)
    if not util_table.empty(remove) then
        cond_set.conditions = util_table.filter_array(cond_set.conditions, function(key, _)
            return not util_table.contains(remove, key)
        end)
        config:save()
    end
end

---@param params ConditionSetDrawParams
---@return boolean remove
---@return boolean duplicate
local function draw_condition_set(params)
    local cond_set = params.cond_set
    cond_set.conditions = cond_set.conditions or {}

    imgui.begin_rect()
    imgui.indent(5)
    util_imgui.spacer(0, 5)

    params.dragger:draw_drag_button(tostring(params.index), cond_set)
    imgui.same_line()

    if imgui.arrow_button(params.collapse_id, cond_set.collapsed and 1 or 3) then
        cond_set.collapsed = not cond_set.collapsed
        config:save()
    end

    if cond_set.collapsed then
        util_imgui.tooltip(build_condition_tooltip(cond_set.conditions, params.config_key))
    end

    imgui.same_line()
    local remove = imgui.button(params.remove_label)

    imgui.same_line()
    local duplicate = imgui.button(params.duplicate_label)

    imgui.same_line()
    params.draw_selector()
    imgui.same_line()
    imgui.invisible_button("i_button1" .. params.collapse_id, { 0, 0 })

    if not cond_set.collapsed then
        imgui.separator()
        draw_condition_editor(
            cond_set,
            params.config_key,
            params.highlight,
            params.condition_path_fn
        )

        if params.draw_expanded then
            params.draw_expanded()
        end
    end

    imgui.invisible_button("i_button2" .. params.collapse_id, { 0, 1 })
    imgui.unindent(5)

    end_rect_colored(resolve_highlight_color(params.highlight, params.pass_path, COLOR_FAIL), 0)

    imgui.indent(5)
    params.dragger:check_drag_pos(cond_set, -5, -5)
    imgui.unindent(5)
    util_imgui.spacer(0, 5)

    return remove, duplicate
end

---@param items ConditionSetConfig[]
---@param dragger any
---@param draw_item fun(i: integer, cond_set: ConditionSetConfig): boolean, boolean
---@return ConditionSetConfig[]
local function draw_condition_set_list(items, dragger, draw_item)
    dragger:clear()
    imgui.indent(1)

    ---@type integer[]
    local remove = {}
    ---@type ConditionSetConfig?
    local duplicate

    for i, cond_set in ipairs(items) do
        local should_remove, should_duplicate = draw_item(i, cond_set)
        if should_remove then
            table.insert(remove, i)
        end
        if should_duplicate then
            duplicate = cond_set
        end
    end

    imgui.unindent(1)
    return finalize_set_list(items, dragger, remove, duplicate)
end

---@param i integer
---@param cond_set ConditionSetConfig
---@param elem_profiles HudBaseConfigProfileForShow[]
local function draw_element_profiles(i, cond_set, elem_profiles)
    local values = util_table.slice(elem_profiles, 2, #elem_profiles)

    imgui.spacing()
    imgui.indent(2)
    imgui.begin_disabled(util_table.empty(values))

    local bad_key = util_table.value(cond_set.children, function(_, value)
        return value.parent_key ~= cond_set.key
    end)

    if bad_key then
        local config_mod = config.current.mod
        local bad_profiles = config_mod.hud[bad_key.parent_key].profile
        values = util_table.slice(bad_profiles, 2, #bad_profiles)

        imgui.text_colored(
            config.lang:tr("menu.bind.condition.tooltip_wrong_parent_key"),
            mod.enum.colors.bad
        )
        if imgui.button(util_gui.tr("menu.bind.condition.button_clear", "element_profiles")) then
            cond_set.children = {}
            config:save()
        end
    else
        if
            imgui.button(
                util_gui.tr("menu.bind.condition.button_add_new_condition", "element_profiles")
            )
        then
            table.insert(
                cond_set.children,
                bind_condition.new_condition_set(elem_profiles[1].key, cond_set.key)
            )
            cond_set.children[#cond_set.children].combo_profile = 0
            config:save()
        end
    end

    if not util_table.empty(cond_set.children) then
        imgui.separator()
    end

    imgui.begin_disabled(bad_key ~= nil)
    cond_set.children = draw_condition_set_list(
        cond_set.children,
        elem_drag,
        function(j, cond_child)
            local config_key = string.format("mod.bind.condition.hud.int:%s.children.int:%s", i, j)

            return draw_condition_set({
                index = j,
                cond_set = cond_child,
                config_key = config_key,
                dragger = elem_drag,
                collapse_id = string.format("cond_set_collapse.%s.%s", i, j),
                remove_label = util_gui.tr(
                    "menu.bind.condition.button_remove",
                    "hud_condition",
                    i,
                    j
                ),
                duplicate_label = util_gui.tr(
                    "menu.bind.condition.button_duplicate",
                    "hud_condition",
                    i,
                    j
                ),
                highlight = config.current.mod.bind.condition.highlight_pass,
                pass_path = { i, "children", j, "pass" },
                condition_path_fn = function(k)
                    return { i, "children", j, "conditions", k }
                end,
                draw_selector = function()
                    if
                        util_bind.profile_multi_combo(
                            util_gui.tr("menu.bind.condition.combo_elem_profile", i, j),
                            string.format("%s.combo_profile", config_key),
                            values,
                            bad_key ~= nil
                        )
                    then
                        cond_child.key = config:get(string.format("%s.combo_profile", config_key))
                        config:save()
                    end
                end,
            })
        end
    )

    imgui.end_disabled()
    imgui.end_disabled()
    imgui.spacing()
    imgui.unindent(2)
end

local function draw_condition_bind_menu()
    local config_mod = config.current.mod

    imgui.spacing()
    imgui.indent(2)
    imgui.begin_disabled(util_table.empty(config_mod.hud))

    if imgui.button(util_gui.tr("menu.bind.condition.button_add_new_condition")) then
        table.insert(
            config_mod.bind.condition.hud,
            bind_condition.new_condition_set(config_mod.hud[1].key)
        )
        config:save()
    end

    util_imgui.tooltip(config.lang:tr("menu.bind.condition.tooltip_add_new_condition"), true)

    if not util_table.empty(config_mod.bind.condition.hud) then
        imgui.separator()
    end

    config_mod.bind.condition.hud = draw_condition_set_list(
        config_mod.bind.condition.hud,
        drag,
        function(i, cond_set)
            local config_key = "mod.bind.condition.hud.int:" .. i
            cond_set.children = cond_set.children or {}

            return draw_condition_set({
                index = i,
                cond_set = cond_set,
                config_key = config_key,
                dragger = drag,
                collapse_id = "cond_set_collapse" .. i,
                remove_label = util_gui.tr("menu.bind.condition.button_remove", "hud_condition", i),
                duplicate_label = util_gui.tr(
                    "menu.bind.condition.button_duplicate",
                    "hud_condition",
                    i
                ),
                highlight = config_mod.bind.condition.highlight_pass,
                pass_path = { i, "pass" },
                condition_path_fn = function(j)
                    return { i, "conditions", j }
                end,
                draw_selector = function()
                    imgui.push_item_width(util_gui.get_item_size())
                    if
                        set:combo(
                            util_gui.tr("menu.bind.condition.combo_profile", i),
                            string.format("%s.combo_profile", config_key),
                            state.combo.hud.values
                        )
                    then
                        cond_set.key = config_mod.hud[config:get(
                            string.format("%s.combo_profile", config_key)
                        )].key
                        config:save()
                    end
                    imgui.pop_item_width()
                end,
                draw_expanded = function()
                    imgui.separator()
                    util_menubar.draw_menu(
                        util_gui.tr("menu.bind.condition.menubar_element_profiles", i),
                        function()
                            draw_element_profiles(i, cond_set, config_mod.hud[cond_set.key].profile)
                        end
                    )
                end,
            })
        end
    )

    imgui.end_disabled()
    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    util_menubar.draw_menu(util_gui.tr("menu.bind.condition.name"), draw_condition_bind_menu)
end

return this
