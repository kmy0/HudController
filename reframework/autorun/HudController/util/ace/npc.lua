---@class NpcUtil
---@field npcs table<app.NpcDef.ID, app.NpcCharacterCore>

local s = require("HudController.util.ref.singletons")
---@class MethodUtil
local m = require("HudController.util.ref.methods")
local util_game = require("HudController.util.game")
local util_misc = require("HudController.util.misc")
local util_ref = require("HudController.util.ref")

m.NpcIDfromFIXED = m.wrap(m.get("app.NpcDef.getIDFromFixed(app.NpcDef.ID_Fixed, app.NpcDef.ID)")) --[[@as fun(id_fixed: app.NpcDef.ID_Fixed, out: app.NpcDef.ID): System.Boolean]]

---@class NpcUtil
local this = {
    npcs = {},
}

---@param npc_id app.NpcDef.ID
---@return app.cNpcManageInfo?
function this.get_npc_info(npc_id)
    return s.get("app.NpcManager"):findNpcInfo_NpcId(npc_id)
end

---@param npc_id app.NpcDef.ID
---@return app.NpcCharacterCore
function this.get_npc_core(npc_id)
    if not this.npcs[npc_id] or this.npcs[npc_id]:get_Valid() then
        this.npcs[npc_id] = nil
    end

    local info = this.get_npc_info(npc_id)
    if info then
        this.npcs[npc_id] = info:get_NpcCore()
    end

    return this.npcs[npc_id]
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

---@param npc_id app.NpcDef.ID
---@param flag app.NpcDef.CHARA_CONTINUE_FLAG
---@param value boolean
function this.set_continue_flag(npc_id, flag, value)
    local npc = this.get_npc_core(npc_id)
    if not npc then
        return
    end

    local holder = npc._ContextHolder
    if not holder then
        return
    end

    local ctx = holder:get_Npc()
    local flags = ctx.NpcContinueFlag

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

return this
