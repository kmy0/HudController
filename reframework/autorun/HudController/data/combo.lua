---@class (exact) ComboRegistry
---@field hud_elem Combo
---@field hud Combo
---@field item_decide Combo
---@field control_point Combo
---@field blend Combo
---@field alpha_channel Combo
---@field option_bind Combo
---@field option_mod_bind Combo
---@field bind_action_type Combo
---@field segment Combo
---@field page_alignment Combo
---@field enemy_msg_type Combo
---@field config Combo
---@field config_backup Combo
---@field log_id Combo
---@field map_filter Combo
---@field condition Combo
---@field elem_cache Combo
---@field system_log Combo
---@field enemy_log Combo
---@field camp_log Combo
---@field chat_log Combo
---@field lobby_log Combo
---@field auto_id Combo
---@field object_category Combo
---@field npc_type Combo
---@field enemy_type Combo
---@field panel_type Combo
---@field gossip_type Combo
---@field nameplate_type Combo
---@field subtitles Combo
---@field npc Combo
---@field dialogue_type Combo
---@field dialogue_actor_type Combo
---@field sfx_game_object Combo
---@field elem_option Combo
---@field option_game_bind Combo
---@field enable_disable Combo
---@field bind_trigger_type Combo
---@field option_user_bind Combo

---@class ComboData
---@field combo ComboRegistry
---@field combo_cache table<string, Combo>
---@field bind_condition_options table<string, Combo>

local combo = require("HudController.util.imgui.combo")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local game_lang = require("HudController.util.game.lang")
local user_option = require("HudController.hud.user.option")
local util_misc = require("HudController.util.misc.init")
local util_ref = require("HudController.util.ref.init")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.bind.condition.init"
local bind_condition = util_misc.lazy_require("HudController.hud.bind.condition.init")

local ace_map = data.ace.map
local mod = data.mod

local function sort_by_key(a, b)
    return a.key < b.key
end

local function sort_by_value(a, b)
    return a.value < b.value
end

local function map_key(_, key)
    return key
end

