local ace_player = require("HudController.util.ace.player")
local common = require("HudController.hud.hook.common")
local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local hud = require("HudController.hud.init")
local m = require("HudController.util.ref.methods")
local util_misc = require("HudController.util.misc.init")

local ace_enum = data.ace.enum
local ace_map = data.ace.map
local rl = game_data.reverse_lookup

local this = {}

function this.hide_danger_line_post(retval)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("hide_danger") then
        local arr = sdk.to_managed_object(retval) --[[@as System.Array<app.AttackAreaResult>]]
        arr:Clear()
    end
end

--#region hide_weapon
function this.hide_weapon_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("hide_weapon") then
        -- weapon cant be drawn otherwise
        ace_player.set_continue_flag(rl(ace_enum.hunter_continue_flag, "WP_ALPHA_ZERO"), false)
    end
end

function this.hide_weapon_post(retval)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("hide_weapon") then
        util_misc.try(function()
            local master_player = ace_player.get_master_char()

            if
                master_player
                and not master_player:get_IsWeaponOnAction()
                and not ace_player.check_continue_flag(
                    rl(ace_enum.hunter_continue_flag, "PORTER_WP_CHANGE")
                )
                and not ace_player.check_continue_flag(
                    rl(ace_enum.hunter_continue_flag, "OPEN_KIREAJI_HUD")
                )
            then
                ace_player.set_continue_flag(
                    rl(ace_enum.hunter_continue_flag, "WP_ALPHA_ZERO"),
                    true
                )
            end
        end)
    end
end
--#endregion

return this
