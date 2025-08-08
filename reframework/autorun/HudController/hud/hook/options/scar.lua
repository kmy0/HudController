local common = require("HudController.hud.hook.common")
local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud = require("HudController.hud")
local util_ref = require("HudController.util.ref")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

local this = {}

function this.disable_scar_stamp_pre(args)
    local hud_config = common.get_hud()
    if hud_config and (hud.get_hud_option("disable_scar") or hud.get_hud_option("hide_scar")) then
        local state = sdk.to_int64(args[3]) --[[@as app.cEmModuleScar.cScarParts.STATE]]
        if state ~= rl(ace_enum.scar_state, "NORMAL") then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.disable_scar_activate_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_scar") then
        local state = sdk.to_int64(args[6]) --[[@as app.cEmModuleScar.cScarParts.STATE]]
        if state == rl(ace_enum.scar_state, "RAW") or state == rl(ace_enum.scar_state, "TEAR") then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.disable_scar_state_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_scar") then
        local state = sdk.to_int64(args[4]) --[[@as app.cEmModuleScar.cScarParts.STATE]]
        if state == rl(ace_enum.scar_state, "RAW") or state == rl(ace_enum.scar_state, "TEAR") then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.scar_state_post(retval)
    local hud_config = common.get_hud()
    if
        hud_config
        and not hud.get_hud_option("disable_scar")
        and (hud.get_hud_option("show_scar") or hud.get_hud_option("hide_scar"))
    then
        ---@type boolean?
        local bool
        if hud.get_hud_option("show_scar") then
            bool = true
        elseif hud.get_hud_option("hide_scar") then
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
