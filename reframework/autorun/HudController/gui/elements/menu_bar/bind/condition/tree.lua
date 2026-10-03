---@class ConditionTreeStyle
---@field indent number
---@field normal_color integer
---@field selected_color integer
---@field triggering_color integer
---@field invalid_color integer
---@field line_thickness number
---@field node_gap number
---@field summaries table<ConditionTreeNode, ConditionTreeSummary>

---@class ConditionTreeNode
---@field id string? Stable ID for collapse state when sibling order changes.
---@field name string
---@field config_key string
---@field selected boolean
---@field selected_edit boolean
---@field triggering boolean
---@field invalid boolean
---@field tooltip fun()?
---@field disabled boolean
---@field children ConditionTreeNode[]?
---@field type BindCondType?
---@field is_dummy boolean

---@class ConditionTreeNodePos
---@field left number
---@field right number
---@field top number
---@field bottom number
---@field center_x number
---@field center_y number

---@class ConditionTreeState
---@field selected boolean
---@field triggering boolean
---@field invalid boolean

---@class ConditionTreeChild
---@field node ConditionTreeNodePos
---@field state ConditionTreeState

---@class ConditionTreeSummary
---@field state ConditionTreeState
---@field count integer

local color = require("HudController.util.imgui.color")
local config = require("HudController.config.init")
local managers = require("HudController.gui.elements.menu_bar.bind.condition.managers.init")
local util_imgui = require("HudController.util.imgui.init")
local util_table = require("HudController.util.misc.table")
local mod_enum = require("HudController.data.mod").enum
local cond_draw = require("HudController.gui.elements.menu_bar.bind.condition.cond_draw")

local ROOT_KEY = "mod.bind.condition"

local this = {}
---@type table<string, boolean>
local collapsed_nodes = {}
local is_collapsed = false

---@param label string
---@param draw_fn fun(size: number[]): boolean
local function draw_button_node(label, draw_fn)
    local pos = imgui.get_cursor_screen_pos()
    local text_size = imgui.calc_text_size(label)
    local width = text_size.x + 8
    local height = text_size.y + 6
    local clicked = draw_fn({ width, height })

    return clicked,
        {
            left = pos.x,
            right = pos.x + width,
            top = pos.y,
            bottom = pos.y + height,
            center_x = pos.x + width / 2,
            center_y = pos.y + height / 2,
        }
end

---@param item ConditionTreeNode
---@param collapsed table<string, boolean>
---@param path string
---@param value boolean
local function set_all_collapsed(item, collapsed, path, value)
    local id = item.id or item.config_key or path

    if item.children and #item.children > 0 then
        collapsed[id] = value or nil

        for index, child in ipairs(item.children) do
            set_all_collapsed(child, collapsed, path .. "/" .. index, value)
        end
    end
end

---@param node ConditionTreeNode?
---@return ConditionTreeState
local function new_state(node)
    return {
        selected = node and node.selected or false,
        triggering = node and node.triggering or false,
        invalid = node and node.invalid or false,
    }
end

---@param dst ConditionTreeState
---@param src ConditionTreeState
local function merge_state(dst, src)
    dst.selected = dst.selected or src.selected
    dst.triggering = dst.triggering or src.triggering
    dst.invalid = dst.invalid or src.invalid
end

---@param state ConditionTreeState
---@param style ConditionTreeStyle
---@return integer
local function get_state_color(state, style)
    if state.invalid then
        return style.invalid_color
    end

    if state.selected then
        return style.selected_color
    end

    if state.triggering then
        return style.triggering_color
    end

    return style.normal_color
end

