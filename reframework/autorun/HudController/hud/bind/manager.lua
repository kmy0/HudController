---@class ModBindManager : BindManager
---@field action fun(bind: ModBind)

local bind_manager = require("HudController.util.game.bind.manager")
local util_table = require("HudController.util.misc.table")

---@class ModBindManager
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = setmetatable(this, { __index = bind_manager })

---@param name string?
---@param action fun(bind: Bind)
---@return ModBindManager
function this:new(name, action)
    local o = bind_manager.new(self, name)
    setmetatable(o, self)
    ---@cast o ModBindManager
    o.action = action
    return o
end

---@param binds ModBindBase[]
function this:load(binds)
    local res = util_table.deep_copy(binds) --[=[@as ModBind[]]=]
    for _, bind in pairs(res) do
        bind.action = function()
            self.action(bind)
        end
    end

    bind_manager.load(self, res)
end

---@param bind ModBind
---@return boolean, ModBindBase?
function this:register(bind)
    bind.action = function()
        self.action(bind)
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return bind_manager.register(self, bind)
end

---@param bind ModBind
function this:unregister(bind)
    self.binds = util_table.remove(self.binds --[==[@as ModBind[]]==], function(t, i, j)
        return self.binds[i].bound_value ~= bind.bound_value or self.binds[i].name ~= bind.name
    end)
    self.sorted = self:_sort_binds()
    self:_execute_on_data_changed_callback()
end

---@param bind ModBindBase
---@return boolean, ModBind?
function this:is_collision(bind)
    for _, b in pairs(self.binds) do
        if b.name == bind.name and b.bound_value == bind.bound_value then
            return true, b
        end
    end

    return false
end

return this
