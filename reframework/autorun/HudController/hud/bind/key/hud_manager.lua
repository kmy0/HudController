---@class HudModBindManager : ModBindManager

local mod_bind_manager = require("HudController.hud.bind.key.manager")

---@class HudModBindManager
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = setmetatable(this, { __index = mod_bind_manager })

---@param name string?
---@param action fun(bind: Bind)
---@return HudModBindManager
function this:new(name, action)
    local o = mod_bind_manager.new(self, name, action)
    setmetatable(o, self)
    ---@cast o HudModBindManager
    o.action = action
    return o
end

---@param bind ModBindBase
---@return boolean, ModBind?
function this:is_collision(bind)
    for _, b in pairs(self.binds) do
        ---@diagnostic disable-next-line: param-type-mismatch
        if b.name == bind.name then
            return true, b
        end
    end

    return false
end

return this
