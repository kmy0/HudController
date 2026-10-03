---@class OptionElemGuiCondManagerBase : GuiCondManagerBase

local base = require("HudController.gui.elements.menu_bar.bind.condition.managers.base")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local def = require("HudController.data.option.element.init")
local set = require("HudController.gui.set")
local util_bind = require("HudController.gui.elements.menu_bar.bind.condition.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local mod_enum = data.mod.enum

---@class OptionElemGuiCondManagerBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = base })

---@return OptionElemGuiCondManagerBase
function this:new()
    ---@type OptionElemGuiCondManagerBase
    return setmetatable(base.new(self), self)
end

---@param rule_path string
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:draw_target(rule_path)
    local values = util_table.transform(def.tree.nodes, function(value)
        return value.value.name
    end)
    local free_value_path = rule_path .. ".free_value"
    local changed = false

    if not config:get(free_value_path) then
        config:set(free_value_path, def.tree.nodes[1].leaves[1].path)
        changed = true
    end

    changed = set:combo_popup_filter(
        "##cond_target|" .. rule_path,
        free_value_path,
        values,
        function(query, value)
            def.tree:filter(query)
            ---@type string?
            local selected

            ---@param node TreeNode<BindElemOptNode, NamedElementOptionDef>
            local function draw_node(node)
                imgui.indent(2)
                util_menubar.draw_menu(node.value.name, function()
                    for _, leaf in ipairs(node.leaves) do
                        if util_imgui.menu_item(leaf.name, value == leaf.path) then
                            selected = leaf.path
                        end
                    end

                    for _, branch in ipairs(node.children) do
                        draw_node(branch)
                    end
                end)
                imgui.unindent(2)
            end

            for _, root in ipairs(def.tree.nodes) do
                draw_node(root)
            end

            return selected
        end,
        function(value)
            return self:make_short_name(value)
        end,
        config.lang.font_size + 1
    ) or changed

    if changed then
        local path = config:get(free_value_path)
        local opt = def.get_opt(path)
        config:set(rule_path .. ".free_value2", util_table.deep_copy(opt.default_value))
    end

    return changed
end

---@param path string
---@return string
function this:make_name(path)
    return table.concat(util_table.get_by_path(def.map, path).name_path, " > ")
end

---@param path string
---@return string
function this:make_short_name(path)
    local opt = util_table.get_by_path(def.map, path) --[[@as NamedElementOptionDef]]
    local res = {}

    if #opt.name_path > 3 then
        table.insert(res, opt.name_path[1])
        table.insert(res, config.lang:tr("misc.text_ellipsis"))
        table.insert(res, opt.name_path[#opt.name_path - 1])
        table.insert(res, opt.name_path[#opt.name_path])
    else
        return self:make_name(path)
    end

    return table.concat(res, " > ")
end

---@param rule_path string
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:draw_option(rule_path)
    local option_key = config:get(rule_path .. ".free_value")

    if not option_key then
        return false
    end

    local opt = def.get_opt(option_key)
    local config_key = string.format("%s.free_value2", rule_path)
    return util_bind.draw_option(config_key, function()
        return opt:draw("##user_opt" .. rule_path, config_key)
    end)
end

---@param rule_path string
---@param with_manager_name boolean?
---@return string
function this:get_rule_name(rule_path, with_manager_name)
    with_manager_name = with_manager_name == nil or with_manager_name
    local rule = config:get(rule_path) --[[@as ConditionBindRuleConfig]]
    local invalid = self:get_rule_invalid(rule_path)
    local opt = rule.free_value and def.get_opt(rule.free_value)
    local name = opt and config.lang:tr(opt.lang_key)

    ---@type string?
    local ret

    if not name or invalid.free_value then
        ret = config.lang:tr("misc.text_unknown")
    else
        ret = name

        ret = string.format("%s (%s)", ret, opt:format(rule.free_value2))
    end

    if with_manager_name then
        ret = string.format(
            "%s: %s",
            config.lang:tr(
                "menu.bind.condition.bind_cond_type." .. mod_enum.bind_cond_type.OPTION_ELEM
            ),
            ret
        )
    end

    return util_misc.trunc_string2(ret, util_imgui.scale_w_font_size(180))
end

return this
