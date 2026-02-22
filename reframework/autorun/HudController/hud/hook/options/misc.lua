local common = require("HudController.hud.hook.common")
local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local hud = require("HudController.hud.init")
local util_ref = require("HudController.util.ref.init")

local ace_enum = data.ace.enum
local ace_map = data.ace.map
local rl = game_data.reverse_lookup

local this = {}

function this.disable_gui_sound_pre(args)
    local hud_config = common.get_hud()
    if not hud_config then
        return
    end

    if hud.get_hud_option("mute_gui") then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end

    local guiid = util_ref.to_short(args[3])
    if hud.get_hud_option("skip_quest_end_timer") and ace_enum.gui_id[guiid] == "UI020202" then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end

    if ace_enum.gui_id[guiid] == ace_map.additional_hud_to_guiid_name["BUTTON_PRESS"] then
        local hud_elem, _ = common.get_elem_consume_t(nil, guiid)
        if hud_elem and hud_elem.hide then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.hide_gossip_subtitles_pre(args)
    local hud_config = common.get_hud()
    if not hud_config then
        return
    end

    if hud.get_hud_option("hide_subtitles") then
        local req = sdk.to_managed_object(args[3]) --[[@as app.cDialogueSubtitleManager.RequestData]]
        local param = req.SubTitleParam
        local type = param.DialogueType

        if type == rl(ace_enum.dialog, "GOSSIP") or type == rl(ace_enum.dialog, "NAGARA") then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.mute_gossip_subtitles_pre(args)
    local hud_config = common.get_hud()
    if not hud_config then
        return
    end

    if hud.get_hud_option("mute_gossip") then
        local param = sdk.to_managed_object(args[3]) --[[@as app.DialogueDef.DialogueVoiceParam]]
        local type = param.TalkType

        if type == rl(ace_enum.dialog, "GOSSIP") or type == rl(ace_enum.dialog, "NAGARA") then
            util_ref.thread_store(true)
        end
    end
end

function this.mute_gossip_subtitles_post(args)
    if util_ref.thread_get() then
        return false
    end
end

function this.disable_area_intro_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_area_intro") then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

return this
