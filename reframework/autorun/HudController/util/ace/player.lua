---@class PlayerUtil
---@field is_village_frame boolean

local cache = require("HudController.util.misc.cache")
local s = require("HudController.util.ref.singletons")
local util_misc = require("HudController.util.misc")

---@class PlayerUtil
local this = {}

---@return app.cPlayerManageInfo?
function this.get_master_info()
    return s.get("app.PlayerManager"):getMasterPlayer()
end

---@param info app.cPlayerManageInfo
function this.get_char(info)
    return info:get_Character()
end

---@return app.HunterCharacter?
function this.get_master_char()
    local info = this.get_master_info()
    if info then
        return info:get_Character()
    end
end

function this.get_master_pos()
    local info = this.get_master_info() --[[@as app.cPlayerManageInfo]]
    return this.get_char(info):get_Pos()
end

---@param info app.cPlayerManageInfo
---@return Vector3f
function this.get_pos(info)
    local char = this.get_char(info)
    if not char then
        return Vector3f.new(0, 0, 0)
    end
    return char:get_Pos()
end

---@param flag app.HunterDef.CONTINUE_FLAG
---@return boolean
function this.check_continue_flag(flag)
    local master_player = this.get_master_char()
    if not master_player then
        return false
    end

    local flags = master_player._HunterContinueFlag
    return flags:check(flag)
end

---@param flag app.HunterDef.CONTINUE_FLAG
---@param value boolean
function this.set_continue_flag(flag, value)
    local master_player = this.get_master_char()
    if not master_player then
        return false
    end

    local flags = master_player._HunterContinueFlag
    if value then
        flags:on(flag)
    else
        flags:off(flag)
    end
end

---@return boolean
function this.is_combat()
    local master_player = this.get_master_char()
    if not master_player then
        return false
    end

    local is_combat = false
    if
        not util_misc.try(function()
            is_combat = master_player:get_IsWeaponOn() or master_player:get_IsCombat()
        end)
    then
        return false
    end

    return is_combat
end

---@return app.WeaponDef.TYPE
function this.get_weapon_type()
    local master_player = this.get_master_char()
    if not master_player then
        return -1
    end

    return master_player:get_WeaponType()
end

---@return boolean
function this.is_in_village()
    local master_player = this.get_master_char()
    if not master_player then
        return false
    end

    local is_village = master_player:get_IsInBaseCamp()
    if not is_village and this.is_village_frame and this.is_fast_travel() then
        return true
    end

    this.is_village_frame = is_village
    return is_village
end

---@return boolean
function this.is_fast_travel()
    return s.get("app.MissionManager"):isFastTravel()
end

this.get_master_char = cache.memoize(this.get_master_char, function(cached_value)
    ---@cast cached_value app.HunterCharacter
    return cached_value:get_Valid()
end)
this.get_char = cache.memoize(this.get_char, function(cached_value)
    ---@cast cached_value app.HunterCharacter
    return cached_value:get_Valid()
end)

return this
