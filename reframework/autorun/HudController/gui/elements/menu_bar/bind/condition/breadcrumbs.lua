---@class ConditionRuleCrumb
---@field config_key string
---@field name string
---@field siblings ConditionBindRuleSet
---@field prefix string
---@field rule_index integer
---@field rule ConditionBindRuleConfig
---@field cond_type BindCondType
---@field tooltip fun()?
---@field children ConditionRuleCrumb[]

local cond_draw = require("HudController.gui.elements.menu_bar.bind.condition.cond_draw")
local config = require("HudController.config.init")
local managers = require("HudController.gui.elements.menu_bar.bind.condition.managers.init")
local util_imgui = require("HudController.util.imgui.init")
local util_table = require("HudController.util.misc.table")

local ROOT_KEY = "mod.bind.condition"

local this = {}

---@param path string
---@return ConditionRuleCrumb[]
function this.make_breadcrumbs(path)
    ---@type ConditionRuleCrumb[]
    local ret = {
        ---@diagnostic disable-next-line: missing-fields
        {
            config_key = ROOT_KEY,
            name = config.lang:tr("misc.text_root"),
        },
    }

    local sets = config.current.mod.bind.condition.sets
    local pos = #ROOT_KEY + 1

    ---@param key string
    ---@param rule_set ConditionBindRuleSet
    ---@param cond_type BindCondType
    ---@param rule_index integer
    ---@return ConditionRuleCrumb
    local function make_crumb(key, rule_set, cond_type, rule_index)
        local rule = rule_set.rules[rule_index]
        local manager = managers[cond_type]
        local prefix = key:match("^(.-)%.rules%.int:%d+$")

        return {
            config_key = key,
            name = manager:get_rule_name(key),
            siblings = rule_set,
            prefix = prefix,
            rule_index = rule_index,
            rule = rule,
            cond_type = cond_type,
            tooltip = function()
                cond_draw.draw_tooltip(manager, key)
            end,
            children = {},
        }
    end

    while true do
        local start_pos, end_pos, type_str, rule_str =
            string.find(path, "%.sets%.([^%.]+)%.rules%.int:(%d+)", pos)

        if not start_pos then
            break
        end

        ---@type BindCondType
        local cond_type = type_str
        local rule_index = tonumber(rule_str)
        if not rule_index then
            break
        end

        local rule_set = sets[cond_type]
        if not rule_set then
            break
        end

        local rule = rule_set.rules[rule_index]
        if not rule then
            break
        end

        local key = path:sub(1, end_pos)
        table.insert(ret, make_crumb(key, rule_set, cond_type, rule_index))

        sets = rule.sets
        pos = end_pos + 1
    end

    if sets then
        local last = ret[#ret]
        last.children = {}

        for cond_type, rule_set in pairs(sets) do
            for rule_index, rule in pairs(rule_set.rules) do
                if
                    util_table.any(rule.conditions, function(_, value)
                        return not util_table.empty(value)
                    end)
                then
                    local key = string.format(
                        "%s.sets.%s.rules.int:%s",
                        last.config_key,
                        cond_type,
                        rule_index
                    )

                    table.insert(last.children, make_crumb(key, rule_set, cond_type, rule_index))
                end
            end
        end
    end

    return ret
end

---@param crumbs ConditionRuleCrumb[]
---@return string?
function this.draw(crumbs)
    ---@type string?
    local ret

    local last = crumbs[#crumbs]
    local available_width = util_imgui.get_available_width()
    local ellipsis = config.lang:tr("misc.text_ellipsis")
    local scale = config.lang.font_size / 13
    local padding = 8 * scale
    local spacing = 8 * scale

    local function button_width(text)
        return imgui.calc_text_size(text).x + padding
    end

    local separator_width = button_width("A")

    local function path_width(first, overflow)
        local width = button_width(overflow and ellipsis or crumbs[first].name)
        if not overflow then
            first = first + 1
        end

        for i = first, #crumbs do
            width = width + spacing * 2 + separator_width + button_width(crumbs[i].name)
        end

        return width + (not util_table.empty(last.children) and spacing + separator_width or 0)
    end

    local first_visible = 1
    if #crumbs > 1 and path_width(1, false) > available_width then
        first_visible = #crumbs

        for i = 2, #crumbs do
            if path_width(i, true) <= available_width then
                first_visible = i
                break
            end
        end
    end

    ---@param crumb ConditionRuleCrumb
    local function menu_item(crumb)
        if
            util_imgui.menu_item(
                string.format("%s##cond_crumb_overflow|%s", crumb.name, crumb.config_key),
                false,
                nil,
                true
            )
        then
            ret = crumb.config_key
        end

        if crumb.tooltip then
            crumb.tooltip()
        end
    end

    if first_visible > 1 then
        util_imgui.button_with_popup(ellipsis .. "##cond_crumbs|overflow", function()
            for i = 1, first_visible - 1 do
                menu_item(crumbs[i])
            end
        end)
    end

    for i = first_visible, #crumbs do
        local crumb = crumbs[i]

        if i > 1 then
            imgui.same_line()

            util_imgui.arrow_button_with_popup("##cond_crumbs|" .. i, function()
                local rules = crumb.siblings and crumb.siblings.rules
                if not rules or not crumb.prefix then
                    return
                end

                local count = #rules
                for index in pairs(rules) do
                    if count == 1 or index ~= crumb.rule_index then
                        menu_item(crumb)
                    end
                end
            end, 3, 1)

            imgui.same_line()
        end

        if
            util_imgui.draw_sel_button(
                string.format("%s##breadcrumb_%d", crumb.name, i),
                i == #crumbs
            )
        then
            ret = crumb.config_key
        end

        if crumb.tooltip then
            crumb.tooltip()
        end
    end

    if not util_table.empty(last.children) then
        imgui.same_line()

        util_imgui.arrow_button_with_popup("##cond_crumbs|last", function()
            for _, crumb in ipairs(last.children) do
                menu_item(crumb)
            end
        end, 3, 1)
    end

    return ret
end

return this
