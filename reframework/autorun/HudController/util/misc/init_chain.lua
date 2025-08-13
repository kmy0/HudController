---@class (exact) InitChain
---@field chain (fun(): boolean)[]
---@field ok boolean
---@field retry_timer Timer
---@field max_retries integer
---@field failed boolean
---@field name string
---@field protected _retries table<integer, integer>
---@field protected _progress table<fun(): boolean, boolean>

local logger = require("HudController.util.misc.logger").g
local timer = require("HudController.util.misc.timer")
local util_misc = require("HudController.util.misc.util")

---@class InitChain
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param name string
---@param ... fun(): boolean
---@return InitChain
function this:new(name, ...)
    local o = {
        chain = { ... },
        ok = false,
        name = name,
        _progress = {},
        _retries = {},
        failed = false,
        max_retries = 10,
    }
    setmetatable(o, self)
    ---@cast o InitChain

    o.retry_timer = timer.new("retry_timer_" .. tostring(o), 3, nil, true)
    return o
end

---@return boolean
function this:init()
    if self.ok then
        return true
    end

    if self.failed then
        return false
    end

    if not self.retry_timer:update() then
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
            logger:info(string.format("%s initialized.", info.source))
            self._progress[f] = true
        end, function(err)
            fail = true
            logger:error(string.format("InitChain (%s) func at index %s threw: %s", self.name, i, err))
        end)

        if fail then
            if self._retries[i] then
                self._retries[i] = self._retries[i] + 1
            else
                self._retries[i] = 0
            end

            if self._retries[i] >= self.max_retries then
                logger:error(string.format("InitChain (%s) func at index %s failed", self.name, i))
                self.failed = true
            end

            self.retry_timer:restart()
            return false
        end

        ::continue::
    end

    self.ok = true
    return true
end

return this
