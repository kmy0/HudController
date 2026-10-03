local config = require("HudController.config.init")
local def = require("HudController.data.option.element.init")
local set = require("HudController.gui.set")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_table = require("HudController.util.misc.table")

local this = {}

---@param path string
---@return string
local function make_name(path)
    return table.concat(util_table.get_by_path(def.map, path).name_path, " > ")
end

---@param path string
---@return string
local function make_short_name(path)
    local opt = util_table.get_by_path(def.map, path) --[[@as NamedElementOptionDef]]
    local res = {}

    if #opt.name_path > 3 then
        table.insert(res, opt.name_path[1])
        table.insert(res, config.lang:tr("misc.text_ellipsis"))
        table.insert(res, opt.name_path[#opt.name_path - 1])
        table.insert(res, opt.name_path[#opt.name_path])
    else
        return make_name(path)
    end

    return table.concat(res, " > ")
end

---@return boolean
function this.draw(label, config_key)
    local values = util_table.transform(def.tree.nodes, function(value)
        return value.value.name
    end)

    return set:combo_popup_filter(label, config_key, values, function(query, value)
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
    end, function(value)
        return make_short_name(value)
    end, config.lang.font_size + 1)
end

return this
