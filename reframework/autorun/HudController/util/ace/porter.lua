---@class Porterutil
---@field porter_command table<app.PorterDef.COMMUNICATOR_COMMAND, string>
---@field porter_quest_interrupts string[]

local cache = require("HudController.util.misc.cache")
local s = require("HudController.util.ref.singletons")
local util_game = require("HudController.util.game")
local util_table = require("HudController.util.misc.table")

local rl = util_game.data.reverse_lookup

---@class Porterutil
local this = {
    porters = {},
    porter_command = {},
    porter_quest_interrupts = {
        "INTERRUPT_QUEST_CLEAR_GESTURE_EAT",
        "INTERRUPT_QUEST_CLEAR_GESTURE_PET",
        "INTERRUPT_QUEST_CLEAR_GESTURE_EAT_NOTE",
        "INTERRUPT_QUEST_CLEAR_GESTURE_EAT_OTOMO_FEED",
        "INTERRUPT_QUEST_CLEAR_GESTURE_HUG_PORTER_AND_OTOMO",
        "INTERRUPT_QUEST_CLEAR_GESTURE_HAND_OVER_MEMO_PLAYER",
        "INTERRUPT_QUEST_CLEAR_GESTURE_HAND_OVER_MEMO_ADVISOR",
    },
}

---@return app.cPorterManageInfo?
function this.get_master_info()
    return s.get("app.PorterManager"):getMasterPlayerPorter()
end

---@return app.PorterCharacter?
function this.get_master_char()
    local info = this.get_master_info()
    if info then
        return info:get_Character()
    end
end

---@return boolean
function this.is_master_riding()
    local master_porter = this.get_master_char()
    if not master_porter then
        return false
    end

    return master_porter:get_IsRiding()
end

---@return boolean
function this.is_master_touch()
    local master_porter = this.get_master_char()
    if not master_porter then
        return false
    end

    local ctx = master_porter:get_Context()
    local owner = ctx:get_RideOwner()

    if not owner then
        return false
    end

    local comm = owner:get_PorterComm()
    return comm:get_IsRiderWithinRanged()
end

---@param command app.PorterDef.COMMUNICATOR_COMMAND
---@return boolean
function this.is_master_command(command)
    local master_porter = this.get_master_char()
    if not master_porter then
        return false
    end

    local ctx = master_porter:get_Context()
    local command_info = ctx:get_CommandInfo()

    return command_info:isExecuted(command)
end

---@return boolean
function this.is_master_quest_interrupt()
    local master_porter = this.get_master_char()
    if not master_porter then
        return false
    end

    local ctx = master_porter:get_Context()
    local command_info = ctx:get_CommandInfo()

    return util_table.any(this.porter_quest_interrupts, function(key, value)
        return command_info:isExecuted(rl(this.porter_command, value))
    end)
end

---@param flag app.PorterDef.CONTINUE_FLAG
---@param value boolean
function this.set_master_continue_flag(flag, value)
    local master_porter = this.get_master_char()
    if not master_porter then
        return false
    end

    local ctx = master_porter:get_Context()
    local flags = ctx:get_PtContinueFlag()

    if value then
        flags:on(flag)
    else
        flags:off(flag)
    end
end

---@param hunter app.CharacterBase
---@return app.PorterCharacter?
function this.get_porter(hunter)
    ---@type app.PorterCharacter?
    local ret
    local arr = s.get("app.PorterManager"):get_InstancedPorterList()
    util_game.do_something(arr, function(system_array, index, value)
        local info = value:get_PorterInfo()
        local holder = info:get_ContextHolder()
        local ctx = holder:get_Pt()

        if ctx:get_RideOwner() == hunter then
            ret = info:get_Character()
            return false
        end
    end)

    return ret
end

---@param info app.cPorterManageInfo
---@return Vector3f
function this.get_pos(info)
    local char = info:get_Character()
    if not char then
        return Vector3f.new(0, 0, 0)
    end

    return char:get_Pos()
end

---@param porter app.PorterCharacter
---@param flag app.PorterDef.CONTINUE_FLAG
---@param value boolean
function this.set_continue_flag(porter, flag, value)
    local ctx = porter:get_Context()
    local flags = ctx:get_PtContinueFlag()

    if value then
        flags:on(flag)
    else
        flags:off(flag)
    end
end

---@param n number
function this.change_fade_speed(n)
    local master_porter = this.get_master_char()
    if not master_porter then
        return
    end

    local fade = master_porter._MeshFadeController
    fade:set_DefaultSpeed(n)
end

---@return boolean
function this.init()
    util_game.data.get_enum("app.PorterDef.COMMUNICATOR_COMMAND", this.porter_command)

    if util_table.empty(this.porter_command) then
        return false
    end
    return true
end

this.get_master_char = cache.memoize(this.get_master_char, function(cached_value)
    ---@cast cached_value app.PorterCharacter
    return cached_value:get_Valid()
end)
this.get_porter = cache.memoize(this.get_porter, function(cached_value)
    ---@cast cached_value app.PorterCharacter
    return cached_value:get_Valid()
end)

return this
