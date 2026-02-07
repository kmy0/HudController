local common = require("HudController.hud.hook.common")
local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local play_object = require("HudController.hud.play_object.init")
local util_ref = require("HudController.util.ref.init")
local util_table = require("HudController.util.misc.table")

local this = {}

function this.skip_system_message_pre(args)
    local notice = common.get_elem_t("Notice")
    if notice then
        if notice.hide or notice.system_log.ALL then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end

        local def = sdk.to_managed_object(args[3]) --[[@as app.ChatDef.SystemMessage]]
        local name = e.get("app.ChatDef.SYSTEM_MSG_TYPE")[def:get_SystemMsgType()]

        if notice.system_log[name] then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end

        local log_id = def:get_ChatLogId()

        if log_id ~= -1 then
            if notice.log_id[tostring(log_id)] then
                return sdk.PreHookResult.SKIP_ORIGINAL
            end
        end

        local log_name = ""
        local log_t = {}
        if util_ref.is_a(def, "app.ChatDef.EnemyMessage") then
            ---@cast def app.ChatDef.EnemyMessage
            log_name = e.get("app.ChatDef.ENEMY_LOG_TYPE")[def:get_EnemyLogType()]
            log_t = notice.enemy_log
        elseif util_ref.is_a(def, "app.ChatDef.CampMessage") then
            ---@cast def app.ChatDef.CampMessage
            log_name = e.get("app.ChatDef.CAMP_LOG_TYPE")[def:get_CampLogType()]
            log_t = notice.camp_log
        end

        if log_t[log_name] then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.cache_message_pre(args)
    local notice = common.get_elem_t("Notice")
    if notice and notice.cache_msg then
        local panel_base = sdk.to_managed_object(args[3]) --[[@as app.cGUI020100PanelBase]]
        local message_elem = panel_base:get_Log()
        local chat_log_base = panel_base:get_LogPanelBase()
        local ctrl = chat_log_base:get_BasePanel()
        local txts = play_object.child.all_type(ctrl, nil, "via.gui.Text")
        local msgs = {}

        util_table.do_something(txts, function(_, _, value)
            local msg = value:get_Message()
            if msg then
                local stripped_msg, _ = msg:gsub("<[^>]*>", "")
                table.insert(msgs, stripped_msg)
            end
        end)

        ---@type CachedMessage
        local cached_msg = {
            type = config.lang:tr("misc.text_unknown"),
            msg = table.concat(msgs, ", "),
            cls = notice.get_cls_name_short(util_ref.whoami(panel_base)),
            log_id = message_elem:get_ChatLogId(),
        }

        if util_ref.is_a(message_elem, "app.ChatDef.SystemMessage") then
            ---@cast message_elem app.ChatDef.SystemMessage
            cached_msg.type = config.lang:tr("misc.text_system")
            cached_msg.sub_type =
                e.get("app.ChatDef.SYSTEM_MSG_TYPE")[message_elem:get_SystemMsgType()]

            if util_ref.is_a(message_elem, "app.ChatDef.EnemyMessage") then
                ---@cast message_elem app.ChatDef.EnemyMessage
                cached_msg.other_type =
                    e.get("app.ChatDef.ENEMY_LOG_TYPE")[message_elem:get_EnemyLogType()]
            elseif util_ref.is_a(message_elem, "app.ChatDef.CampMessage") then
                ---@cast message_elem app.ChatDef.CampMessage
                cached_msg.other_type =
                    e.get("app.ChatDef.CAMP_LOG_TYPE")[message_elem:get_CampLogType()]
            end
        elseif util_ref.is_a(message_elem, "app.ChatDef.ChatBase") then
            ---@cast message_elem app.ChatDef.ChatBase
            cached_msg.type = config.lang:tr("misc.text_lobby")
            cached_msg.sub_type = e.get("app.ChatDef.MSG_TYPE")[message_elem:get_MsgType()]
            cached_msg.other_type = e.get("app.ChatDef.SEND_TARGET")[message_elem:get_SendTarget()]
        end

        notice:push_back(cached_msg)
    end
end

function this.skip_lobby_message_pre(args)
    local notice = common.get_elem_t("Notice")
    if notice then
        if notice.hide or notice.chat_log.ALL then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end

        local def = sdk.to_managed_object(args[3]) --[[@as app.ChatDef.ChatBase]]
        local name = e.get("app.ChatDef.MSG_TYPE")[def:get_MsgType()]

        if notice.chat_log[name] then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end

        name = e.get("app.ChatDef.SEND_TARGET")[def:get_SendTarget()]
        if notice.lobby_log[name] then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.skip_auto_message_pre(args)
    local notice = common.get_elem_t("Notice")
    if notice then
        local chat_base = sdk.to_managed_object(args[3]) --[[@as app.net_packet.cChatBase]]
        if
            util_ref.is_a(chat_base, "app.net_packet.cSysChatAutoTemplate")
            ---@cast chat_base app.net_packet.cSysChatAutoTemplate

            and notice.auto_id[e.get("app.Communication.AUTO_ID")[chat_base.AutoId]]
        then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

return this
