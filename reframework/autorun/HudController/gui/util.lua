---@class Separator
---@field ordered_keys string[]
---@field protected _count integer
---@field protected _start_count integer

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
        _start_count = -1,
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
    self._start_count = self._count
end

function Separator:has_separators()
    return self._count > 0
end

function Separator:had_separators()
    return self._start_count > -1
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

    local int = key:match("%d+")
    ---@type string
    local msg
    if int then
        key = string.gsub(key, "%d", "")
        msg = string.format("%s %s", config.lang.tr(key), int)
    else
        msg = config.lang.tr(key)
    end

    return string.format("%s##%s", msg, table.concat(suffix, "_"))
end

---@param key string
---@return string
function this.tr_int(key)
    local int = key:match("%d+")
    ---@type string
    local msg
    if int then
        key = string.gsub(key, "%d", "")
        msg = string.format("%s %s", config.lang.tr(key), int)
    else
        msg = config.lang.tr(key)
    end

    return msg
end

this.separator = Separator
return this