---@param parent ConditionTreeNodePos
---@param children ConditionTreeChild[]
---@param style ConditionTreeStyle
local function draw_connections(parent, children, style)
    if #children == 0 then
        return
    end

    ---@type ConditionTreeState[]
    local suffix_states = {}
    local dl = imgui.get_window_draw_list()
    local trunk_x = parent.center_x
    local accumulated = new_state()

    for i = #children, 1, -1 do
        local state = new_state()

        merge_state(state, accumulated)
        merge_state(state, children[i].state)

        suffix_states[i] = state
        accumulated = state
    end

    local start_y = parent.bottom + style.node_gap
    for i, child in ipairs(children) do
        local end_y = child.node.center_y

        if end_y > start_y then
            dl:add_line({
                trunk_x,
                start_y,
            }, {
                trunk_x,
                end_y,
            }, get_state_color(suffix_states[i], style), style.line_thickness)
        end

        dl:add_line({
            trunk_x,
            child.node.center_y,
        }, {
            child.node.left - style.node_gap,
            child.node.center_y,
        }, get_state_color(child.state, style), style.line_thickness)

        start_y = end_y
    end
end

---@param item ConditionTreeNode
---@param summaries table<ConditionTreeNode, ConditionTreeSummary>
---@return ConditionTreeSummary
local function summarize(item, summaries)
    local ret = { state = new_state(item), count = 0 }
    for _, child in ipairs(item.children or {}) do
        local child_summary = summarize(child, summaries)
        merge_state(ret.state, child_summary.state)
        ret.count = ret.count + child_summary.count + 1
    end
    summaries[item] = ret
    return ret
end

---@param item ConditionTreeNode
---@param style ConditionTreeStyle
---@param collapsed table<string, boolean>
---@param path string
---@return ConditionTreeNodePos, ConditionTreeState, string?
local function draw_node(item, style, collapsed, path)
    local id = item.id or path
    local summary = style.summaries[item]
    local has_children = item.children and not util_table.empty(item.children)
    local is_collapsed = has_children and collapsed[id] == true
    local size_label = string.format("%s (%d)", item.name, summary.count)
    local label = is_collapsed and size_label or item.name

    ---@type ConditionTreeNodePos
    local node
    ---@type string?
    local ret
    ---@type boolean
    local clicked

    imgui.begin_rect()

    if not item.is_dummy then
        util_imgui.begin_disabled(item.disabled)

        clicked, node = draw_button_node(size_label, function(size)
            return util_imgui.draw_sel_button(
                string.format("%s##%s", label, id),
                item.selected,
                size
            )
        end)

        if clicked then
            ret = item.config_key
        end

        util_imgui.end_disabled()
    else
        clicked, node = draw_button_node(size_label, function(size)
            imgui.push_style_var(imgui.ImGuiStyleVar.ButtonTextAlign, Vector2f.new(0, 0.5))
            local ret = imgui.button(string.format("%s##dummy|%s", label, path), size)
            imgui.pop_style_var(1)
            return ret
        end)

        if clicked then
            config:set(item.config_key .. ".cond_type_selection", item.type)
            ret = item.config_key
        end
    end

    imgui.push_style_color(
        5,
        (item.selected_edit and style.selected_color)
            or (item.invalid and style.invalid_color)
            or (item.triggering and style.triggering_color)
            or 0
    )
    imgui.end_rect(0, 2)
    imgui.pop_style_color(1)

    if item.tooltip then
        item.tooltip()
    end

    if has_children then
        imgui.same_line()
        util_imgui.adjust_pos(-8)
        if imgui.arrow_button("##condition_tree_toggle_" .. id, is_collapsed and 1 or 3) then
            collapsed[id] = not collapsed[id]
            is_collapsed = collapsed[id] == true
        end
    end

    if has_children and not is_collapsed then
        ---@type ConditionTreeChild[]
        local children = {}
        local child_indent =
            math.max(style.indent, node.center_x - node.left + util_imgui.scale_w_font_size(8))

        imgui.indent(child_indent)
        for index, child in ipairs(item.children) do
            local child_node, child_state, child_ret =
                draw_node(child, style, collapsed, path .. "/" .. index)
            ret = child_ret or ret
            table.insert(children, { node = child_node, state = child_state })
        end
        draw_connections(node, children, style)
        imgui.unindent(child_indent)
    end

    return node, summary.state, ret
end

