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
---@field draw_additional_opt fun()?
---@field draw_expanded fun()?

---@class ConditionOptionDrawParams
---@field field string
---@field tr_key string
---@field combo Combo
---@field default_value any
---@field draw_value fun(config_key: string, i: integer, j: integer)

local bind_condition = require("HudController.hud.bind.condition.init")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local drag_util = require("HudController.gui.drag")
local generic = require("HudController.gui.elements.profile.panel.generic")
local mod = require("HudController.data.mod")
local set = require("HudController.gui.set")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_table = require("HudController.util.misc.table")

local drag = drag_util:new()
local elem_drag = drag_util:new()

local this = {}

local COLOR_PASS = 0xff3eb231
local COLOR_FAIL = 0xff6a6a6a
local COLOR_NONE = 0

---@return number
local function get_width()
    return config.lang.font_size * (500 / 16)
end

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
                cd.bind_condition_options[cond.class]:get_value(index)
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

---@param conditions ConditionConfigBase[]
---@param config_key string
---@param highlight boolean
---@param path_fn fun(k: integer): any[]
---@return integer[]
local function draw_condition_rows(conditions, config_key, highlight, path_fn)
    local cond_remove = {}

    if util_table.empty(conditions) then
        util_imgui.adjust_pos(0, 2)
        imgui.text(config.lang:tr("menu.bind.condition.text_no_condition"))
    end

    if
        imgui.begin_table(
            "conditions_" .. config_key,
            3,
            imgui.TableFlags.SizingFixedFit,
            Vector2f.new(get_width() - 12, 0)
        )
    then
        imgui.table_setup_column("##buttons", imgui.ColumnFlags.WidthFixed)
        imgui.table_setup_column("##name", imgui.ColumnFlags.WidthFixed)
        imgui.table_setup_column("##options", imgui.ColumnFlags.WidthStretch)

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

            local x_size = util_imgui.get_max_button_size(
                config.lang:tr("menu.bind.condition.expected_result_values.TRUE"),
                config.lang:tr("menu.bind.condition.expected_result_values.FALSE")
            )

            imgui.same_line()

            if
                imgui.button(
                    util_gui.tr(
                        "menu.bind.condition.expected_result_values."
                            .. util_table.reverse_lookup(
                                mod.enum.expected_result,
                                cond.expected_result
                            ),
                        "hud_condition",
                        config_key,
                        k
                    ),
                    { x_size, 0 }
                )
            then
                if cond.expected_result == mod.enum.expected_result.TRUE then
                    cond.expected_result = mod.enum.expected_result.FALSE
                else
                    cond.expected_result = mod.enum.expected_result.TRUE
                end

                config:set(
                    string.format("%s.conditions.int:%s.expected_result", config_key, k),
                    cond.expected_result
                )
            end

            imgui.table_set_column_index(1)
            imgui.text(cond_class:get_display_name())

            imgui.table_set_column_index(2)
            if cond_class:has_custom_options() then
                cond_class:draw_options()
            elseif cond_class.options then
                imgui.push_item_width(-2)
                set:combo_filter(
                    string.format("##cond_opt.%s.%s", config_key, k),
                    string.format("%s.conditions.int:%s.combo", config_key, k),
                    cd.bind_condition_options[cond.class]
                )
                imgui.pop_item_width()
            else
                imgui.invisible_button("i_button3" .. config_key .. k, { -2, 0 })
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
    local combo = cd.get_profile_combo("condition", config_key, function(_, key, _)
        return util_table.any(conditions, function(_, value)
            return key == value.class
        end)
    end)

    util_imgui.begin_disabled(combo:empty())
    local row_width = util_imgui.get_row_width()
    imgui.set_next_item_width(row_width)
    row_width =
        util_imgui.get_something_with_button_width(config.lang:tr("menu.bind.condition.button_add"))
    imgui.set_next_item_width(row_width)
    set:combo_filter("##conditions." .. config_key, combo_condition_key, combo)

    imgui.same_line()

    if imgui.button(util_gui.tr("menu.bind.condition.button_add", "condition", config_key)) then
        local index = config:get(combo_condition_key) --[[@as integer]]
        local cond_key = combo:get_key(index) --[[@as string]]
        local cond = bind_condition.conditions[cond_key]

        table.insert(conditions, cond:new_config())
        config:set(combo_condition_key, combo:disable_item(cond_key))
        config:save()
    end

    util_imgui.end_disabled()
end

