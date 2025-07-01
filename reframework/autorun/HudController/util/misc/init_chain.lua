---@class (exact) InitChain
---@field chain (fun(): boolean)[]
---@field ok boolean
---@field protected _progress table<fun(): boolean, boolean>

---@class InitChain
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param ... fun(): boolean
---@return InitChain
function this:new(...)
    local o = {
        chain = { ... },
        ok = false,
        _progress = {},
    }
    setmetatable(o, self)
    ---@cast o InitChain
    return o
end

---@return boolean
function this:init()
    if self.ok then
        return true
    end

    for i = 1, #self.chain do
        local f = self.chain[i]
        if self._progress[f] then
            goto continue
        end

        if not f() then
            return false
        end

        local info = debug.getinfo(f, "S")
        log.debug(string.format("%s initialized.", info.source))
        self._progress[f] = true
        ::continue::
    end

    self.ok = true
    return true
end

return this
