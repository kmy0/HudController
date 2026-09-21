---@class GuiKeyManagerBase
---@field manager ModBindManager
---@field base_bind ModBind
---@field config_key string

local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local set = require("HudController.gui.set")
local util_table = require("HudController.util.misc.table")

---@class GuiKeyManagerBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param manager ModBindManager
---@param config_key string
---@return GuiKeyManagerBase
function this:new(manager, config_key)
    local o = {
        manager = manager,
        config_key = config_key,
    }

    setmetatable(o, self)
    ---@cast o GuiKeyManagerBase
    return o
end

---@return boolean
function this:draw_target()
    return false
end

---@return boolean
function this:draw_action()
    return set:combo_filter(
        "##bind_action_type_combo",
        "__temp.combo_action_type",
        cd.combo.bind_action_type
    )
end

---@param bind ModBind
---@return string
function this:get_bind_name(bind)
    return bind.name_display
end

---@return boolean
function this:draw_trigger()
    return set:combo_filter(
        "##bind_trigger_type_combo",
        "__temp.combo_trigger_type",
        cd.combo.bind_trigger_type
    )
end

---@return boolean
function this:draw_option()
    return false
end

---@return boolean
function this:empty()
    return util_table.empty(self.manager.binds)
end

---@param set_default boolean?
---@return BindBase
---@diagnostic disable-next-line: unused-local
function this:make_base_bind(set_default)
    return self.base_bind
end

---@return boolean
function this:is_disabled()
    return false
end

---@param bind_base ModBindBase
function this:register(bind_base)
    local b = util_table.merge(bind_base, self.base_bind)
    ---@diagnostic disable-next-line: param-type-mismatch
    self.manager:register(b)
    config:set(self.config_key, self.manager:get_base_binds())
    self:make_base_bind()
end

---@param bind_base ModBindBase
---@return string?
function this:is_collision(bind_base)
    local b = util_table.merge(bind_base, self.base_bind)
    local is_collision, collision = self.manager:is_collision(b)
    if is_collision then
        ---@cast collision ModBind
        return self:get_bind_name(collision)
    end
end

return this