---@param items ConditionSetConfig[]
---@param remove integer[]
---@return ConditionSetConfig[]
local function remove_sets(items, remove)
    if util_table.empty(remove) then
        return items
    end

    return util_table.filter_array(items, function(key, _)
        return not util_table.contains_any(remove, key)
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
        cd.clear_cache()
    end

    if not util_table.empty(remove) then
        items = remove_sets(items, remove)
        cd.clear_cache()
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
    util_imgui.adjust_pos(0, 1)
    draw_add_condition(cond_set.conditions, config_key, combo_condition_key)

    util_imgui.adjust_pos(0, -2)
    local remove = draw_condition_rows(cond_set.conditions, config_key, highlight, path_fn)
    if not util_table.empty(remove) then
        local combo = cd.get_profile_combo("condition", config_key)

        for _, i in ipairs(remove) do
            config:set(combo_condition_key, combo:enable_item(cond_set.conditions[i].class))
        end
        cond_set.conditions = util_table.filter_array(cond_set.conditions, function(key, _)
            return not util_table.contains_any(remove, key)
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
    util_imgui.dummy_button3(
        "##window_padding_hud1",
        { 1, util_imgui.get_button_height() },
        { -3, 0 }
    )

    if not cond_set.collapsed then
        if params.draw_additional_opt then
            params.draw_additional_opt()
        end

        draw_condition_editor(
            cond_set,
            params.config_key,
            params.highlight,
            params.condition_path_fn
        )

        if params.draw_expanded then
            params.draw_expanded()
        end
    else
        util_imgui.spacer(0, 2)
    end

    imgui.unindent(5)
    util_imgui.spacer(0, 5)
    end_rect_colored(resolve_highlight_color(params.highlight, params.pass_path, COLOR_FAIL), 0)
    imgui.indent(5)
    params.dragger:check_drag_pos(cond_set, -5, -5)
    imgui.unindent(5)

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

    local bad_key = util_table.find_value(cond_set.element_profile, function(_, value)
        return value.parent_key ~= cond_set.key
    end)

    util_imgui.begin_disabled(util_table.empty(values) and not bad_key)

    imgui.begin_group()
    util_imgui.dummy_button3("##window_padding_hud3", { get_width(), 1 })
    util_imgui.separator_text_item(
        config.lang:tr("menu.bind.condition.category_element_profile"),
        util_imgui.get_button_width(config.lang:tr("menu.bind.condition.button_add_new_condition")),
        { 0, 3 },
        nil,
        nil,
        0xffffffff
    )

    local bad_key = util_table.find_value(cond_set.element_profile, function(_, value)
        return value.parent_key ~= cond_set.key
    end)

    util_imgui.begin_disabled(util_table.empty(values) and not bad_key)
    imgui.same_line()
    util_imgui.adjust_pos(3)
    if
        imgui.button(
            util_gui.tr("menu.bind.condition.button_add_new_condition", "element_profiles")
        )
    then
        table.insert(
            cond_set.element_profile,
            bind_condition.new_condition_set(elem_profiles[1].key, cond_set.key)
        )
        cond_set.element_profile[#cond_set.element_profile].combo_profile = 0
        config:save()
    end
    util_imgui.end_disabled()
    imgui.end_group()
    util_imgui.tooltip(config.lang:tr("menu.bind.condition.tooltip_elem_condition_set"))
    util_imgui.begin_disabled(util_table.empty(values) and not bad_key)

    if bad_key then
        local config_mod = config.current.mod
        local bad_hud = config_mod.hud[bad_key.parent_key]
        local bad_profiles = bad_hud.profile
        values = util_table.slice(bad_profiles, 2, #bad_profiles)

        imgui.text_colored(
            string.format(
                config.lang:tr("menu.bind.condition.tooltip_wrong_parent_key"),
                bad_hud.name,
                bad_hud.name
            ),
            mod.enum.colors.bad
        )
        if imgui.button(util_gui.tr("menu.bind.condition.button_clear", "element_profiles")) then
            cond_set.element_profile = {}
            config:save()
        end
    end

    util_imgui.begin_disabled(bad_key ~= nil)
    cond_set.element_profile = draw_condition_set_list(
        cond_set.element_profile,
        elem_drag,
        function(j, cond_child)
            local config_key =
                string.format("mod.bind.condition.hud.int:%s.element_profile.int:%s", i, j)

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
                pass_path = { i, "element_profile", j, "pass" },
                condition_path_fn = function(k)
                    return { i, "element_profile", j, "conditions", k }
                end,
                draw_selector = function()
                    imgui.set_next_item_width(-9)
                    if
                        set:combo_multi_bits_filter(
                            string.format("##%s.%s.%s.%s", "combo_profile", config_key, i, j),
                            string.format("%s.combo_profile", config_key),
                            config.lang:tr("misc.text_none"),
                            values,
                            function(v)
                                return v.key
                            end,
                            function(v)
                                return v.name
                            end
                        )
                    then
                        cond_child.key = config:get(string.format("%s.combo_profile", config_key))
                        config:save()
                    end
                end,
            })
        end
    )

    util_imgui.end_disabled()
    util_imgui.end_disabled()
    imgui.spacing()
    imgui.unindent(2)
end

---@param i integer
---@param cond_set ConditionSetConfig
---@param params ConditionOptionDrawParams
local function draw_options(i, cond_set, params)
    imgui.spacing()
    imgui.indent(2)

    imgui.begin_group()
    util_imgui.dummy_button3("##window_padding_hud3", { get_width(), 1 })
    util_imgui.separator_text_item(
        config.lang:tr("menu.bind.condition.category_" .. params.tr_key),
        util_imgui.get_button_width(config.lang:tr("menu.bind.condition.button_add_new_condition")),
        { 0, 3 },
        nil,
        nil,
        0xffffffff
    )

    imgui.same_line()
    util_imgui.adjust_pos(3)
    ---@type ConditionSetConfig[]
    local items = cond_set[params.field]
    if imgui.button(util_gui.tr("menu.bind.condition.button_add_new_condition", params.tr_key)) then
        table.insert(
            items,
            bind_condition.new_condition_set(params.combo:get_keys()[1], cond_set.key)
        )

        items[#items].free_value = params.default_value
        config:save()
    end
    imgui.end_group()
    util_imgui.tooltip(config.lang:tr("menu.bind.condition.tooltip_option_condition_set"))

    ---@diagnostic disable-next-line: no-unknown
    cond_set[params.field] = draw_condition_set_list(items, elem_drag, function(j, cond_child)
        local config_key =
            string.format("mod.bind.condition.hud.int:%s.%s.int:%s", i, params.field, j)

        return draw_condition_set({
            index = j,
            cond_set = cond_child,
            config_key = config_key,
            dragger = elem_drag,
            collapse_id = string.format("cond_set_collapse.%s.%s.%s", params.field, i, j),
            remove_label = util_gui.tr("menu.bind.condition.button_remove", params.field, i, j),
            duplicate_label = util_gui.tr(
                "menu.bind.condition.button_duplicate",
                params.field,
                i,
                j
            ),
            highlight = config.current.mod.bind.condition.highlight_pass,
            pass_path = { i, params.field, j, "pass" },
            condition_path_fn = function(k)
                return { i, params.field, j, "conditions", k }
            end,
            draw_selector = function()
                local item_config_key = string.format("%s.combo_profile", config_key)
                imgui.set_next_item_width(-9)

                if
                    set:combo_filter(
                        string.format("##%s.%s.%s.%s", "combo_profile", params.field, i, j),
                        item_config_key,
                        params.combo
                    )
                then
                    cond_child.key = params.combo:get_key(config:get(item_config_key))
                    config:save()
                end
            end,
            draw_additional_opt = function()
                params.draw_value(config_key, i, j)
            end,
        })
    end)

    util_imgui.end_disabled()
    imgui.spacing()
    imgui.unindent(2)
end

---@param config_key string
---@param i integer
---@param j integer
local function draw_enable_disable(config_key, i, j)
    util_imgui.adjust_pos(0, 1)
    imgui.set_next_item_width(util_imgui.get_row_width())
    set:combo_filter(
        "##option" .. i .. j,
        string.format("%s.free_value", config_key),
        cd.combo.enable_disable
    )
    util_imgui.adjust_pos(0, -1)
end

---@param config_key string
---@param i integer
---@param j integer
local function draw_game_option(config_key, i, j)
    util_imgui.adjust_pos(0, 1)
    imgui.set_next_item_width(util_imgui.get_row_width())
    generic.draw_option(
        cd.combo.option_game_bind:get_key(config:get(string.format("%s.combo_profile", config_key))),
        string.format("%s.free_value", config_key),
        nil,
        string.format("##.%s.%s.%s", config_key, i, j),
        false
    )
    util_imgui.adjust_pos(0, -1)
end

---@param i integer
---@param cond_set ConditionSetConfig
local function draw_hud_options(i, cond_set)
    draw_options(i, cond_set, {
        field = "hud_option",
        tr_key = "hud_options",
        combo = cd.combo.option_bind,
        default_value = 1,
        draw_value = draw_enable_disable,
    })
end

---@param i integer
---@param cond_set ConditionSetConfig
local function draw_game_options(i, cond_set)
    util_imgui.begin_disabled(cd.combo.option_game_bind:empty())
    draw_options(i, cond_set, {
        field = "game_option",
        tr_key = "game_options",
        combo = cd.combo.option_game_bind,
        default_value = 0,
        draw_value = draw_game_option,
    })
    util_imgui.end_disabled()
end

---@param i integer
---@param cond_set ConditionSetConfig
local function draw_mod_options(i, cond_set)
    draw_options(i, cond_set, {
        field = "mod_option",
        tr_key = "mod_options",
        combo = cd.combo.option_mod_bind,
        default_value = 1,
        draw_value = draw_enable_disable,
    })
end

local function draw_condition_bind_menu()
    local config_mod = config.current.mod

    imgui.spacing()
    imgui.indent(2)

    imgui.begin_group()
    util_imgui.dummy_button3("##window_padding_hud2", { get_width(), 1 })
    util_imgui.separator_text_item(
        config.lang:tr("menu.bind.condition.category_hud"),
        util_imgui.get_button_width(config.lang:tr("menu.bind.condition.button_add_new_condition")),
        { 0, 3 },
        nil,
        nil,
        0xffffffff
    )

    util_imgui.begin_disabled(util_table.empty(config_mod.hud))
    util_imgui.adjust_pos(3)
    if imgui.button(util_gui.tr("menu.bind.condition.button_add_new_condition")) then
        table.insert(
            config_mod.bind.condition.hud,
            bind_condition.new_condition_set(config_mod.hud[1].key)
        )
        config:save()
    end
    imgui.end_group()
    util_imgui.tooltip(config.lang:tr("menu.bind.condition.tooltip_add_new_condition"))

    config_mod.bind.condition.hud = draw_condition_set_list(
        config_mod.bind.condition.hud,
        drag,
        function(i, cond_set)
            local config_key = "mod.bind.condition.hud.int:" .. i
            cond_set.element_profile = cond_set.element_profile or {}
            cond_set.hud_option = cond_set.hud_option or {}
            cond_set.mod_option = cond_set.mod_option or {}
            cond_set.game_option = cond_set.game_option or {}

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
                    imgui.push_item_width(-9)
                    if
                        set:combo_filter(
                            "##combo_profile" .. i,
                            string.format("%s.combo_profile", config_key),
                            cd.combo.hud
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
                    util_imgui.adjust_pos(0, -4)

                    if
                        imgui.begin_table(
                            "##condition_menus_" .. i,
                            1,
                            imgui.TableFlags.SizingFixedFit | imgui.TableFlags.NoHostExtendX --[[@as ImGuiTableFlags]],
                            Vector2f.new(get_width() - 12, 0)
                        )
                    then
                        imgui.table_setup_column("##menu", imgui.ColumnFlags.WidthStretch)

                        imgui.table_next_row()
                        imgui.table_set_column_index(0)
                        imgui.separator()

                        util_menubar.draw_menu(
                            util_gui.tr("menu.bind.condition.menubar_element_profiles", i),
                            function()
                                draw_element_profiles(
                                    i,
                                    cond_set,
                                    config_mod.hud[cond_set.key].profile
                                )
                            end
                        )

                        util_menubar.draw_menu(
                            util_gui.tr("menu.bind.condition.menubar_hud_options", i),
                            function()
                                draw_hud_options(i, cond_set)
                            end
                        )

                        util_menubar.draw_menu(
                            util_gui.tr("menu.bind.condition.menubar_mod_options", i),
                            function()
                                draw_mod_options(i, cond_set)
                            end
                        )

                        util_menubar.draw_menu(
                            util_gui.tr("menu.bind.condition.menubar_game_options", i),
                            function()
                                draw_game_options(i, cond_set)
                            end
                        )

                        imgui.end_table()
                    end
                end,
            })
        end
    )

    util_imgui.end_disabled()
    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    util_menubar.draw_menu(util_gui.tr("menu.bind.condition.name"), draw_condition_bind_menu)
end

return this
