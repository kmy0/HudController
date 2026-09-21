local common = require("HudController.hud.hook.common")
local e = require("HudController.util.game.enum")
local hud = require("HudController.hud.init")
local mod = require("HudController.data.mod")
local util_ref = require("HudController.util.ref.init")

local this = {}

function this.disable_scar_stamp_pre(args)
    local hud_config = common.get_hud()
    if hud_config then
        local em_scar = hud.get_hud_option("monster_wound")

        if em_scar == mod.enum.em_scar.DISABLE or em_scar == mod.enum.em_scar.HIDE then
            local state = sdk.to_int64(args[3]) --[[@as app.cEmModuleScar.cScarParts.STATE]]
            if state ~= e.get("app.cEmModuleScar.cScarParts.STATE").NORMAL then
                return sdk.PreHookResult.SKIP_ORIGINAL
            end
        end
    end
end

function this.disable_scar_activate_pre(args)
    local hud_config = common.get_hud()
    if hud_config then
        local em_scar = hud.get_hud_option("monster_wound")

        if em_scar == mod.enum.em_scar.DISABLE then
            local state = sdk.to_int64(args[6]) --[[@as app.cEmModuleScar.cScarParts.STATE]]

            if
                state == e.get("app.cEmModuleScar.cScarParts.STATE").RAW
                or state == e.get("app.cEmModuleScar.cScarParts.STATE").TEAR
            then
                return sdk.PreHookResult.SKIP_ORIGINAL
            end
        end
    end
end

function this.disable_scar_state_pre(args)
    local hud_config = common.get_hud()
    if hud_config then
        local em_scar = hud.get_hud_option("monster_wound")

        if em_scar == mod.enum.em_scar.DISABLE then
            local state = sdk.to_int64(args[4]) --[[@as app.cEmModuleScar.cScarParts.STATE]]

            if
                state == e.get("app.cEmModuleScar.cScarParts.STATE").RAW
                or state == e.get("app.cEmModuleScar.cScarParts.STATE").TEAR
            then
                return sdk.PreHookResult.SKIP_ORIGINAL
            end
        end
    end
end

function this.scar_state_post(_)
    local hud_config = common.get_hud()
    if hud_config then
        local em_scar = hud.get_hud_option("monster_wound")
        if em_scar == mod.enum.em_scar.DISABLE then
            return
        end

        ---@type boolean?
        local bool
        if em_scar == mod.enum.em_scar.SHOW then
            bool = true
        elseif em_scar == mod.enum.em_scar.HIDE then
            bool = false
        end

        local eff_highlight = util_ref.get_this() --[[@as app.cEnemyLoopEffectHighlight?]]
        if bool ~= nil and eff_highlight then
            eff_highlight._IsAim = bool
            return bool
        end
    end
end

return this
