---@class GuiOptionElemKeyManager : GuiKeyManagerBase
---@field manager ModBindManager

local base = require("HudController.gui.elements.menu_bar.bind.key.managers.base")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local def = require("HudController.data.option.element.init")
local set = require("HudController.gui.set")
local util_bind = require("HudController.gui.elements.menu_bar.bind.key.util")
local util_imgui = require("HudController.util.imgui.init")
local util_menubar = require("HudController.gui.elements.menu_bar.util")
local util_table = require("HudController.util.misc.table")

---@class GuiOptionElemKeyManager
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = base })

---@param manager ModBindManager
---@param config_key string
---@return GuiOptionElemKeyManager
function this:new(manager, config_key)
    local o = base.new(self, manager, config_key)
    setmetatable(o, self)
    ---@cast o GuiOptionElemKeyManager
    return o
end

---@return boolean
function this:draw_target()
    local values = util_table.transform(def.tree.nodes, function(value)
        return value.value.name
    end)

    return set:combo_popup_filter(
        "##bind_target_combo",
        "__temp.combo_target",
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
    )
end

---@return boolean
function this:draw_option()
    return util_bind.draw_option(function()
        local opt = def.get_opt(config:get("__temp.combo_target"))
        return opt:draw(nil, "__temp.option_value")
    end)
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

---@param set_default boolean?
---@return ModBind
function this:make_base_bind(set_default)
    if set_default then
        ---@type NamedElementOptionDef
        local opt
        local path = config:get("__temp.combo_target")

        if type(path) ~= "string" or not def.get_opt(path) then
            local node = def.tree.nodes[1].value
            opt = node.opt[1]
            config:set("__temp.combo_target", opt.path)
            path = opt.path
        end

        opt = def.get_opt(path)
        config:set("__temp.option_value", util_table.deep_copy(opt.default_value))
    end

    local opt = def.get_opt(config:get("__temp.combo_target"))
    self.base_bind = {
        action_type = cd.combo.bind_action_type:get_key(config:get("__temp.combo_action_type")),
        bound_value = {
            key = config:get("__temp.combo_target"),
            value = util_table.deep_copy(config:get("__temp.option_value")),
            free_value = opt.ctx_path,
        },
        trigger_repeat = cd.combo.bind_trigger_type:get_key(
            config:get("__temp.combo_trigger_type")
        ) == "REPEAT",
    }

    return self.base_bind
end

---@param bind ModBind<string, any>
---@return string
function this:get_bind_name(bind)
    local opt = def.get_opt(bind.bound_value.key)
    return string.format(
        "%s (%s)",
        table.concat(opt.name_path, " > "),
        opt:format(bind.bound_value.value)
    )
end

return this
