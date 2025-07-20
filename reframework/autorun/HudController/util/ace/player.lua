---@class PlayerUtil
---@field is_village_frame boolean
---@field frame integer
---@field pos_frame table<app.cPlayerManageInfo, integer>
---@field master_pos_frame integer

local cache = require("HudController.util.misc.cache")
local s = require("HudController.util.ref.singletons")
local util_misc = require("HudController.util.misc")

---@class PlayerUtil
local this = {
    frame = 0,
    master_pos_frame = 0,
    pos_frame = {},
}

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

---@return Vector3f
function this.get_master_pos_cached()
    this.master_pos_frame = this.frame
    return this.get_master_pos()
end

function this.get_master_pos()
    local info = this.get_master_info() --[[@as app.cPlayerManageInfo]]
    return this.get_char(info):get_Pos()
end

---@param info app.cPlayerManageInfo
---@return Vector3f
function this.get_pos_cached(info)
    return this.get_pos(info)
end

---@param info app.cPlayerManageInfo
---@return Vector3f
function this.get_pos(info)
    local char = this.get_char(info)
    if not char then
        return Vector3f.new(0, 0, 0)
    end
    print(info)
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

re.on_frame(function()
    this.frame = this.frame + 1
end)

this.get_master_char = cache.memoize(this.get_master_char, function(cached_value)
    ---@cast cached_value app.HunterCharacter
    return cached_value:get_Valid()
end)
this.get_char = cache.memoize(this.get_char, function(cached_value)
    ---@cast cached_value app.HunterCharacter
    return cached_value:get_Valid()
end)
this.get_pos_cached = cache.memoize(this.get_pos_cached, function(cached_value, key)
    ---@cast key app.cPlayerManageInfo
    return not this.pos_frame[key] or this.frame - this.pos_frame[key] < 60
end)
this.get_master_pos_cached = cache.memoize(this.get_master_pos_cached, function(cached_value, key)
    return this.frame - this.master_pos_frame < 60
end)

return this
