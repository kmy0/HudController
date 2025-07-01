---@class Separator
---@field ordered_keys string[]
---@field protected _count integer

local config = require("HudController.config")

local this = {}

---@class Separator
local Separator = {}
---@diagnostic disable-next-line: inject-field
Separator.__index = Separator

---@param ordered_keys any
---@return Separator
function Separator:new(ordered_keys)
    local o = {
        ordered_keys = ordered_keys,
        _count = -1,
    }
    setmetatable(o, self)
    return o
end

---@param t table<string, any>
function Separator:refresh(t)
    self._count = -1
    for i = 1, #self.ordered_keys do
        if t[self.ordered_keys[i]] ~= nil then
            self._count = self._count + 1
        end
    end
end

function Separator:has_separators()
    return self._count > 0
end

function Separator:draw()
    if self:has_separators() then
        imgui.separator()
        self._count = self._count - 1
    end
end

---@param key string
---@param ... string
---@return string
function this.tr(key, ...)
    local suffix = { ... }
    table.insert(suffix, key)
    return string.format("%s##%s", config.lang.tr(key), table.concat(suffix, "_"))
end

this.separator = Separator
return this