---@class ComboData
local this = {
    bind_condition_options = {},
    combo_cache = {},
    combo = {
        hud_elem = combo:new(nil, {
            sort_fn = function(a, b)
                local enum = e.get("app.GUIHudDef.TYPE")
                return enum[a.key] < enum[b.key]
            end,

            translate_fn = function(key)
                return ace_map.hudid_name_to_local_name[key]
            end,
        }),
        hud = combo:new(nil, {
            sort_fn = sort_by_key,
            map_fn = function(value)
                return value.name
            end,
        }),
        item_decide = combo:new(nil, {
            map_fn = function(value)
                return value.value
            end,
            sort_fn = function(a, b)
                return mod.map.combo_item_decide[a.key].sort < mod.map.combo_item_decide[b.key].sort
            end,
            translate_fn = function(key)
                if key == "option_disable" then
                    return config.lang:tr("hud.option_disable")
                end
                return mod.map.combo_item_decide[key].value
            end,
        }),
        control_point = combo:new(nil, {
            sort_fn = sort_by_key,
        }),
        blend = combo:new(nil, {
            sort_fn = sort_by_key,
        }),
        alpha_channel = combo:new(nil, {
            sort_fn = sort_by_key,
        }),
        option_bind = combo:new(mod.map.options_hud, {
            sort_fn = sort_by_key,
            translate_fn = function(key)
                return config.lang:tr("hud." .. mod.map.options_hud[key])
            end,
        }),
        option_mod_bind = combo:new(mod.map.options_mod, {
            sort_fn = sort_by_key,
            translate_fn = function(key)
                return config.lang:tr("menu.config." .. mod.map.options_mod[key])
            end,
        }),
        segment = combo:new(nil, {
            sort_fn = sort_by_key,
        }),
        page_alignment = combo:new(nil, {
            sort_fn = sort_by_key,
        }),
        enemy_msg_type = combo:new(nil, {
            sort_fn = sort_by_value,
        }),
        config = combo:new(),
        config_backup = combo:new(),
        bind_action_type = combo:new(
            ---@diagnostic disable-next-line: no-unknown
            util_table.filter(mod.enum.action_type, function(_, value)
                return value ~= mod.enum.action_type.NONE
            end),
            {
                sort_fn = sort_by_key,
                translate_fn = function(key)
                    return config.lang:tr("menu.bind.key.action_type." .. key)
                end,
            }
        ),
        log_id = combo:new(nil, {
            sort_fn = function(a, b)
                return tonumber(a.key) < tonumber(b.key)
            end,
            map_fn = function(value)
                local id = e.get("app.ChatDef.LOG_ID")[value]
                return string.format(
                    "[%s]  %s",
                    id,
                    util_misc.trunc_string(ace_map.log_id_to_text[tonumber(id)], 50)
                )
            end,
        }),
        map_filter = combo:new(nil, {
            sort_fn = function(a, b)
                if util_table.empty(mod.map.combo_map_filter) then
                    return a.key < b.key
                end
                return mod.map.combo_map_filter[a.key] < mod.map.combo_map_filter[b.key]
            end,
            translate_fn = function(key)
                if key == "option_disable" then
                    return config.lang:tr("hud.option_disable")
                end
                return key
            end,
        }),
        condition = combo:new(nil, {
            translate_fn = function(key)
                return bind_condition.conditions[key]:get_display_name()
            end,
            sort_fn = sort_by_value,
        }),
        elem_cache = combo:new(mod.enum.elem_cache, {
            translate_fn = function(key)
                return config.lang:tr("debug.combo_elem_cache_values." .. key)
            end,
            sort_fn = function(a, b)
                return mod.enum.elem_cache[a.key] < mod.enum.elem_cache[b.key]
            end,
        }),
        system_log = combo:new(nil, {
            sort_fn = sort_by_value,
            map_fn = map_key,
        }),
        enemy_log = combo:new(nil, {
            sort_fn = sort_by_value,
            map_fn = map_key,
        }),
        camp_log = combo:new(nil, {
            sort_fn = sort_by_value,
            map_fn = map_key,
        }),
        chat_log = combo:new(nil, {
            sort_fn = sort_by_value,
            map_fn = map_key,
        }),
        lobby_log = combo:new(nil, {
            sort_fn = sort_by_value,
            map_fn = map_key,
        }),
        auto_id = combo:new(nil, {
            sort_fn = sort_by_value,
            translate_fn = function(key, _)
                local ret = ace_map.auto_id_to_text[e.get("app.Communication.AUTO_ID")[key]] --[[@as string]]
                if not ret then
                    ret = config.lang:tr("misc.text_unknown")
                end
                return ret
            end,
            map_fn = map_key,
        }),
        object_category = combo:new(nil, {
            sort_fn = sort_by_value,
            map_fn = map_key,
        }),
        npc_type = combo:new(nil, {
            sort_fn = sort_by_value,
            map_fn = map_key,
        }),
        enemy_type = combo:new(nil, {
            sort_fn = sort_by_value,
        }),
        panel_type = combo:new(nil, {
            sort_fn = sort_by_value,
            map_fn = map_key,
        }),
        gossip_type = combo:new(nil, {
            sort_fn = sort_by_value,
            map_fn = map_key,
        }),
        nameplate_type = combo:new(nil, {
            sort_fn = sort_by_value,
            map_fn = map_key,
        }),
        subtitles = combo:new(nil, {
            sort_fn = sort_by_value,
            map_fn = function(value, key)
                local npc_name = ace_map.subtitles[key].npc.name
                if npc_name == "" then
                    npc_name = config.lang:tr("misc.text_unknown")
                end
                return string.format(
                    "[%s]  %s##%s",
                    npc_name,
                    util_misc.trunc_string(value, 50),
                    key
                )
            end,
        }),
        npc = combo:new(nil, {
            sort_fn = sort_by_value,
            map_fn = function(value, key)
                if value == "" then
                    value = config.lang:tr("misc.text_unknown")
                end
                return string.format("%s##%s", value, key)
            end,
        }),
        dialogue_type = combo:new(nil, {
            sort_fn = sort_by_value,
            map_fn = map_key,
        }),
        dialogue_actor_type = combo:new(nil, {
            sort_fn = sort_by_value,
            map_fn = map_key,
        }),
        sfx_game_object = combo:new(nil, {
            sort_fn = sort_by_key,
            swap_fn = function(self, key_to_value, current_index, disabled_keys)
                ---@diagnostic disable-next-line: no-unknown
                key_to_value[0] = config.lang:tr("misc.text_disabled")
                return combo.swap(self, key_to_value, current_index, disabled_keys)
            end,
        }),
        elem_option = combo:new(nil, {
            sort_fn = function(a, b)
                local enum = e.get("app.GUIHudDef.TYPE")
                return (enum[a.key] or -1) < (enum[b.key] or -1)
            end,

            translate_fn = function(_, value)
                return config.lang:try_replace(value)
            end,
        }),
        option_game_bind = combo:new(nil, {
            sort_fn = sort_by_key,
        }),
        enable_disable = combo:new(nil, {
            sort_fn = sort_by_key,
        }),
        bind_trigger_type = combo:new(mod.enum.trigger_type, {
            sort_fn = sort_by_key,
            translate_fn = function(key)
                return config.lang:tr("menu.bind.key.trigger_type." .. key)
            end,
        }),
        option_user_bind = combo:new(nil, {
            sort_fn = function(a, b)
                return a.key.sort < b.key.sort
            end,
        }),
    },
}

