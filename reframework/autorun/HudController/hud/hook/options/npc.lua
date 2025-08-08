local ace_npc = require("HudController.util.ace.npc")
local ace_player = require("HudController.util.ace.player")
local ace_porter = require("HudController.util.ace.porter")
local common = require("HudController.hud.hook.common")
local config = require("HudController.config")
local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud = require("HudController.hud")
local m = require("HudController.util.ref.methods")
local s = require("HudController.util.ref.singletons")
local timer = require("HudController.util.misc.timer")
local util_game = require("HudController.util.game")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

local this = {}
local handler_key = "handler_touch_timer"

function this.hide_handler_post(retval)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("hide_handler") then
        local handler_id_fixed = m.getHandlerNpcIDFixed(true)
        local handler_id = ace_npc.get_npc_id_from_fixed(handler_id_fixed)

        if ace_npc.is_touch(handler_id) then
            timer.restart_key(handler_key)
        elseif timer.check(handler_key, config.handler_timeout) then
            local char_base = ace_npc.get_char_base(handler_id)
            if not char_base then
                return
            end

            ace_npc.set_continue_flag(handler_id, rl(ace_enum.npc_continue_flag, "DISABLE_TALK"), true)
            ace_npc.set_continue_flag(handler_id, rl(ace_enum.npc_continue_flag, "ALPHA_ZERO"), true)

            local handler_porter = ace_porter.get_porter(char_base)
            if not handler_porter then
                return
            end

            ace_porter.set_continue_flag(handler_porter, rl(ace_enum.porter_continue_flag, "DISABLE_RIDE_HUNTER"), true)
            ace_porter.set_continue_flag(handler_porter, rl(ace_enum.porter_continue_flag, "ALPHA_ZERO"), true)
        end
    end
end

function this.hide_no_talk_npc_pre(args)
    local hud_config = common.get_hud()
    if hud_config then
        local no_talk = hud.get_hud_option("hide_no_talk_npc")
        local no_facility = hud.get_hud_option("hide_no_facility_npc")

        if not no_talk and not no_facility then
            return
        end

        local npc_base = sdk.to_managed_object(args[2]) --[[@as app.NpcCharacter]]
        if
            (no_facility and ace_npc.is_facility(npc_base) == false)
            or (no_talk and ace_npc.is_talk(npc_base) == false)
        then
            ace_npc.set_continue_flag(npc_base, rl(data.ace.enum.npc_continue_flag, "ALPHA_ZERO"), true)
        end
    end
end

function this.hide_pet_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("hide_pet") then
        local quest_dir = s.get("app.MissionManager"):get_QuestDirector()
        if quest_dir:isPlayingQuest() or util_game.get_component_any("app.OtomoDoll") then
            return
        end

        local master_char = ace_player.get_master_char()
        if not master_char or master_char:get_IsInTent() then
            return
        end

        util_game.do_something(util_game.get_all_components("app.OtomoCharacter"), function(system_array, index, value)
            value:onOtomoContinueFlag(rl(ace_enum.otomo_continue_flag, "DRAW_OFF"))
        end)
    end
end

return this
