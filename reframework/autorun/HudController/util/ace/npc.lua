local cache = require("HudController.util.misc.cache")
local s = require("HudController.util.ref.singletons")
---@class MethodUtil
local m = require("HudController.util.ref.methods")
local util_game = require("HudController.util.game")
local util_misc = require("HudController.util.misc")
local util_ref = require("HudController.util.ref")

m.NpcIDfromFIXED = m.wrap(m.get("app.NpcDef.getIDFromFixed(app.NpcDef.ID_Fixed, app.NpcDef.ID)")) --[[@as fun(id_fixed: app.NpcDef.ID_Fixed, out: app.NpcDef.ID): System.Boolean]]

local this = {}

---@param npc_id app.NpcDef.ID
---@return app.cNpcManageInfo?
function this.get_npc_info(npc_id)
    return s.get("app.NpcManager"):findNpcInfo_NpcId(npc_id)
end

---@param npc app.NpcDef.ID | app.NpcCharacter
---@return app.NpcCharacterCore?
function this.get_npc_core(npc)
    ---@type app.NpcDef.ID
    local npc_id
    if type(npc) == "number" then
        npc_id = npc
    else
        ---@cast npc app.NpcCharacter
        npc_id = this.get_npc_id(npc)
    end

    local info = this.get_npc_info(npc_id)
    if info then
        return info:get_NpcCore()
    end
end

---@param npc_char app.NpcCharacter
function this.get_npc_id(npc_char)
    local ctx_holder = npc_char._ContextHolder
    local ctx = ctx_holder:get_Npc()
    return ctx.NpcID
end

---@param npc_id app.NpcDef.ID
---@return boolean
function this.is_touch(npc_id)
    local npc = this.get_npc_core(npc_id)
    if not npc then
        return false
    end

    local components = npc._Components
    local interact_ctrl = components.InteractCtrl

    if not interact_ctrl then
        return false
    end

    return interact_ctrl:get_IsTouch()
end


---@param npc app.NpcDef.ID | app.NpcCharacter
---@return ace.cSafeContinueFlagGroup?
function this.get_flags(npc)
    local core = this.get_npc_core(npc)

    if not core then
        return
    end

    local holder = core._ContextHolder
    if not holder then
        return
    end

    local ctx = holder:get_Npc()
    return ctx.NpcContinueFlag
end

---@param npc app.NpcDef.ID | app.NpcCharacter
---@param flag app.NpcDef.CHARA_CONTINUE_FLAG
---@param value boolean
function this.set_continue_flag(npc, flag, value)
    local flags = this.get_flags(npc)

    if not flags then
        return
    end

    if value then
        flags:on(flag)
    else
        flags:off(flag)
    end
end

---@param npc_id app.NpcDef.ID
---@return app.CharacterBase?
function this.get_char_base(npc_id)
    local core = this.get_npc_core(npc_id)
    if not core then
        return
    end

    ---@type via.GameObject?
    local game_object
    util_misc.try(function()
        game_object = core:get_GameObject()
    end)

    if not game_object then
        return
    end

    return util_game.get_component(game_object, "app.CharacterBase") --[[@as app.CharacterBase]]
end

---@param npc_id_fixed app.NpcDef.ID_Fixed
---@return app.NpcDef.ID
function this.get_npc_id_from_fixed(npc_id_fixed)
    local npc_id = util_ref.value_type("app.NpcDef.ID")
    m.NpcIDfromFIXED(npc_id_fixed, npc_id)
    return npc_id:get_field("value__")
end
this.get_flags = cache.memoize(this.get_flags)
this.get_npc_core = cache.memoize(this.get_npc_core, function(cached_value)
    ---@cast cached_value app.NpcCharacterCore
    return cached_value:get_Valid()
end)

return this
