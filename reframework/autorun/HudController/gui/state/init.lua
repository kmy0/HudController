---@class GuiState
---@field combo GuiCombo
---@field bind_condition_options table<string, Combo>
---@field input {buf: string, type: string, key: any?}?
---@field listener NewBindListener?
---@field set ImguiConfigSet
---@field combo_cache table<string, Combo>

---@class (exact) HudBindOpt
---@field hud integer
---@field profile integer

---@class (exact) NewBindListener
---@field opt HudBindOpt | string
---@field opt_name string
---@field listener BindListener
---@field collision string?

local combo = require("HudController.util.imgui.combo")
local combo_state = require("HudController.gui.state.combo")
local config = require("HudController.config.init")
local config_set = require("HudController.util.imgui.config_set")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local game_lang = require("HudController.util.game.lang")
local util_gui = require("HudController.gui.util")
local util_misc = require("HudController.util.misc.init")
local util_ref = require("HudController.util.ref.init")
local util_table = require("HudController.util.misc.table")
---@module "HudController.hud.bind.condition.init"
local bind_condition = util_misc.lazy_require("HudController.hud.bind.condition.init")

local ace_map = data.ace.map
local mod = data.mod

---@class GuiState
local this = {
    combo = combo_state,
    bind_condition_options = {},
    set = config_set:new(config),
    combo_cache = {},
}

local function init_condition_combo()
    ---@type table<string, string>
    local names = {}
    for _, cond in pairs(bind_condition.conditions) do
        names[cond.condition_name] = cond.condition_name

        if cond.options then
            this.bind_condition_options[cond.condition_name] = combo:new(cond.options, {
                translate_fn = function(_, value)
                    if config.lang:exists(value) then
                        return config.lang:tr(value)
                    end
                    return value
                end,
                sort_fn = function(a, b)
                    return a.key < b.key
                end,
            })
        end
    end

    this.combo.condition:swap(names)
    this.combo.condition:translate()

    for _, cond_set in pairs(config.current.mod.bind.condition.hud) do
        cond_set.combo_condition = math.min(cond_set.combo_condition, this.combo.condition:size())
    end
end

function this.translate_combo()
    for _, c in
        pairs(this.combo --[==[@as Combo[]]==])
    do
        c:translate()
    end

    for _, c in pairs(this.bind_condition_options) do
        c:translate()
    end
end

---@return boolean, string
function this.get_input()
    local changed = false
    changed, this.input.buf = imgui.input_text(util_gui.tr("hud.input"), this.input.buf, 1 << 6)
    return changed, this.input.buf
end

function this.clear_cache()
    this.combo_cache = {}
end

---@param key string
---@param item_config_key string
---@param is_key_disabled (fun(item_config_key: string, key: any, value: string): boolean)?
function this.get_cached_combo(key, item_config_key, is_key_disabled)
    local cache_key = string.format("COMBO|%s|%s", key, item_config_key)
    local ret = this.combo_cache[cache_key]
    if not ret then
        this.combo_cache[cache_key] = util_table.deep_copy(this.combo[key])
        ret = this.combo_cache[cache_key]

        if is_key_disabled then
            local disabled_items = {}
            for _, map in ipairs(ret.map) do
                if is_key_disabled(item_config_key, map.key, map.value) then
                    table.insert(disabled_items, map.key)
                end
            end

            ret:disable_items(disabled_items)
        end
    end

    return ret
end

function this.init_combo_map_icon_filter()
    if not util_table.empty(mod.map.combo_map_filter) then
        return
    end

    local lang = game_lang.get_language()
    ---@type table<string, integer>
    local res = {}
    for k, v in pairs(mod.map.combo_map_filter_init) do
        if v == -1 then
            res[k] = v
            goto continue
        end

        local guid = util_ref.value_type("System.Guid")
        guid = guid:Parse(k)
        local str = game_lang.get_message_local(guid, lang, true)
        if str == "" then
            return
        end

        res[str] = v
        ::continue::
    end

    mod.map.combo_map_filter = res
    this.combo.map_filter:swap(mod.map.combo_map_filter)
    this.combo.map_filter:translate()