---@param path string
---@return ConditionTreeNode
function this.make_tree(path)
    ---@param sets table<BindCondType, ConditionBindRuleSet>?
    ---@param parent_path string
    ---@param selection BindCondType
    ---@return ConditionTreeNode[]
    local function build_sets(sets, parent_path, selection)
        ---@type ConditionTreeNode[]
        local nodes = {}
        if not sets then
            return nodes
        end

        local keys = util_table.sort(util_table.keys(sets))
        for _, cond_type in ipairs(keys) do
            local manager = managers[cond_type]
            local rule_set = sets[cond_type]

            if rule_set then
                local set_path = string.format("%s.sets.%s", parent_path, cond_type)
                ---@type ConditionTreeNode[]
                local rules = {}

                for rule_index, rule in ipairs(rule_set.rules or {}) do
                    local rule_path = string.format("%s.rules.int:%d", set_path, rule_index)
                    table.insert(rules, {
                        name = manager:get_rule_name(rule_path, false),
                        config_key = rule_path,
                        selected = path == rule_path,
                        triggering = manager:is_rule_triggering(rule_path),
                        invalid = manager:is_rule_invalid(rule_path),
                        children = build_sets(rule.sets, rule_path, rule.cond_type_selection),
                        selected_edit = parent_path == path
                            and rule_set.selection == rule_index
                            and cond_type == selection,
                        tooltip = function()
                            cond_draw.draw_tooltip(manager, rule_path)
                        end,
                        disabled = not util_table.any(rule.conditions, function(_, value)
                            return not util_table.empty(value)
                        end),
                        is_dummy = false,
                    })
                end

                table.insert(nodes, {
                    name = config.lang:tr("menu.bind.condition.bind_cond_type." .. cond_type),
                    type = cond_type,
                    config_key = parent_path,
                    children = rules,
                    is_dummy = true,
                })
            end
        end

        return nodes
    end

    return {
        name = config.lang:tr("misc.text_root"),
        config_key = ROOT_KEY,
        selected = path == ROOT_KEY,
        children = build_sets(
            config.current.mod.bind.condition.sets,
            ROOT_KEY,
            config.current.mod.bind.condition.cond_type_selection
        ),
        invalid = false,
        triggering = false,
        selected_edit = false,
        disabled = false,
        is_dummy = false,
    }
end

---@param root ConditionTreeNode
---@param collapsed table<string, boolean>?
---@return string?
function this.draw(root, collapsed)
    collapsed = collapsed or collapsed_nodes
    ---@type string?
    local ret

    util_imgui.button_with_popup(config.lang:tr("menu.bind.condition.button_tree"), function()
        util_imgui.even_popup_border(function()
            local x_size = util_imgui.get_max_button_size(
                config.lang:tr("menu.bind.condition.button_expand_all"),
                config.lang:tr("menu.bind.condition.button_collapse_all")
            )

            if
                imgui.button(
                    is_collapsed and config.lang:tr("menu.bind.condition.button_expand_all")
                        or config.lang:tr("menu.bind.condition.button_collapse_all"),
                    { x_size, 0 }
                )
            then
                is_collapsed = not is_collapsed

                set_all_collapsed(
                    root,
                    collapsed,
                    root.id or root.config_key or "root",
                    is_collapsed
                )
            end

            ---@type ConditionTreeStyle
            local style = {
                indent = util_imgui.scale_w_font_size(24),
                normal_color = color.with_alpha(0xff8a7668),
                selected_color = color.with_alpha(0xffd47b35),
                triggering_color = color.with_alpha(mod_enum.colors.good),
                invalid_color = color.with_alpha(mod_enum.colors.bad),
                line_thickness = 2,
                node_gap = 2,
                summaries = {},
            }
            summarize(root, style.summaries)

            imgui.indent(2)
            local _, _, selected_key =
                draw_node(root, style, collapsed, root.id or root.config_key or "root")
            imgui.unindent(2)
            ret = selected_key
        end)
    end, util_imgui.scale_w_font_size(262), util_imgui.scale_w_font_size(262))

    return ret
end

return this
