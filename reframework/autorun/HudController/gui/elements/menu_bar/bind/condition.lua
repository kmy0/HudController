local bind_condition = require("HudController.hud.bind_condition.init")
local config = require("HudController.config.init")
local drag_util = require("HudController.gui.drag")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_table = require("HudController.util.misc.table")

local set = state.set
local drag = drag_util:new()

local this = {}

---@param config_mod ModSettings
local function draw_add_set_button(config_mod)
    if imgui.button(util_gui.tr("menu.bind.condition.button_add_new_condition")) then
        table.insert(
            config_mod.bind.condition.hud,
            bind_condition.new_condition_set(config_mod.hud[1])
        )
        config:save()
    end

    util_imgui.tooltip(config.lang:tr("menu.bind.condition.tooltip_add_new_condition"), true)

    if not util_table.empty(config_mod.bind.condition.hud) then
        imgui.separator()
    end
end

---@param cond_set ConditionSetConfig
---@param config_key string
---@return string
local function get_condition_summary(cond_set, config_key)
    local text = {}

    for j, cond in ipairs(cond_set.conditions) do
        local cond_class = bind_condition.conditions[cond.class]
        if not cond_class then
            goto continue
        end

        local str = cond_class:get_display_name()

        if cond_class:has_custom_options() then
            str = cond_class:get_selected_option_string()
        elseif cond_class.options then
            local index = config:get(
                string.format("%s.conditions.int:%s.%s", config_key, j, "combo")
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

---@param i integer
---@param cond_set ConditionSetConfig
---@param config_key string
local function draw_collapse_button(i, cond_set, config_key)
    if imgui.arrow_button("cond_set_collapse" .. i, cond_set.collapsed and 1 or 3) then
        cond_set.collapsed = not cond_set.collapsed
    end

    if cond_set.collapsed then
        util_imgui.tooltip(get_condition_summary(cond_set, config_key))
    end
end

---@param i integer
---@param set_remove integer[]
---@return boolean
local function draw_set_actions(i, set_remove)
    imgui.same_line()

    if imgui.button(util_gui.tr("menu.bind.condition.button_remove", "hud_condition", i)) then
        table.insert(set_remove, i)
    end

    imgui.same_line()

    if imgui.button(util_gui.tr("menu.bind.condition.button_duplicate", "hud_condition", i)) then
        return true
    end

    return false
end

---@param i integer
---@param cond_set ConditionSetConfig
---@param config_key string
---@param config_mod ModSettings
local function draw_profile_selector(i, cond_set, config_key, config_mod)
    imgui.same_line()
    imgui.push_item_width(util_gui.get_item_size())

    local combo_key = string.format("%s.%s", config_key, "combo_profile")
    if
        set:combo(
            util_gui.tr("menu.bind.condition.combo_profile", i),
            combo_key,
            state.combo.hud.values
        )
    then
        cond_set.key = config_mod.hud[config:get(combo_key)].key
        config:save()
    end

    imgui.pop_item_width()

    imgui.same_line()
    imgui.invisible_button("i_button1" .. i, { 0, 0 })
end

---@param config_key string
local function advance_condition_combo(config_key)
    local combo = state.combo.condition
    local combo_key = string.format("%s.%s", config_key, "combo_condition")
    local index = config:get(combo_key) --[[@as integer]]

    index = index + 1
    if index > combo:size() then
        index = 1
    end

    config:set(combo_key, index)
end

---@param cond_set ConditionSetConfig
---@param config_key string
local function add_selected_condition(cond_set, config_key)
    local combo = state.combo.condition
    local combo_key = string.format("%s.%s", config_key, "combo_condition")
    local index = config:get(combo_key) --[[@as integer]]
    local cond_key = combo:get_key(index) --[[@as string]]

    if
        not util_table.any(cond_set.conditions, function(_, value)
            return cond_key == value.class
        end)
    then
        table.insert(cond_set.conditions, bind_condition.conditions[cond_key]:new_config())
        config:save()
    end

    advance_condition_combo(config_key)
end

---@param i integer
---@param cond_set ConditionSetConfig
---@param config_key string
local function draw_condition_selector(i, cond_set, config_key)
    imgui.push_item_width(util_gui.get_item_size())

    set:combo(
        "##conditions." .. i,
        string.format("%s.%s", config_key, "combo_condition"),
        state.combo.condition.values
    )

    imgui.pop_item_width()
    imgui.same_line()

    local combo = state.combo.condition
    imgui.begin_disabled(combo:size() == #cond_set.conditions)

    if imgui.button(util_gui.tr("menu.bind.condition.button_add", "condition", i)) then
        add_selected_condition(cond_set, config_key)
    end

    imgui.end_disabled()
end

---@param i integer
---@param config_mod ModSettings
---@return boolean
local function is_set_passing(i, config_mod)
    return config_mod.bind.condition.highlight_pass
        and bind_condition.passing_sets[i]
        and bind_condition.passing_sets[i].pass
end

---@param i integer
---@param j integer
---@param config_mod ModSettings
---@return boolean
local function is_condition_passing(i, j, config_mod)
    local passing_set = bind_condition.passing_sets[i]

    return config_mod.bind.condition.highlight_pass
        and passing_set
        and passing_set.conditions
        and passing_set.conditions[j]
end

---@param i integer
---@param j integer
---@param cond ConditionConfigBase
---@param config_key string
---@param cond_remove integer[]
---@param config_mod ModSettings
local function draw_condition_row(i, j, cond, config_key, cond_remove, config_mod)
    local cond_class = bind_condition.conditions[cond.class]
    if not cond_class then
        return
    end

    imgui.table_next_row()
    imgui.table_set_column_index(0)
    imgui.begin_rect()

    if imgui.button(util_gui.tr("menu.bind.condition.button_remove", "hud_condition", i, j)) then
        table.insert(cond_remove, j)
    end

    imgui.table_set_column_index(1)
    imgui.text(cond_class:get_display_name())

    imgui.table_set_column_index(2)

    if cond_class:has_custom_options() then
        cond_class:draw_options()
    elseif cond_class.options then
        imgui.push_item_width(util_gui.get_item_size())

        set:combo(
            string.format("##%s.%s.%s", "cond_opt", i, j),
            string.format("%s.conditions.int:%s.%s", config_key, j, "combo"),
            state.bind_condition_options[cond.class].values
        )

        imgui.pop_item_width()
    else
        imgui.invisible_button("i_button3" .. i .. j, { 200, 0 })
    end

    imgui.push_style_color(5, is_condition_passing(i, j, config_mod) and 0xff3eb231 or 0)
    imgui.end_rect(1, 0)
    imgui.pop_style_color(1)
end

---@param i integer
---@param cond_set ConditionSetConfig
---@param config_key string
---@param config_mod ModSettings
local function draw_conditions(i, cond_set, config_key, config_mod)
    if util_table.empty(cond_set.conditions) then
        imgui.text(config.lang:tr("menu.bind.condition.text_no_condition"))
        return
    end

    if not imgui.begin_table("conditions_" .. i, 3, 1 << 9) then
        return
    end

    ---@type integer[]
    local cond_remove = {}

    for j, cond in ipairs(cond_set.conditions) do
        draw_condition_row(i, j, cond, config_key, cond_remove, config_mod)
    end

    imgui.end_table()

    if not util_table.empty(cond_remove) then
        cond_set.conditions = util_table.filter_array(cond_set.conditions, function(key, _)
            return not util_table.contains(cond_remove, key)
        end)

        config:save()
    end
end

---@param i integer
---@param cond_set ConditionSetConfig
---@param config_key string
---@param config_mod ModSettings
local function draw_set_contents(i, cond_set, config_key, config_mod)
    if cond_set.collapsed then
        return
    end

    imgui.separator()

    draw_condition_selector(i, cond_set, config_key)

    if not util_table.empty(cond_set.conditions) then
        imgui.separator()
    end

    draw_conditions(i, cond_set, config_key, config_mod)
end

---@param i integer
---@param cond_set ConditionSetConfig
---@param set_remove integer[]
---@param config_mod ModSettings
---@return ConditionSetConfig?
local function draw_condition_set(i, cond_set, set_remove, config_mod)
    local config_key = "mod.bind.condition.hud.int:" .. i
    cond_set.conditions = cond_set.conditions or {}

    imgui.begin_rect()
    imgui.indent(5)

    util_imgui.spacer(0, 5)

    drag:draw_drag_button(tostring(i), cond_set)
    imgui.same_line()

    draw_collapse_button(i, cond_set, config_key)

    local duplicate = draw_set_actions(i, set_remove)

    draw_profile_selector(i, cond_set, config_key, config_mod)
    draw_set_contents(i, cond_set, config_key, config_mod)

    imgui.invisible_button("i_button2" .. i, { 0, 1 })
    imgui.unindent(5)

    imgui.push_style_color(5, is_set_passing(i, config_mod) and 0xff3eb231 or 0xff6a6a6a)
    imgui.end_rect(0, 0)
    imgui.pop_style_color(1)

    imgui.indent(5)
    drag:check_drag_pos(cond_set, -5, -5)
    imgui.unindent(5)

    util_imgui.spacer(0, 5)

    if duplicate then
        return cond_set
    end
end

---@param config_mod ModSettings
local function handle_drag(config_mod)
    if drag:is_released() then
        config:save()
    elseif drag:is_drag() then
        util_table.sort(config_mod.bind.condition.hud, function(a, b)
            return drag.item_pos[a] < drag.item_pos[b]
        end)
    end
end

---@param config_mod ModSettings
---@param set_remove integer[]
local function remove_sets(config_mod, set_remove)
    if util_table.empty(set_remove) then
        return
    end

    config_mod.bind.condition.hud = util_table.filter_array(
        config_mod.bind.condition.hud,
        function(key, _)
            return not util_table.contains(set_remove, key)
        end
    )

    config:save()
end

---@param config_mod ModSettings
---@param duplicate ConditionSetConfig?
local function duplicate_set(config_mod, duplicate)
    if not duplicate then
        return
    end

    table.insert(config_mod.bind.condition.hud, util_table.deep_copy(duplicate))
end

local function draw_condition_bind_menu()
    imgui.spacing()
    imgui.indent(2)

    local config_mod = config.current.mod

    imgui.begin_disabled(util_table.empty(config_mod.hud))

    draw_add_set_button(config_mod)

    drag:clear()
    imgui.indent(1)

    ---@type integer[]
    local set_remove = {}
    ---@type ConditionSetConfig?
    local duplicate

    for i, cond_set in ipairs(config_mod.bind.condition.hud) do
        local duplicated = draw_condition_set(i, cond_set, set_remove, config_mod)

        if duplicated then
            duplicate = duplicated
        end
    end

    imgui.unindent(1)

    handle_drag(config_mod)
    remove_sets(config_mod, set_remove)
    duplicate_set(config_mod, duplicate)

    imgui.end_disabled()

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    util_menubar.draw_menu(util_gui.tr("menu.bind.condition.name"), draw_condition_bind_menu)
end

return this
