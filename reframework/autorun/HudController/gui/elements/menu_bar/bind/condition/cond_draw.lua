local bind_condition = require("HudController.hud.bind.condition.init")
local cd = require("HudController.data.combo")
local color = require("HudController.util.imgui.color")
local combo_popup = require("HudController.util.imgui.combo.combo_popup")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local drag_util = require("HudController.gui.drag")
local managers = require("HudController.gui.elements.menu_bar.bind.condition.managers.init")
local op = require("HudController.hud.manager.op.init")
local set = require("HudController.gui.set")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local drag = drag_util:new()
local mod_enum = data.mod.enum

local this = {}

---@return table<BindCondType, string>, number
function this.get_buttons()
    ---@type table<BindCondType, string>
    local ret = {}
    for _, cond_type in
        pairs(mod_enum.bind_cond_type --[[@as table<string, BindCondType>]])
    do
        ret[cond_type] = config.lang:tr("menu.bind.condition.bind_cond_type." .. cond_type)
    end

    local max_width = 0
    for _, label in pairs(ret) do
        max_width = math.max(max_width, imgui.calc_text_size(label).x) --[[@as number]]
    end

    max_width = max_width + config.lang.font_size
    return ret, max_width
end

---@param buttons table<BindCondType, string>
---@param config_key string
---@return ConditionBindRuleSet?, integer?
function this.draw_buttons(buttons, config_key)
    local changed = false
    local sets = config:get(config_key .. ".sets")--[==[@as ConditionBindRuleSet[]]==]
    local struct = config:get(config_key) --[[@as ConditionBindRuleConfig | ConditionBindStateConfig]]
    local index = util_table.index(sets, function(o)
        return o.type == struct.cond_type_selection
    end)

    imgui.set_next_item_width(-1)
    combo_popup.combo_popup_filter(
        "##cond_main_add_rule",
        "",
        util_table.keys(buttons),
        function(query, _)
            ---@type BindCondType[]
            local sorted = {}
            for i, label in pairs(buttons) do
                if label:lower():find(query, 1, true) ~= nil then
                    table.insert(sorted, i)
                end
            end
            table.sort(sorted, function(a, b)
                return buttons[a] < buttons[b]
            end)

            ---@type table<BindCondType, boolean>
            local selected = {}
            for _, set in pairs(sets) do
                selected[set.type] = true
            end

            for _, bind_type in ipairs(sorted) do
                if
                    bind_type == mod_enum.bind_cond_type.OPTION_USER
                    and cd.combo.option_user_bind:empty()
                then
                    goto continue
                end

                local manager = managers[bind_type]
                util_imgui.begin_disabled(manager:empty())

                if util_imgui.menu_item(buttons[bind_type], selected[bind_type]) then
                    if selected[bind_type] then
                        table.remove(
                            sets,
                            util_table.index(sets, function(o)
                                return o.type == bind_type
                            end)
                        )
                        index = 1
                        if sets[index] then
                            struct.cond_type_selection = sets[index].type
                        end

                        config:save()
                    else
                        table.insert(sets, bind_condition.new_condition_rule_set(bind_type))
                        struct.cond_type_selection = bind_type
                        config:save()
                    end
                end

                util_imgui.end_disabled()
                ::continue::
            end
        end,
        function(_)
            return config.lang:tr("menu.bind.condition.combo_add_rules")
        end
    )

    drag:clear()

    local sel = sets[index]
    ---@type integer?
    local to_remove
    for i, set in ipairs(sets) do
        drag:draw_drag_button(set.type, set.type)
        imgui.same_line()

        if util_imgui.draw_remove_button("cond_set_main_remove|" .. set.type) then
            to_remove = i
            changed = true
        end

        imgui.same_line()

        if
            util_imgui.draw_sel_button(
                string.format(
                    "%s##bind_cond_sel_button|%s",
                    config.lang:tr("menu.bind.condition.bind_cond_type." .. set.type),
                    set.type
                ),
                struct.cond_type_selection == set.type,
                { -1, 0 }
            )
        then
            struct.cond_type_selection = set.type
            index = i
        end

        drag:check_drag_pos(set.type)
    end

    if drag:is_released() then
        changed = true
    elseif drag:is_drag() then
        table.sort(sets, function(a, b)
            return drag.item_pos[a.type] < drag.item_pos[b.type]
        end)

        index = util_table.index(sets, function(o)
            return o == sel
        end)
    end

    if to_remove then
        table.remove(sets, to_remove)
        index = 1

        if sets[index] then
            struct.cond_type_selection = sets[index].type
        end

        changed = true
    end

    if changed then
        config:save()
    end

    return index and sets[index], index