end

function this.init()
    this.combo.hud_elem:swap(ace_map.hudid_name_to_local_name)
    this.combo.control_point:swap(e.get("via.gui.ControlPoint").enum_to_field)
    this.combo.blend:swap(e.get("via.gui.BlendType").enum_to_field)

    this.combo.alpha_channel:swap(e.get("via.gui.AlphaChannelType").enum_to_field)
    this.combo.item_decide:swap(mod.map.combo_item_decide)
    this.combo.segment:swap(
        util_table.filter(e.get("app.GUIDefApp.DRAW_SEGMENT").enum_to_field, function(_, value)
            return not value:match("RADAR.-")
        end)
    )
    this.combo.page_alignment:swap(e.get("via.gui.PageAlignment").enum_to_field)
    this.combo.enemy_msg_type:swap(e.get("app.ChatDef.ENEMY_LOG_TYPE").enum_to_field)
    this.combo.config:swap(config.selector.sorted)
    this.combo.config_backup:swap(config.selector.sorted_backup)
    this.combo.log_id:swap(
        util_table.transform_items(e.get("app.ChatDef.LOG_ID").enum_to_field, function(key, _)
            return tostring(key)
        end)
    )
    this.combo.map_filter:swap(mod.map.combo_map_filter_init)
    this.combo.hud:swap(config.current.mod.hud)
    this.combo.system_log:swap(
        util_table.merge({ ALL = -100 }, e.get("app.ChatDef.SYSTEM_MSG_TYPE").field_to_enum)
    )
    this.combo.enemy_log:swap(e.get("app.ChatDef.ENEMY_LOG_TYPE").field_to_enum)
    this.combo.camp_log:swap(e.get("app.ChatDef.CAMP_LOG_TYPE").field_to_enum)
    this.combo.chat_log:swap(
        util_table.merge({ ALL = -100 }, e.get("app.ChatDef.MSG_TYPE").field_to_enum)
    )
    this.combo.lobby_log:swap(e.get("app.ChatDef.SEND_TARGET").field_to_enum)
    this.combo.auto_id:swap(e.get("app.Communication.AUTO_ID").field_to_enum)
    this.combo.object_category:swap(
        util_table.merge(
            { ALL = -100 },
            e.get("app.GUIAccessIconControl.OBJECT_CATEGORY").field_to_enum
        )
    )
    this.combo.npc_type:swap(e.get("app.GUI020001PanelParams.NPC_TYPE").field_to_enum)
    this.combo.enemy_type:swap({ "BOSS", "ZAKO", "ANIMAL" })
    this.combo.panel_type:swap(e.get("app.GUI020001PanelParams.PANEL_TYPE").field_to_enum)
    this.combo.gossip_type:swap(e.get("app.GUI020001PanelParams.GOSSIP_TYPE").field_to_enum)
    this.combo.nameplate_type:swap(
        util_table.merge({ ALL = -100 }, e.get("app.cGUIMemberPartsDef.MemberType").field_to_enum)
    )
    this.combo.npc:swap(util_table.collect_any(ace_map.subtitles, function(_, value)
        return tostring(value.npc.id)
    end, function(_, value)
        return value.npc.name
    end))
    this.combo.subtitles:swap(util_table.collect_any(ace_map.subtitles, function(key, _)
        return key
    end, function(_, value)
        return value.text
    end))
    this.combo.dialogue_type:swap(e.get("app.DialogueType.TYPE").field_to_enum)
    this.combo.dialogue_actor_type:swap(e.get("app.DialogueDef.ACTOR_TYPE").field_to_enum)
    this.combo.sfx_game_object:swap({})
    this.combo.elem_option:swap(
        util_table.merge({ GLOBAL = ace_map.hud_tr_flag }, ace_map.hudid_name_to_local_name)
    )

    init_condition_combo()
    this.translate_combo()
end

return this
