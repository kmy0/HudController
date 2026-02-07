local this = {
    ace = require("HudController.data.ace"),
    mod = require("HudController.data.mod"),
}

local ace_misc = require("HudController.util.ace.misc")
local config = require("HudController.config.init")
local deprecated = require("HudController.data.deprecated")
local e = require("HudController.util.game.enum")
local game_lang = require("HudController.util.game.lang")
---@class MethodUtil
local m = require("HudController.util.ref.methods")
local s = require("HudController.util.ref.singletons")
local util_game = require("HudController.util.game.init")
local util_table = require("HudController.util.misc.table")

local ace_map = this.ace.map

m.ChatLogIDData = m.wrap(m.get("app.ChatDef.Data(app.ChatDef.LOG_ID)")) --[[@as fun(log_id: app.ChatDef.LOG_ID): app.user_data.ChatLogData.cData]]
m.ChatLogAUTO_IDData = m.wrap(m.get("app.Communication.Data(app.Communication.AUTO_ID)")) --[[@as fun(auto_id: app.Communication.AUTO_ID): app.user_data.AutoData.cData]]

---@return boolean
local function get_hud_setting()
    e.new("app.GUIHudDef.TYPE")

    local var_setting = s.get("app.VariousDataManager"):get_Setting()
    local gui_data = var_setting:get_GUIVariousData()
    local hud_data = gui_data:get_HudDisplayOptionData()
    local lang = game_lang.get_language()

    for name, id in e.iter("app.GUIHudDef.TYPE") do
        local hud_setting = hud_data:getSetting(id)
        local message = game_lang.get_message_local(hud_setting:get_Name(), lang, true)

        --FIXME: this sometimes just fails on boot, i dont understand why
        if message == "" then
            return false
        end

        ace_map.hudid_name_to_local_name[name] = message
        ace_map.hudid_to_can_hide[id] = not hud_setting:get_DisableHide()
    end

    return true
end

local function get_hud_map()
    local huddata = ace_misc.get_hud_manager()._HudData
    local hudsettings = huddata._Settings
    local hudsettings_enum = util_game.get_array_enum(hudsettings)

    while hudsettings_enum:MoveNext() do
        local setting = hudsettings_enum:get_Current() --[[@as app.user_data.GUIHudData.cSetting]]
        local hudid = setting:get_Type()

        if e.get("app.GUIHudDef.TYPE")[hudid] then
            local guiid = setting:get_Id()
            local guiid_name = e.get("app.GUIID.ID")[guiid]
            if not ace_map.guiid_ignore[guiid_name] then
                util_table.insert_nested_value(ace_map.hudid_to_guiid, { hudid }, guiid)
                ace_map.guiid_to_hudid[guiid] = hudid
            end
        end
    end
end

local function set_additional_hud()
    for i = 1, #ace_map.additional_hud do
        local name = ace_map.additional_hud[i]
        local guiid_name = ace_map.additional_hud_to_guiid_name[name]
        local guiid = e.get("app.GUIID.ID")[guiid_name]
        local enum = ace_map.additional_hud_index + i

        e.get("app.GUIHudDef.TYPE"):add(name, enum)
        ace_map.hudid_to_can_hide[enum] = false
        ace_map.hudid_name_to_local_name[name] = ace_map.hud_tr_flag
        ace_map.guiid_to_hudid[guiid] = enum
        util_table.insert_nested_value(ace_map.hudid_to_guiid, { enum }, guiid)
    end

    for gui, target in pairs(ace_map.hudless_to_hud) do
        local guiid = e.get("app.GUIID.ID")[gui]
        local guiid_target = e.get("app.GUIID.ID")[target]
        local hudid = ace_map.guiid_to_hudid[guiid_target]
        ace_map.guiid_to_hudid[guiid] = hudid
        util_table.insert_nested_value(ace_map.hudid_to_guiid, { hudid }, guiid)
    end
end

local function get_option_map()
    local lang = game_lang.get_language()
    for name, id in e.iter("app.Option.ID") do
        local option_data = m.getOptionData(id)

        if not option_data then
            goto continue
        end

        ace_map.option[name] = {
            id = id,
            name_local = game_lang.get_message_local(option_data:get_MsgTitle(), lang, true),
            items = {},
        }

        util_game.do_something(option_data:get_Items(), function(_, index, value)
            table.insert(ace_map.option[name].items, {
                index = index,
                name_local = game_lang.get_message_local(value:get_MsgTitle(), lang, true),
            })
        end)
        ::continue::
    end
end

local function get_log_id_text()
    local lang = game_lang.get_language()

    for _, log_id in e.iter("app.ChatDef.LOG_ID") do
        local data = m.ChatLogIDData(log_id)
        local msgs = {
            game_lang.get_message_local(data:get_Title(), lang, true),
            game_lang.get_message_local(data:get_Caption(), lang, true),
        }
        local stripped = {}

        for _, msg in ipairs(msgs) do
            local stripped_msg, _ = msg:gsub("<[^>]*>", "")

            if stripped_msg ~= "" then
                ---@diagnostic disable-next-line: no-unknown
                stripped_msg, _ = stripped_msg:gsub("\n", " ")
                table.insert(stripped, stripped_msg)
            end
        end
        ace_map.log_id_to_text[log_id] = table.concat(stripped, ", ")
    end

    for _, auto_id in e.iter("app.Communication.AUTO_ID") do
        local data = m.ChatLogAUTO_IDData(auto_id)
        if data then
            ace_map.auto_id_to_text[auto_id] =
                game_lang.get_message_local(data:get_Explain(), lang, true)
        end
    end
