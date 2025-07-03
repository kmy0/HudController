local this = {
    ace = require("HudController.data.ace"),
    mod = require("HudController.data.mod"),
}

local ace_misc = require("HudController.util.ace.misc")
local config = require("HudController.config")
local game_data = require("HudController.util.game.data")
local game_lang = require("HudController.util.game.lang")
local m = require("HudController.util.ref.methods")
local s = require("HudController.util.ref.singletons")
local util_game = require("HudController.util.game")
local util_table = require("HudController.util.misc.table")

local ace_map = this.ace.map
local ace_enum = this.ace.enum
local rl = util_game.data.reverse_lookup

---@return boolean
local function get_hud_setting()
    game_data.get_enum("app.GUIHudDef.TYPE", ace_enum.hud)

    local var_setting = s.get("app.VariousDataManager"):get_Setting()
    local gui_data = var_setting:get_GUIVariousData()
    local hud_data = gui_data:get_HudDisplayOptionData()
    local lang = game_lang.get_language()

    for id, name in pairs(ace_enum.hud) do
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

        if ace_enum.hud[hudid] then
            local guiid = setting:get_Id()
            util_table.insert_nested_value(ace_map.hudid_to_guiid, { hudid }, guiid)
            ace_map.guiid_to_hudid[guiid] = hudid
        end
    end
end

local function set_additional_hud()
    for i = 1, #ace_map.additional_hud do
        local name = ace_map.additional_hud[i]
        local guiid_name = ace_map.additional_hud_to_guiid_name[name]
        local guiid = rl(ace_enum.gui_id, guiid_name)
        local enum = ace_map.additional_hud_index + i

        ace_enum.hud[enum] = name
        ace_map.hudid_to_can_hide[enum] = false
        ace_map.hudid_name_to_local_name[name] = ace_map.hud_tr_flag
        ace_map.guiid_to_hudid[guiid] = enum
        util_table.insert_nested_value(ace_map.hudid_to_guiid, { enum }, guiid)
    end
end

local function get_weapon_map()
    local lang = game_lang.get_language()
    ---@type WeaponBindConfig
    local base = {
        weapon_id = -1,
        enabled = false,
        name = "",
        combat_in = { hud_key = -1, combo = 1 },
        combat_out = { hud_key = -1, combo = 1 },
    }

    for id, name in pairs(ace_enum.weapon) do
        ace_map.weaponid_name_to_local_name[name] = game_lang.get_message_local(m.getWeaponName(id), lang, true)
        local weapon_base = util_table.deep_copy(base)
        weapon_base.weapon_id = id
        weapon_base.name = name

        config.current.mod.bind.weapon.singleplayer[name] = util_table.merge_t(
            util_table.deep_copy(weapon_base),
            config.current.mod.bind.weapon.singleplayer[name] or {}
        )
        config.current.mod.bind.weapon.multiplayer[name] = util_table.merge_t(
            util_table.deep_copy(weapon_base),
            config.current.mod.bind.weapon.multiplayer[name] or {}
        )
    end

    local global_name = "GLOBAL"
    local weapon_base = util_table.deep_copy(base)
    weapon_base.name = global_name

    config.current.mod.bind.weapon.singleplayer[global_name] = util_table.merge_t(
        util_table.deep_copy(weapon_base),
        config.current.mod.bind.weapon.singleplayer[global_name] or {}
    )
    config.current.mod.bind.weapon.multiplayer[global_name] = util_table.merge_t(
        util_table.deep_copy(weapon_base),
        config.current.mod.bind.weapon.multiplayer[global_name] or {}
    )
end

