---@class Migration
---@field version Version
---@field fns {[string]: fun(config: MainSettings)}

local version_base = require("HudController.util.misc.version_base")

---@class Migration
local this = {}
this.__index = this

---@param version_string string
---@return Migration
function this.new(version_string)
    local o = {
        version = version_base.new(version_string),
        fns = {},
    }

    return setmetatable(o, this) --[[@as Migration]]
end

---@param config MainSettings
function this:migrate(config)
    for _, f in pairs(self.fns) do
        f(config)
    end
end

return this
