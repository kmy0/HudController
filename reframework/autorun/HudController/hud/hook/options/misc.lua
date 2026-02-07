local common = require("HudController.hud.hook.common")
local e = require("HudController.util.game.enum")
local hud = require("HudController.hud.init")
local util_ref = require("HudController.util.ref.init")

local this = {}

function this.disable_gui_sound_pre(args)
    local hud_config = common.get_hud()
    if not hud_config then
        return
    end

    if
        hud.get_hud_option("mute_gui")
        or (
            hud.get_hud_option("skip_quest_end_timer")
            and util_ref.to_short(args[3]) == e.get("app.GUIID.ID").UI020202
        )
    then
        return sdk.PreHookResult.SKIP_ORIGINAL
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
        local enum = e.get("app.DialogueType.TYPE")

        if type == enum.GOSSIP or type == enum.NAGARA then
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
        local enum = e.get("app.DialogueType.TYPE")

        if type == enum.GOSSIP or type == enum.NAGARA then
            util_ref.thread_store(true)
        end
    end
end

function this.mute_gossip_subtitles_post(_)
    if util_ref.thread_get() then
        return false
    end
end

function this.disable_area_intro_pre(_)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_area_intro") then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

return this
