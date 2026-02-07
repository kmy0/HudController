local ace_player = require("HudController.util.ace.player")
local common = require("HudController.hud.hook.common")
local e = require("HudController.util.game.enum")
local hud = require("HudController.hud.init")
local util_misc = require("HudController.util.misc.init")

local this = {}

function this.hide_danger_line_post(retval)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("hide_danger") then
        local arr = sdk.to_managed_object(retval) --[[@as System.Array<app.AttackAreaResult>]]
        arr:Clear()
    end
end

--#region hide_weapon
function this.hide_weapon_pre(_)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("hide_weapon") then
        -- weapon cant be drawn otherwise
        ace_player.set_continue_flag(e.get("app.HunterDef.CONTINUE_FLAG").WP_ALPHA_ZERO, false)
    end
end

function this.hide_weapon_post(_)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("hide_weapon") then
        util_misc.try(function()
            local master_player = ace_player.get_master_char()

            if
                master_player
                and not master_player:get_IsWeaponOnAction()
                and not ace_player.check_continue_flag(
                    e.get("app.HunterDef.CONTINUE_FLAG").PORTER_WP_CHANGE
                )
                and not ace_player.check_continue_flag(
                    e.get("app.HunterDef.CONTINUE_FLAG").OPEN_KIREAJI_HUD
                )
            then
                ace_player.set_continue_flag(
                    e.get("app.HunterDef.CONTINUE_FLAG").WP_ALPHA_ZERO,
                    true
                )
            end
        end)
    end
end
--#endregion

function this.hide_aggro_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("hide_aggro") then
        local state = sdk.to_managed_object(args[3]) --[[@as app.game_message.cEmChangeState]]
        local msg_type = e.get("app.EnemyDef.AI_TARGET_STATE")[state:get_StateMsg()]
        if msg_type == "EM_LEAD" then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

return this