end

---@param manager GuiCondManagerBase
---@param config_key string
---@param readonly boolean?
function this.draw_conditions(manager, config_key, readonly)
    local conditions = config:get(config_key) --[==[@as ConditionConfigBase[]]==]
    readonly = readonly or false

    ---@type integer?
    local to_remove
    local x_size = util_imgui.get_max_button_size(
        config.lang:tr("menu.bind.condition.expected_result_values.TRUE"),
        config.lang:tr("menu.bind.condition.expected_result_values.FALSE")
    )
    local item_size = readonly and -1 or -3

    if imgui.begin_table("conditions_" .. config_key, 3, imgui.TableFlags.SizingFixedFit) then
        imgui.table_setup_column("##buttons", imgui.ColumnFlags.WidthFixed)
        imgui.table_setup_column("##name", imgui.ColumnFlags.WidthFixed)
        imgui.table_setup_column("##options", imgui.ColumnFlags.WidthStretch)

        for i, cond in ipairs(conditions) do
            imgui.table_next_row()
            local cond_class = bind_condition.conditions[cond.class]
            local cond_path = string.format("%s.int:%s", config_key, i)
            local invalid = manager:get_cond_invalid(cond_path)

            imgui.table_set_column_index(0)
            imgui.begin_rect()

            if not readonly then
                if util_imgui.draw_remove_button("cond_remove|" .. i) then
                    to_remove = i
                end

                imgui.same_line()
            end

            if
                imgui.button(
                    util_gui.tr(
                        "menu.bind.condition.expected_result_values."
                            .. (cond.negate and "FALSE" or "TRUE"),
                        "hud_condition",
                        config_key,
                        i
                    ),
                    { x_size, 0 }
                )
            then
                cond.negate = not cond.negate
                config:save()
            end

            imgui.table_set_column_index(1)

            if not cond_class or invalid.class then
                imgui.text_colored(cond.class, color.with_alpha(mod_enum.colors.bad))

                if invalid.class then
                    util_imgui.tooltip(invalid.class)
                end
            else
                imgui.text(cond_class:get_display_name())
            end

            imgui.table_set_column_index(2)
            imgui.begin_rect()

            util_misc.try(function()
                if invalid.class_config then
                    util_imgui.tooltip(
                        invalid.class_config,
                        true,
                        config.lang:tr("misc.text_error"),
                        color.with_alpha(mod_enum.colors.bad)
                    )
                    imgui.same_line()
                    imgui.invisible_button("i_button3" .. config_key .. i, { item_size, 0 })

                    return
                end

                local changed = false
                local key = string.format("%s.int:%s", config_key, i)
                if cond_class and cond_class:has_custom_options() then
                    changed = cond_class:draw_options(key) or changed
                elseif cond_class and cond_class.options then
                    imgui.set_next_item_width(item_size)

                    changed = set:combo_filter(
                        string.format("##cond_opt.%s.%s", config_key, i),
                        key .. ".combo",
                        cd.bind_condition_options[cond.class]
                    ) or changed

                    if changed then
                        config:set(
                            key .. ".combo_key",
                            cd.bind_condition_options[cond.class]:get_key(
                                config:get(key .. ".combo")
                            )
                        )
                    end
                else
                    imgui.invisible_button("i_button3" .. config_key .. i, { item_size, 0 })
                end

                if changed then
                    op.bind.set_condition_error(cond, "class_config_value", nil)
                end
            end, function(err)
                op.bind.set_condition_error(cond, "class_config", err)
            end)

            if invalid.class_config_value then
                util_imgui.tooltip(invalid.class_config_value)
            end

            imgui.push_style_color(
                5,
                (invalid.class_config or invalid.class_config_value)
                        and color.with_alpha(mod_enum.colors.bad)
                    or 0
            )
            imgui.end_rect(0, 2)
            imgui.pop_style_color(1)

            imgui.push_style_color(
                5,
                invalid.class and color.with_alpha(mod_enum.colors.bad)
                    or ((config.current.mod.bind.condition.highlight_pass_cond and manager:is_cond_triggering(
                        cond_path
                    )) and color.with_alpha(mod_enum.colors.good))
                    or 0
            )
            imgui.end_rect(0, 2)
            imgui.pop_style_color(1)
        end

        imgui.push_style_var(imgui.ImGuiStyleVar.ItemSpacing, Vector2f.new(2, 2))
        imgui.end_table()
        imgui.pop_style_var(1)
    end

    if to_remove then
        table.remove(conditions, to_remove)
        config:save()
    end