function this.init_combo_condition()
    ---@type table<string, string>
    local names = {}
    for _, cond in pairs(bind_condition.conditions) do
        names[cond.condition_name] = cond.condition_name

        if cond.options then
            this.bind_condition_options[cond.condition_name] = combo:new(cond.options, {
                translate_fn = function(_, value)
                    return config.lang:try_replace(value)
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

function this.clear_cache()
    this.combo_cache = {}
end

function this.init_combo_option_game_bind()
    ---@type table<string, string>
    local res = {}
    local config_game_options = config.current.mod.game_options

    for k, _ in pairs(config_game_options.hud) do
        res[k] = ace_map.option[k].name_local
    end

    for _, v in pairs(config_game_options.elements) do
        for k, _ in pairs(v) do
            res[k] = ace_map.option[k].name_local
        end
    end

    this.combo.option_game_bind:swap(res)
end

function this.init_combo_option_user_bind()
    this.combo.option_user_bind:swap(user_option.get_combo_values())
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

---@param key string
---@param item_config_key string
---@param is_key_disabled (fun(item_config_key: string, key: any, value: string): boolean)?
function this.get_profile_combo(key, item_config_key, is_key_disabled)
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

---@return boolean
function this.init()
    -- choice
    this.combo.hud:swap(config.current.mod.hud)
    this.combo.hud_elem:swap(ace_map.hudid_name_to_local_name)
    -- config_selector
    this.combo.config:swap(config.selector.sorted)
    this.combo.config_backup:swap(config.selector.sorted_backup)
    -- scale9
    this.combo.control_point:swap(e.get("via.gui.ControlPoint").enum_to_field)
    this.combo.blend:swap(e.get("via.gui.BlendType").enum_to_field)
    this.combo.alpha_channel:swap(e.get("via.gui.AlphaChannelType").enum_to_field)
    -- itembar
    this.combo.item_decide:swap(mod.map.combo_item_decide)
    -- generic
    this.combo.segment:swap(
        util_table.filter(e.get("app.GUIDefApp.DRAW_SEGMENT").enum_to_field, function(_, value)
            return not value:match("RADAR.-")
        end)
    )
    -- text
    this.combo.page_alignment:swap(e.get("via.gui.PageAlignment").enum_to_field)
    -- notice
    this.combo.enemy_msg_type:swap(e.get("app.ChatDef.ENEMY_LOG_TYPE").enum_to_field)
    this.combo.log_id:swap(
        util_table.transform_items(e.get("app.ChatDef.LOG_ID").enum_to_field, function(key, _)
            return tostring(key)
        end)
    )
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
    -- minimap
    this.combo.map_filter:swap(mod.map.combo_map_filter_init)
    -- name_access
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
    -- name_other
    this.combo.nameplate_type:swap(
        util_table.merge({ ALL = -100 }, e.get("app.cGUIMemberPartsDef.MemberType").field_to_enum)
    )
    -- subtitles
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
    -- game_options
    this.combo.elem_option:swap(
        util_table.merge(
            { GLOBAL = config.lang.make_placeholder("hud_element.name.GLOBAL") },
            ace_map.hudid_name_to_local_name
        )
    )
    this.combo.enable_disable:swap({
        config.lang:tr("misc.text_enable"),
        config.lang:tr("misc.text_disable"),
    })

    this.init_combo_option_game_bind()
    this.init_combo_condition()
    this.init_combo_option_user_bind()
    this.translate_combo()

    return true
end

return this
