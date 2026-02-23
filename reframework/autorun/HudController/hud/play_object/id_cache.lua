---@class (exact) GUIIdCache : Cache

local cache = require("HudController.util.misc.cache")
local util_game = require("HudController.util.game.init")

---@class GUIIdCache
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = cache })

function this:new()
    local o = cache.new(self)
    setmetatable(o, self)
    ---@cast o GUIIdCache
    return o
end

---@param ctrl via.gui.Control
---@param chain string[] | string
---@return string
local function make_key(ctrl, chain)
    return string.format("%s|%s", tostring(ctrl), tostring(chain))
end

---@param ctrl via.gui.Control
---@param chain string[] | string
---@param id_chain integer[]
function this:set(ctrl, chain, id_chain)
    local key = make_key(ctrl, chain)
    local id_array = util_game.lua_array_to_system_array(id_chain, "System.UInt32")
    cache.set(self, key, id_array)
end

---@param ctrl via.gui.Control
---@param chain string[] | string
---@return System.Array<System.UInt32>
function this:get(ctrl, chain)
    local key = make_key(ctrl, chain)
    return cache.get(self, key)
end

return this:new()