end

---@param manager GuiCondManagerBase
---@param config_key string
function this.draw_condition_target(manager, config_key)
    local conditions = config:get(config_key .. ".conditions") --[==[@as ConditionConfigBase[][]]==]

    util_imgui.begin_disabled(manager:empty())
    ---@type integer?
    local to_remove
    for i, _ in ipairs(conditions) do
        if i > 1 then
            util_imgui.separator_text_centered(config.lang:tr("misc.text_or"))
        end

        util_imgui.begin_disabled(#conditions == 1)

        if util_imgui.draw_remove_button("cond_group_remove|" .. i) then
            to_remove = i
        end

        util_imgui.end_disabled()

        imgui.same_line()

        local cond_key = string.format("%s.conditions.int:%s", config_key, i)

        imgui.set_next_item_width(-3)
        local changed = manager:draw_condition_target(cond_key)

        if changed and type(changed) == "string" then
            local t = config:get(cond_key) --[==[@as ConditionConfigBase[]]==]
            table.remove(
                t,
                util_table.index(t, function(o)
                    return o.class == changed
                end)
            )
            config:save()
        elseif changed and type(changed) == "table" then
            table.insert(config:get(cond_key), changed)
            config:save()
        end

        util_imgui.adjust_pos(0, -2)
        this.draw_conditions(manager, cond_key)
    end

    if util_imgui.draw_add_button("cond_or") then
        table.insert(conditions, bind_condition.new_conditions())
        config:save()
    end
    util_imgui.tooltip(config.lang:tr("menu.bind.condition.tooltip_add_or"))

    if to_remove then
        table.remove(conditions, to_remove)
        config:save()
    end

    util_imgui.end_disabled()
end

---@param manager GuiCondManagerBase
---@param config_key string
function this.draw_target(manager, config_key)
    drag:clear()

    local sel_key = config_key .. ".selection"
    local rules_key = config_key .. ".rules"
    local rules = config:get(rules_key) --[==[@as ConditionBindRuleConfig[]]==]
    local is_mouse_clicked = imgui.is_mouse_clicked(0)
    local dl = imgui.get_window_draw_list()
    local ret = config:get(sel_key)
    local changed = false
    local sel = rules[ret]
    ---@type integer?
    local to_remove
    local highlight = config.current.mod.bind.condition.highlight_pass_rule

    for i, rule in ipairs(rules) do
        local rule_path = string.format("%s.int:%s", rules_key, i)
        local start_pos = imgui.get_cursor_screen_pos()

        imgui.begin_rect()
        imgui.begin_group()

        util_imgui.spacer(10)
        imgui.same_line()
        imgui.begin_group()
        util_imgui.spacer_y(4)

        drag:draw_drag_button(tostring(rule), rule, -4)
        imgui.same_line()

        util_imgui.begin_disabled(#rules == 1)

        if util_imgui.draw_remove_button("cond_target_remove|" .. i) then
            to_remove = i
        end

        local remove_hovered = imgui.is_item_hovered()
        util_imgui.end_disabled()

        imgui.same_line()
        imgui.push_item_width(-4)

        this.draw_manager_target(manager, rule_path)

        imgui.pop_item_width()
        util_imgui.spacer_y(4)

        imgui.end_group()
        imgui.end_group()

        local col = 0xff493e36
        if ret == i then
            col = 0xff7f4a18
        end

        if highlight then
            if manager:is_rule_overridden(rule_path) then
                col = 0xff1f6baa
            end

            if manager:is_rule_triggering(rule_path) then
                col = mod_enum.colors.good
            end
        end

        imgui.push_style_color(5, color.with_alpha(col))
        imgui.end_rect(0, 0)
        imgui.pop_style_color(1)

        if not drag:is_drag(rule) then
            local end_pos = imgui.get_cursor_screen_pos()
            end_pos.y = end_pos.y - 4

            dl:add_line(
                start_pos,
                end_pos,
                color.with_alpha(ret == i and 0xffd47b35 or 0xff8a7668),
                3
            )
        end

        if imgui.is_item_hovered() and is_mouse_clicked and not remove_hovered then
            changed = true
            ret = i
        end

        drag:check_drag_pos(rule)
    end

    if not drag:is_released() and drag:is_drag() and not is_mouse_clicked then
        table.sort(rules, function(a, b)
            return drag.item_pos[a] < drag.item_pos[b]
        end)
        ret = util_table.index(rules, sel) or 1
        changed = true
    elseif drag:is_released() then
        ret = util_table.index(rules, sel) or 1
        changed = true
    end

    if util_imgui.draw_add_button("cond_add_rule|" .. config_key, nil) then
        table.insert(rules, bind_condition.new_condition_rule())
        config:save()
    end
    util_imgui.tooltip(config.lang:tr("menu.bind.condition.tooltip_add_rule"))

    if to_remove then
        table.remove(rules, to_remove)
        ret = util_table.index(rules, sel) or 1
        changed = true
    end

    if changed then
        config:set(sel_key, ret)
        config:save()
    end

    return ret
end

---@param manager GuiCondManagerBase
---@param rule_path string
---@return boolean
function this.draw_manager_target(manager, rule_path)
    local changed = false
    local invalid = manager:get_rule_invalid(rule_path)
    local rule = config:get(rule_path)

    util_imgui.begin_disabled(manager:empty())

    imgui.begin_rect()

    if manager:draw_target(rule_path) then
        changed = true
        op.bind.set_condition_error(rule, "free_value", nil)
    end

    if invalid.free_value then
        util_imgui.tooltip(invalid.free_value)
    end

    imgui.push_style_color(5, invalid.free_value and color.with_alpha(mod_enum.colors.bad) or 0)
    imgui.end_rect(0, 2)
    imgui.pop_style_color(1)

    util_imgui.spacer_x(4)

    imgui.begin_rect()

    if manager:draw_option(rule_path) then
        changed = true
        op.bind.set_condition_error(rule, "free_value2", nil)
    end

    if invalid.free_value2 then
        util_imgui.tooltip(invalid.free_value)
    end

    imgui.push_style_color(5, invalid.free_value2 and color.with_alpha(mod_enum.colors.bad) or 0)
    imgui.end_rect(0, 2)
    imgui.pop_style_color(1)

    util_imgui.end_disabled()

    return changed
end

---@param manager GuiCondManagerBase
---@param rule_path string
function this.draw_tooltip(manager, rule_path)
    util_imgui.tooltip_custom(function()
        --FIXME: there should be less silly way of doing this no ???
        util_imgui.spacer(0, 3)
        util_imgui.spacer(2, 0)
        imgui.same_line()
        util_imgui.adjust_pos(-7)
        imgui.begin_group()

        util_imgui.begin_disabled(true)
        imgui.push_item_width(-1)

        this.draw_manager_target(manager, rule_path)

        local cond_key = rule_path .. ".conditions"
        local i = 1
        ---@diagnostic disable-next-line: no-unknown
        for j, _ in ipairs(config:get(cond_key)) do
            local key = string.format("%s.int:%s", cond_key, j)
            -- skip empty sets
            if not util_table.empty(config:get(key)) then
                if i > 1 then
                    util_imgui.separator_text_centered(config.lang:tr("misc.text_or"))
                elseif i == 1 then
                    util_imgui.adjust_pos(0, -2)
                end

                this.draw_conditions(manager, string.format("%s.int:%s", cond_key, j), true)
                i = i + 1
            end
        end

        imgui.pop_item_width()
        util_imgui.end_disabled()

        imgui.end_group()
        util_imgui.adjust_pos(0, i == 1 and -1 or -3)
        util_imgui.spacer(0, 1)
    end, nil, nil, nil, util_imgui.scale_w_font_size(300))
end

return this