local function get_option_map()
    local lang = game_lang.get_language()
    for id, name in pairs(ace_enum.option) do
        local option_data = m.getOptionData(id)

        if not option_data then
            goto continue
        end

        ace_map.option[name] = {
            id = id,
            name_local = game_lang.get_message_local(option_data:get_MsgTitle(), lang, true),
            items = {},
        }

        util_game.do_something(option_data:get_Items(), function(system_array, index, value)
            table.insert(
                ace_map.option[name].items,
                { index = index, name_local = game_lang.get_message_local(value:get_MsgTitle(), lang, true) }
            )
        end)
        ::continue::
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

    game_data.get_enum("app.GUI020018.GUIDE_PANEL_TYPE", ace_enum.guide_panel)
    game_data.get_enum("via.gui.RegionFitType", ace_enum.region_fit)
    game_data.get_enum("app.WeaponDef.TYPE", ace_enum.weapon)
    game_data.get_enum("app.Option.ID", ace_enum.option)
    game_data.get_enum("app.GUIHudDef.DISPLAY", ace_enum.hud_display)
    game_data.get_enum("app.DialogueType.TYPE", ace_enum.dialog)
    game_data.get_enum("app.HunterDef.CONTINUE_FLAG", ace_enum.hunter_continue_flag)
    game_data.get_enum("ace.GUIDef.INPUT_DEVICE", ace_enum.input_device)
    game_data.get_enum("app.GUIFunc.TYPE", ace_enum.gui_func)
    game_data.get_enum("app.PlayerDef.ButtonMask.USER", ace_enum.button_mask)
    game_data.get_enum("ace.ACE_MKB_KEY.INDEX", ace_enum.kb_btn)
    game_data.get_enum("app.ChatDef.SYSTEM_MSG_TYPE", ace_enum.system_msg)
    game_data.get_enum("app.ChatDef.SEND_TARGET", ace_enum.send_target)
    game_data.get_enum("via.gui.ControlPoint", ace_enum.control_point)
    game_data.get_enum("via.gui.BlendType", ace_enum.blend)
    game_data.get_enum("via.gui.AlphaChannelType", ace_enum.alpha_channel)
    game_data.get_enum("app.ItemUtil.STOCK_TYPE", ace_enum.stock_type)
    game_data.get_enum("app.GUIAccessIconControl.OBJECT_CATEGORY", ace_enum.object_access_category)
    game_data.get_enum("app.PorterDef.CONTINUE_FLAG", ace_enum.porter_continue_flag)
    game_data.get_enum("ace.ActionDef.UPDATE_RESULT", ace_enum.action_update_result)
    game_data.get_enum("app.NpcDef.ID", ace_enum.npc_id)
    game_data.get_enum("app.NpcDef.CHARA_CONTINUE_FLAG", ace_enum.npc_continue_flag)
    game_data.get_enum("app.GUI020201.TYPE", ace_enum.quest_gui_type)
    game_data.get_enum("app.cGUIMemberPartsDef.MemberType", ace_enum.nameplate_type)
    game_data.get_enum("app.GUI020007.BulletSliderStatus", ace_enum.bullet_slider_status)
    game_data.get_enum("app.EnemyDef.CONTINUE_FLAG", ace_enum.enemy_continue_flag)
    game_data.get_enum("app.GUIDefApp.DRAW_SEGMENT", ace_enum.draw_segment, nil, { "LOWEST", "HIGHEST" })
    game_data.get_enum("app.cGUIQuestResultInfo.MODE", ace_enum.quest_result_mode)
    game_data.get_enum("app.GUIManager.APP_CONTINUE_FLAG", ace_enum.gui_continue_flag)
    game_data.get_enum("app.GUIID.ID", ace_enum.gui_id)
    game_data.get_enum("app.GUI020400.SUBTITLES_CATEGORY", ace_enum.subtitles_category)

    if
        util_table.any(this.ace.enum --[[@as table<string, table<integer, string>>]], function(key, value)
            return util_table.empty(value)
        end)
    then
        return false
    end

    get_hud_map()
    set_additional_hud()
    get_weapon_map()
    get_option_map()

    util_table.do_something({ ace_enum.subtitles_category }, function(t, key, value)
        util_table.do_something(value, function(_, _, name)
            ace_map.no_lang_key[name] = true
        end)
    end)

    return true
end

return this
