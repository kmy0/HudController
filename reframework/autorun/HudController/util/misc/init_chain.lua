---@class (exact) InitChain
---@field chain (fun(): boolean)[]
---@field ok boolean
---@field protected _progress table<fun(): boolean, boolean>
local timer = require("HudController.util.misc.timer")
local util_misc = require("HudController.util.misc.util")

---@class InitChain
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

local retry_timer = timer.new("init_retry_timer", 3, nil, true)

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

    if not retry_timer:update() then
        return false
    end

    for i = 1, #self.chain do
        local f = self.chain[i]
        if self._progress[f] then
            goto continue
        end

        local fail = false
        util_misc.try(function()
            if not f() then
                fail = true
                return
            end

            local info = debug.getinfo(f, "S")
            self._progress[f] = true
        end, function(err)
            fail = true
        end)

        if fail then
            retry_timer:restart()
            return false
        end

        ::continue::
    end

    self.ok = true
    return true
end

return this
