local this = {
    ace = require("HudController.data.ace"),
    mod = require("HudController.data.mod"),
}

local ace_misc = require("HudController.util.ace.misc")
local deprecated = require("HudController.data.deprecated")
local e = require("HudController.util.game.enum")
local game_lang = require("HudController.util.game.lang")
local lang_base = require("HudController.util.misc.lang_base")
local util_ref = require("HudController.util.ref.init")
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
        ace_map.hudid_name_to_local_name[name] =
            lang_base.make_placeholder("hud_element.name." .. name)
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

---@param str string
---@return string
local function replace_option_placeholder(str)
    for value in str:gmatch("<.->") do
        str = str:gsub(
            value,
            string.format("<PLACEHOLDER(%s)>", "menu.user.options.placeholder." .. value)
        )
    end
    return str
end

local function get_option_map()
    local lang = game_lang.get_language()
    local ignore_type = {
        e.get("app.Option.TYPE").SPEC,
        e.get("app.Option.TYPE").RESOLUTION,
        e.get("app.Option.TYPE").DISPLAY,
    }

    for name, id in e.iter("app.Option.ID") do
        local option_data = m.getOptionData(id)

        if not option_data or option_data:get_Category() == -1 then
            goto continue
        end

        local scene = option_data:get_Scene()
        if scene == e.get("app.Option.SCENE").TITLE then
            goto continue
        end

        -- app.Option.TYPE is defined here, otherwise in most cases
        -- it's just 0, no idea why it's done this way
        local disp_data = util_ref.ctor("app.GUI030100.DispData", true)
        disp_data:call(".ctor(app.user_data.OptionData.Data)", option_data)
        disp_data:setup(false)

        local type = disp_data:get_OptionType()
        if util_table.contains_any(ignore_type, type) then
            goto continue
        end

        local opt = {
            id = id,
            name = name,
            name_local = replace_option_placeholder(
                game_lang.get_message_local2(option_data:get_MsgTitle())
            ),
            name_path = {},
            items = {},
            category = option_data:get_Category(),
            parent = e.get("app.Option.ID")[option_data:get_ParentOptionID()],
            decimal_place = option_data:get_DecimalPlace(),
            min = option_data:get_MinValue(),
            max = option_data:get_MaxValue(),
            type = type,
        }

        local device = option_data:get_Device()
        if device ~= e.get("app.Option.DEVICE").ALL then
            local device_name = e.get("app.Option.DEVICE")[device]

            opt.name_local = string.format(
                "%s: %s",
                string.format("<PLACEHOLDER(%s)>", "menu.user.options.placeholder." .. device_name),
                opt.name_local
            )
        end

        util_game.do_something(option_data:get_Items(), function(_, index, value)
            table.insert(opt.items, {
                index = index,
                name_local = replace_option_placeholder(
                    game_lang.get_message_local(value:get_MsgTitle(), lang, true)
                ),
            })
        end)

        --FIXME: seems like the only way to "reliable" way to detect if option is a checkbox/toggle
        -- toggles dont have any items and have type CHOICE instead of TOGGLE and flags app.GUI030100.DISP_DATA_FLAG.UNDECIDABLE,
        -- there are few other elements that have type HEADLINE or UI but are actaully CHOICE, because fuck typing things properly or sth
        if
            #opt.items == 0
            and opt.type ~= e.get("app.Option.TYPE").VALUE
            and disp_data:getFlags() == 0 -- app.GUI030100.DISP_DATA_FLAG.NONE
        then
            goto continue
        end

        ace_map.option[name] = opt
        ::continue::
    end

    ---@type table<string, AceOptionNode>
    local nodes = {}
    for name, option in pairs(ace_map.option) do
        nodes[name] = {
            option = option,
            children = {},
        }
    end

    for _, node in pairs(nodes) do
        local option = node.option
        local parent = nodes[option.parent]

        if parent and parent.option.category == option.category then
            table.insert(parent.children, node)
        else
            local category = e.get("app.Option.CATEGORY")[option.category]

            ace_map.game_options[category] = ace_map.game_options[category] or {}

            table.insert(ace_map.game_options[category], node)
        end
    end

    ---@param nodes_to_prune AceOptionNode[]
    local function prune_nodes(nodes_to_prune)
        for i = #nodes_to_prune, 1, -1 do
            local node = nodes_to_prune[i]

            prune_nodes(node.children)

            if
                (
                    node.option.type == e.get("app.Option.TYPE").HEADLINE
                    or node.option.type == e.get("app.Option.TYPE").UI
                )
                and (util_table.empty(node.children) and util_table.empty(node.option.items))
            then
                table.remove(nodes_to_prune, i)
            end
        end
    end

    ---@param nodes AceOptionNode[]
    ---@param parent_path string[]
    local function set_namepaths(nodes, parent_path)
        for _, node in ipairs(nodes) do
            local option = node.option
            option.name_path = {}

            for _, part in ipairs(parent_path) do
                table.insert(option.name_path, part)
            end

            local child_path = {}
            for _, part in ipairs(parent_path) do
                table.insert(child_path, part)
            end

            table.insert(child_path, option.name_local)
            set_namepaths(node.children, child_path)
            table.insert(option.name_path, option.name_local)
        end
    end

    ---@param nodes_to_sort AceOptionNode[]
    local function sort_nodes(nodes_to_sort)
        table.sort(nodes_to_sort, function(a, b)
            return a.option.name_local < b.option.name_local
        end)

        for _, node in ipairs(nodes_to_sort) do
            sort_nodes(node.children)
        end
    end

    for category, roots in pairs(ace_map.game_options) do
        prune_nodes(roots)

        if #roots == 0 then
            ace_map.game_options[category] = nil
        else
            sort_nodes(roots)
            set_namepaths(roots, { category })
        end
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

local function get_weapon_map()
    local lang = game_lang.get_language()
    for name, id in e.iter("app.WeaponDef.TYPE") do
        ace_map.weaponid_name_to_local_name[name] =
            game_lang.get_message_local(m.getWeaponName(id), lang, true)
    end
end

local function get_subtitles_map()
    local dict = s.get("app.DialogueManager")._DiaDataDict
    local entries = dict._entries

    util_game.do_something(entries, function(_, _, entry)
        local dialog_data_info = entry.value
        if dialog_data_info then
            local dialog_data = dialog_data_info:get_Setting()
            local npc_id = dialog_data:get_BeginNpcId()

            if npc_id == -1 then
                return
            end

            local msg_data = dialog_data:get_MsgData()
            local npc_name = m.getNpcName(npc_id)

            util_game.do_something(msg_data:getValues(), function(_, _, value)
                local guid = value:get_MessageText()
                local text = util_game.lang.get_message_local2(guid)
                if text ~= "" then
                    ace_map.subtitles[util_game.format_guid(guid)] = {
                        npc = { id = npc_id, name = npc_name },
                        text = util_game.lang.get_message_local2(guid),
                    }
                end
            end)
        end
    end)
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
            e.new("app.GUI020600.TYPE")
            e.new("app.PlayerDef.ButtonMask.USER")
            e.new("app.DialogueDef.ACTOR_TYPE")
            e.new("app.Option.DEVICE")
            e.new("app.Option.CATEGORY")
            e.new("app.Option.TYPE")
            e.new("app.Option.SCENE")
            e.new("app.WeaponDef.KIREAJI_TYPE")
            e.new("app.QuestDef.EM_REWARD_RANK")
        end)
    then
        return false
    end

    get_hud_map()
    set_additional_hud()
    get_weapon_map()
    get_option_map()
    get_log_id_text()
    get_subtitles_map()

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
