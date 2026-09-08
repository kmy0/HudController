local ace = require("HudController.data.ace")
local e = require("HudController.util.game.enum")
local util_game = require("HudController.util.game.init")
local util_table = require("HudController.util.misc.table")

local this = {}

local module_aliases = {
    ["HudController.hud.bind.init"] = "HudController.hud.bind.key.init",
    ["HudController.hud.bind.manager"] = "HudController.hud.bind.key.manager",
    ["HudController.hud.bind.monitor"] = "HudController.hud.bind.key.monitor",
    ["HudController.hud.bind_condition.init"] = "HudController.hud.bind.condition.init",
    ["HudController.hud.bind_condition.conditions.combat"] = "HudController.hud.bind.condition.conditions.combat",
    ["HudController.hud.bind_condition.conditions.custom"] = "HudController.hud.bind.condition.conditions.custom",
    ["HudController.hud.bind_condition.conditions.game_mode"] = "HudController.hud.bind.condition.conditions.game_mode",
    ["HudController.hud.bind_condition.conditions.village"] = "HudController.hud.bind.condition.conditions.village",
    ["HudController.hud.bind_condition.conditions.weapon"] = "HudController.hud.bind.condition.conditions.weapon",
}

local table_aliases = {
    remove = "filter_inplace",
    contains = "contains_any",
    merge_into = "update",
    merge_t = "merge",
    merge2 = "merge_protected",
    merge2_t = "merge_protected",
    array_merge = "extend",
    array_merge_t = "extend",
    array_merge_copy = "concat",
    array_merge_copy_t = "concat",
    merge_nested_array = "extend_nested",
    map_array = "index_by",
    map_table = "transform_items",
    pop_item = "pop",
    value = "find_value",
    key = "find_key",
    print = "pprint",
    split = "groupby",
    parse_key = "parse_path_key",
    split_key = "split_path",
    get_by_key = "get_by_path",
    set_by_key = "set_by_path",
    normalize = "unwrap_first",
    array_to_map = "index_by_value",
    to_string = "repr",
    consume = "collect",
    consume_map = "collect_pairs",
    map_to_array = "entries",
    pick = "select_keys",
    array_to_array = "transform",
}

local function register_module_aliases()
    for old, new in pairs(module_aliases) do
        ---@diagnostic disable-next-line: no-unknown
        package.preload[old] = function()
            return require(new)
        end
    end
end

local function register_legacy_modules()
    package.preload["HudController.util.game.data"] = function()
        return {
            reverse_lookup = util_table.reverse_lookup,
        }
    end

    package.preload["HudController.util.game.bind.enum"] = function()
        return {
            input_device = e.get("ace.GUIDef.INPUT_DEVICE").enum_to_field,
            pad_btn = e.get("ace.ACE_PAD_KEY.BITS").enum_to_field,
            kb_btn = e.get("ace.ACE_MKB_KEY.INDEX").enum_to_field,
        }
    end
end

