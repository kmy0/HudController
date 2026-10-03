---@class GuiOptionElemKeyManager : GuiKeyManagerBase
---@field manager ModBindManager

local base = require("HudController.gui.elements.menu_bar.bind.key.managers.base")
local config = require("HudController.config.init")
local def = require("HudController.data.option.element.init")
local elm_opt_selector = require("HudController.gui.elements.menu_bar.bind.elem_opt_selector")
local util_bind = require("HudController.gui.elements.menu_bar.bind.key.util")
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
    return elm_opt_selector.draw("##bind_target_combo", "__temp.combo_target")
end

---@return boolean
function this:draw_option()
    return util_bind.draw_option(function()
        local opt = def.get_opt(config:get("__temp.combo_target"))
        return opt:draw(nil, "__temp.option_value")
    end)
end

function this:set_default()
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

---@param set_default boolean?
---@return BindBase
function this:make_base_bind(set_default)
    if set_default then
        self:set_default()
    end

    local opt = def.get_opt(config:get("__temp.combo_target"))
    return base.make_base_bind(self, {
        key = config:get("__temp.combo_target"),
        value = util_table.deep_copy(config:get("__temp.option_value")),
        free_value = opt.ctx_path,
    })
end

---@param bind ModBind<string, any>
---@return string
function this:get_bind_name(bind)
    if bind.invalid then
        return config.lang:tr("misc.text_unknown")
    end

    local opt = def.get_opt(bind.bound_value.key)
    return string.format(
        "%s (%s)",
        table.concat(opt.name_path, " > "),
        opt:format(bind.bound_value.value)
    )
end

return this
