---@class PlayerUtil
---@field master_char app.HunterCharacter?

local s = require("HudController.util.ref.singletons")
local util_misc = require("HudController.util.misc")

---@class PlayerUtil
local this = {}

---@return app.cPlayerManageInfo?
function this.get_master_info()
    return s.get("app.PlayerManager"):getMasterPlayer()
end

---@return app.HunterCharacter
function this.get_master_char()
    if this.master_char and not this.master_char:get_Valid() then
        this.master_char = nil
    end

    local info = this.get_master_info()
    if info then
        this.master_char = info:get_Character()
    end

    return this.master_char
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
function this.get_master_weapon_type()
    local master_player = this.get_master_char()
    if not master_player then
        return -1
    end

    return master_player:get_WeaponType()
end

return this