end

---@param config_table MainSettings
function this.get_weapon_bind_map(config_table)
    local lang = game_lang.get_language()
    ---@type WeaponBindConfig
    local base = {
        weapon_id = -1,
        enabled = false,
        name = "",
        combat_in = { hud_key = -1, combo = 1 },
        combat_out = { hud_key = -1, combo = 1 },
        camp = { hud_key = -1, combo = 1 },
    }

    local function copy_base(name, wp_base)
        local bind_weapon = config_table.mod.bind.weapon
        for _, mode in pairs(ace_map.weapon_binds.game_mode) do
            ---@diagnostic disable-next-line: no-unknown
            bind_weapon[mode][name] =
                util_table.merge_t(util_table.deep_copy(wp_base), bind_weapon[mode][name] or {})
        end
    end

    for name, id in e.iter("app.WeaponDef.TYPE") do
        ace_map.weaponid_name_to_local_name[name] =
            game_lang.get_message_local(m.getWeaponName(id), lang, true)
        local weapon_base = util_table.deep_copy(base)
        weapon_base.weapon_id = id
        weapon_base.name = name

        copy_base(name, weapon_base)
    end

    for i, name in pairs(ace_map.weapon_binds.additional_weapon) do
        local weapon_base = util_table.deep_copy(base)
        weapon_base.name = name
        weapon_base.weapon_id = -i
        copy_base(name, weapon_base)
    end
end

---@return boolean
function this.init()
    if
        not s.get("app.GUIManager")
        or not ace_misc.get_hud_manager()
        or not s.get("app.VariousDataManager")
        or not get_hud_setting()
    then
        return false
    end

    if
        not e.wrap_init(function()
            e.new("app.WeaponDef.TYPE")
            e.new("app.Option.ID")
            e.new("app.GUIHudDef.DISPLAY")
            e.new("app.DialogueType.TYPE")
            e.new("app.HunterDef.CONTINUE_FLAG")
            e.new("ace.GUIDef.INPUT_DEVICE")
            e.new("app.GUIFunc.TYPE")
            e.new("app.PlayerDef.ButtonMask.USER")
            e.new("app.ChatDef.SYSTEM_MSG_TYPE")
            e.new("app.ChatDef.SEND_TARGET")
            e.new("via.gui.ControlPoint")
            e.new("via.gui.BlendType")
            e.new("via.gui.AlphaChannelType")
            e.new("app.ItemUtil.STOCK_TYPE")
            e.new("app.GUIAccessIconControl.OBJECT_CATEGORY")
            e.new("app.PorterDef.CONTINUE_FLAG")
            e.new("app.NpcDef.ID")
            e.new("app.NpcDef.CHARA_CONTINUE_FLAG")
            e.new("app.GUI020201.TYPE")
            e.new("app.cGUIMemberPartsDef.MemberType")
            e.new("app.GUI020007.BulletSliderStatus")
            e.new("app.GUIDefApp.DRAW_SEGMENT", function(key, _)
                return key ~= "LOWEST" and key ~= "HIGHEST"
            end, true)
            e.new("app.cGUIQuestResultInfo.MODE")
            e.new("app.GUIManager.APP_CONTINUE_FLAG")
            e.new("app.GUIID.ID")
            e.new("app.GUI020400.SUBTITLES_CATEGORY")
            e.new("app.EnemyDef.CONTINUE_FLAG")
            e.new("app.GUI020020.State")
            e.new("app.GUI020020.CRITICAL_STATE")
            e.new("app.HunterDef.SLINGER_AMMO_TYPE")
            e.new("via.gui.PageAlignment")
            e.new("app.ChatDef.CAMP_LOG_TYPE")
            e.new("app.ChatDef.ENEMY_LOG_TYPE")
            e.new("app.ChatDef.MSG_TYPE")
            e.new("app.GUI020001PanelParams.NPC_TYPE")
            e.new("app.GUI020001PanelParams.GOSSIP_TYPE")
            e.new("app.GUI020001PanelParams.PANEL_TYPE")
            e.new("app.cEmModuleScar.cScarParts.STATE")
            e.new("app.GUI020015.DEFAULT_STATUS")
            e.new("app.TARGET_ACCESS_KEY.CATEGORY")
            e.new("app.OtomoDef.CONTINUE_FLAG")
            e.new("app.cGUIMapFlowCtrl.FLAG")
            e.new("app.ChatDef.LOG_ID")
            e.new("app.EnemyDef.AI_TARGET_STATE")
            e.new("app.Communication.AUTO_ID")
        end)
    then
        return false
    end

    get_hud_map()
    set_additional_hud()
    this.get_weapon_bind_map(config.current)
    get_option_map()
    get_log_id_text()

    for field_name, _ in
        e.iter_many({
            "app.GUI020400.SUBTITLES_CATEGORY",
            "app.GUI020020.State",
            "app.GUI020020.CRITICAL_STATE",
        })
    do
        ace_map.no_lang_key[field_name] = true
    end

    deprecated.init()
    return true
end

return this
