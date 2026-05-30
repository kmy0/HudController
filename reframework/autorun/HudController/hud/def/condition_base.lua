---@class ConditionBase
---@field name string
---@field protected _instances ConditionBase[]

---@class ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
this._instances = setmetatable({}, { __mode = "v" })

---@param name string
---@return ConditionBase
function this:new(name)
    local o = {
        name = name,
    }
    setmetatable(o, self)
    ---@cast o ConditionBase
    table.insert(this._instances, o)
    return o
end

---@return boolean
function this:update()
    return false
end

function this:reset() end

function this.reset_all()
    for _, t in pairs(this._instances) do
        t:reset()
    end
end

return this