local function restore_legacy_fields()
    for old, new in pairs(table_aliases) do
        ---@diagnostic disable-next-line: inject-field, no-unknown
        util_table[old] = util_table[new]
    end

    ---@diagnostic disable-next-line: inject-field
    ace.enum = {
        hud = e.get("app.GUIHudDef.TYPE").enum_to_field,
        weapon = e.get("app.WeaponDef.TYPE").enum_to_field,
        option = e.get("app.Option.ID").enum_to_field,
        hud_display = e.get("app.GUIHudDef.DISPLAY").enum_to_field,
        dialog = e.get("app.DialogueType.TYPE").enum_to_field,
        hunter_continue_flag = e.get("app.HunterDef.CONTINUE_FLAG").enum_to_field,
        input_device = e.get("ace.GUIDef.INPUT_DEVICE").enum_to_field,
        gui_func = e.get("app.GUIFunc.TYPE").enum_to_field,
        button_mask = e.get("app.PlayerDef.ButtonMask.USER").enum_to_field,
        system_msg = e.get("app.ChatDef.SYSTEM_MSG_TYPE").enum_to_field,
        send_target = e.get("app.ChatDef.SEND_TARGET").enum_to_field,
        control_point = e.get("via.gui.ControlPoint").enum_to_field,
        blend = e.get("via.gui.BlendType").enum_to_field,
        alpha_channel = e.get("via.gui.AlphaChannelType").enum_to_field,
        stock_type = e.get("app.ItemUtil.STOCK_TYPE").enum_to_field,
        object_access_category = e.get("app.GUIAccessIconControl.OBJECT_CATEGORY").enum_to_field,
        porter_continue_flag = e.get("app.PorterDef.CONTINUE_FLAG").enum_to_field,
        npc_id = e.get("app.NpcDef.ID").enum_to_field,
        npc_continue_flag = e.get("app.NpcDef.CHARA_CONTINUE_FLAG").enum_to_field,
        quest_gui_type = e.get("app.GUI020201.TYPE").enum_to_field,
        nameplate_type = e.get("app.cGUIMemberPartsDef.MemberType").enum_to_field,
        bullet_slider_status = e.get("app.GUI020007.BulletSliderStatus").enum_to_field,
        draw_segment = e.get("app.GUIDefApp.DRAW_SEGMENT").enum_to_field,
        quest_result_mode = e.get("app.cGUIQuestResultInfo.MODE").enum_to_field,
        gui_continue_flag = e.get("app.GUIManager.APP_CONTINUE_FLAG").enum_to_field,
        gui_id = e.get("app.GUIID.ID").enum_to_field,
        subtitles_category = e.get("app.GUI020400.SUBTITLES_CATEGORY").enum_to_field,
        enemy_continue_flag = e.get("app.EnemyDef.CONTINUE_FLAG").enum_to_field,
        damage_state = e.get("app.GUI020020.State").enum_to_field,
        critical_state = e.get("app.GUI020020.CRITICAL_STATE").enum_to_field,
        slinger_ammo = e.get("app.HunterDef.SLINGER_AMMO_TYPE").enum_to_field,
        page_alignment = e.get("via.gui.PageAlignment").enum_to_field,
        enemy_log = e.get("app.ChatDef.ENEMY_LOG_TYPE").enum_to_field,
        camp_log = e.get("app.ChatDef.CAMP_LOG_TYPE").enum_to_field,
        chat_log = e.get("app.ChatDef.MSG_TYPE").enum_to_field,
        interact_npc_type = e.get("app.GUI020001PanelParams.NPC_TYPE").enum_to_field,
        interact_gossip_type = e.get("app.GUI020001PanelParams.GOSSIP_TYPE").enum_to_field,
        interact_panel_type = e.get("app.GUI020001PanelParams.PANEL_TYPE").enum_to_field,
        scar_state = e.get("app.cEmModuleScar.cScarParts.STATE").enum_to_field,
        sharpness_state = e.get("app.GUI020015.DEFAULT_STATUS").enum_to_field,
        target_access = e.get("app.TARGET_ACCESS_KEY.CATEGORY").enum_to_field,
        otomo_continue_flag = e.get("app.OtomoDef.CONTINUE_FLAG").enum_to_field,
        map_flow_flag = e.get("app.cGUIMapFlowCtrl.FLAG").enum_to_field,
        log_id = e.get("app.ChatDef.LOG_ID").enum_to_field,
        ai_target_state = e.get("app.EnemyDef.AI_TARGET_STATE").enum_to_field,
        auto_id = e.get("app.Communication.AUTO_ID").enum_to_field,
    }

    ---@diagnostic disable-next-line: no-unknown
    util_game.data = require("HudController.util.game.data")
    ---@diagnostic disable-next-line: no-unknown
    util_game.bind.enum = require("HudController.util.game.bind.enum")
end

---@return boolean
function this.init()
    register_module_aliases()
    register_legacy_modules()
    restore_legacy_fields()

    return true
end

return this
