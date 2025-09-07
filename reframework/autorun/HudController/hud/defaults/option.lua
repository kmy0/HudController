---@class (exact) OptionDefaultJsonCache : JsonCache

local config = require("HudController.config")
local json_cache = require("HudController.util.misc.json_cache")
local m = require("HudController.util.ref.methods")

---@class OptionDefaultJsonCache
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = json_cache })

---@return OptionDefaultJsonCache
function this:new()
    local o = json_cache.new(self, config.option_default_path)
    ---@cast o OptionDefaultJsonCache
    return o
end

---@param opt app.Option.ID
function this:check(opt)
    if self:get(opt) then
        return
    end

    self:set(opt, m.getOptionValue(opt))
end

return this
