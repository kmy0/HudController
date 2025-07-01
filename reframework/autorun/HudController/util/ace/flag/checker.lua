---@class (exact) FlagChecker
---@field flags AceFlags
---@field state table<integer, boolean>
---@field type string
---@field protected _flag_max integer

local util_game = require("HudController.util.game")

---@class FlagChecker
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param flags AceFlags
---@return FlagChecker
function this:new(flags)
    local type = flags:get_type_definition() --[[@as RETypeDefinition]]
    local o = {
        flags = flags,
        state = {},
        type = type:get_full_name(),
        _flag_max = 0,
    }
    setmetatable(o, self)

    if type:is_a("ace.cSafeContinueFlag") then
        ---@cast flags ace.cSafeContinueFlag
        local bitset = flags._Flags
        o._flag_max = bitset:getMaxElement()
    elseif type:is_a("ace.cSafeContinueFlagGroup") then
        local enum = util_game.get_array_enum(flags._Groups)
        while enum:MoveNext() do
            local group = enum:get_Current() --[[@as ace.cSafeContinueFlagGroup.GROUP]]
            local bitset = group._Flags
            o._flag_max = o._flag_max + bitset:getMaxElement()
        end

        o._flag_max = o._flag_max - 1
    else
        ---@cast flags ace.BIT_FLAG
        o._flag_max = flags:getMaxElement()
    end

    return o
end

function this:check()
    local flags = self.flags
    for i = 0, self._flag_max do
        ---@type boolean
        local state
        if self.type == "ace.cSafeContinueFlagGroup" or self.type == "ace.cSafeContinueFlag" then
            ---@cast flags ace.cSafeContinueFlagGroup
            state = flags:check(i)
        else
            state = flags:call("isOn(System.Int32)", i)
        end

        if self.state[i] ~= nil and self.state[i] ~= state then
            print(i, state)
        end

        self.state[i] = state
    end
end

---@param bool boolean
function this:set_all(bool)
    for i = 0, self._flag_max do
        if bool then
            self.flags:on(i)
        else
            self.flags:off(i)
        end
    end
end

return this
