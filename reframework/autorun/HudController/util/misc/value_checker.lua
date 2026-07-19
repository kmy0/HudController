---@class ValueCheker
---@field value any
---@field default_value any
---@field eval_fn (fun(old_value: any, new_value: any): boolean)?

---@class ValueCheker
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param default_value any
---@param eval_fn (fun(old_value: any, new_value: any): boolean)?
---@return ValueCheker
function this:new(default_value, eval_fn)
    local o = {
        value = default_value,
        eval_fn = eval_fn,
    }

    setmetatable(o, self)
    ---@cast o ValueCheker

    return o
end

---@param new_value any
---@return boolean
function this:is_changed(new_value)
    local ret = self.value ~= new_value
        and (not self.eval_fn or self.eval_fn(self.value, new_value))
    self.value = new_value
    return ret
end

function this:reset()
    self.value = self.default_value
end

return this
