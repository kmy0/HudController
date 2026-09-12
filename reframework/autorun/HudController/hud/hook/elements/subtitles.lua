local this = {}

local ace = require("HudController.data.ace")
local common = require("HudController.hud.hook.common")
local e = require("HudController.util.game.enum")
local util_game = require("HudController.util.game.init")
local util_ref = require("HudController.util.ref.init")
local m = util_ref.methods

---@param req app.cDialogueSubtitleManager.RequestData
---@return string type
---@return string npc_id
---@return string msg_id
---@return string talker_type
---@return string cls
local function get_subtitle_data(req)
    local param = req.SubTitleParam
    local base_param = param.baseParam
    local type = e.get("app.DialogueType.TYPE")[param.DialogueType]
    local npc_id = tostring(base_param:get_TalkerId())
    local msg_id = util_game.format_guid(base_param.MessageId)
    local talker_type = e.get("app.DialogueDef.ACTOR_TYPE")[base_param.TalkerType]
    local cls = e.get("app.GUI020400.SUBTITLES_CATEGORY")[param.SubTitleType]
    return type, npc_id, msg_id, talker_type, cls
end

---@param param app.DialogueDef.DialogueVoiceParam
---@return string type
---@return string npc_id
---@return string msg_id
---@return string talker_type
local function get_voice_data(param)
    local type = e.get("app.DialogueType.TYPE")[param.TalkType]
    local npc_id = tostring(param:get_TalkerId())
    local msg_id = util_game.format_guid(param.MessageId)
    local talker_type = e.get("app.DialogueDef.ACTOR_TYPE")[param.TalkerType]
    return type, npc_id, msg_id, talker_type
end

function this.hide_subtitles_pre(args)
    local subtitles = common.get_elem_t("Subtitles")
    if not subtitles then
        return
    end

    if subtitles:any_hide() then
        local req = sdk.to_managed_object(args[3]) --[[@as app.cDialogueSubtitleManager.RequestData]]
        local type, npc_id, msg_id, talker_type = get_subtitle_data(req)

        if
            subtitles.hide_subtitles[msg_id]
            or subtitles.hide_npc_id[npc_id]
            or subtitles.hide_dialogue_actor_type[talker_type]
            or subtitles.hide_dialogue_type[type]
        then
            local callback = req.SubTitleParam.EndCallBack
            callback:Invoke()
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.hide_subtitles_pre2(args)
    local subtitles = common.get_elem_t("Subtitles")
    if not subtitles then
        return
    end

    -- this prevents voice interuption if its not muted
    if subtitles:any_hide() then
        local param = sdk.to_managed_object(args[3]) --[[@as app.DialogueDef.DialogueVoiceParam]]
        local type, npc_id, msg_id, talker_type = get_voice_data(param)

        if
            subtitles.hide_subtitles[msg_id]
            or subtitles.hide_npc_id[npc_id]
            or subtitles.hide_dialogue_actor_type[talker_type]
            or subtitles.hide_dialogue_type[type]
        then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.mute_subtitles_pre(args)
    local subtitles = common.get_elem_t("Subtitles")
    if not subtitles then
        return
    end

    if subtitles:any_mute() then
        local param = sdk.to_managed_object(args[3]) --[[@as app.DialogueDef.DialogueVoiceParam]]
        local type, npc_id, msg_id, talker_type = get_voice_data(param)

        if
            subtitles.mute_subtitles[msg_id]
            or subtitles.mute_npc_id[npc_id]
            or subtitles.mute_dialogue_actor_type[talker_type]
            or subtitles.mute_dialogue_type[type]
        then
            util_ref.thread_store(true)
        end
    end
end

function this.mute_subtitles_post(_)
    if util_ref.thread_get() then
        return false
    end
end

function this.cache_subtitles_pre(args)
    local subtitles = common.get_elem_t("Subtitles")
    if not subtitles or not subtitles.cache_subtitles then
        return
    end

    local req = sdk.to_managed_object(args[3]) --[[@as app.cDialogueSubtitleManager.RequestData]]
    local type, npc_id, msg_id, talker_type, cls = get_subtitle_data(req)

    ---@type CachedSubtitle
    local cached_sub = {
        type = type,
        text = ace.map.subtitles[msg_id].text,
        cls = cls,
        talker_type = talker_type,
        npc = m.getNpcName(tonumber(npc_id) --[[@as number]]),
    }

    subtitles:push_back(cached_sub)
end

return this
