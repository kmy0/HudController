---@class GuiState
---@field combo GuiCombo
---@field bind_condition_options table<string, Combo>
---@field input {buf: string, type: string, key: any?}?
---@field listener NewBindListener?
---@field set ImguiConfigSet
---@field combo_cache table<string, Combo>

---@class (exact) GuiCombo
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

---@class (exact) HudBindOpt
---@field hud integer
---@field profile integer

---@class (exact) NewBindListener
---@field opt HudBindOpt | string
---@field opt_name string
---@field listener BindListener
---@field collision string?

local bind_manager = require("HudController.hud.bind.key.init")
local combo = require("HudController.util.imgui.combo")
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
    combo = {
        hud_elem = combo:new(nil, {
            sort_fn = function(a, b)
                local enum = e.get("app.GUIHudDef.TYPE")
                return enum[a.key] < enum[b.key]
            end,

            translate_fn = function(key)
                local val = ace_map.hudid_name_to_local_name[key]
                if val == ace_map.hud_tr_flag then
                    return config.lang:tr("hud_element.name." .. key)
                end
                return val
            end,
        }),
        hud = combo:new(nil, {
            sort_fn = function(a, b)
                return a.key < b.key
            end,
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
            sort_fn = function(a, b)
                return a.key < b.key
            end,
        }),
        blend = combo:new(nil, {
            sort_fn = function(a, b)
                return a.key < b.key
            end,
        }),
        alpha_channel = combo:new(nil, {
            sort_fn = function(a, b)
                return a.key < b.key
            end,
        }),
        option_bind = combo:new(mod.map.options_hud, {
            sort_fn = function(a, b)
                return a.key < b.key
            end,
            translate_fn = function(key)
                return config.lang:tr("hud." .. mod.map.options_hud[key])
            end,
        }),
        option_mod_bind = combo:new(mod.map.options_mod, {
            sort_fn = function(a, b)
                return a.key < b.key
            end,
            translate_fn = function(key)
                return config.lang:tr("menu.config." .. mod.map.options_mod[key])
            end,
        }),
        segment = combo:new(nil, {
            sort_fn = function(a, b)
                return a.key < b.key
            end,
        }),
        page_alignment = combo:new(nil, {
            sort_fn = function(a, b)
                return a.key < b.key
            end,
        }),
        enemy_msg_type = combo:new(nil, {
            sort_fn = function(a, b)
                return a.value < b.value
            end,
        }),
        config = combo:new(),
        config_backup = combo:new(),
        bind_action_type = combo:new(
            util_table.filter(bind_manager.action_type, function(_, value)
                return value ~= bind_manager.action_type.NONE
            end),
            {
                sort_fn = function(a, b)
                    return a.key < b.key
                end,
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
                local bind_condition = require("HudController.hud.bind.condition.init")
                return bind_condition.conditions[key]:get_display_name()
            end,
            sort_fn = function(a, b)
                return a.value < b.value
            end,
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
            sort_fn = function(a, b)
                return a.value < b.value
            end,
            map_fn = function(_, key)
                return key
            end,
        }),
        enemy_log = combo:new(nil, {
            sort_fn = function(a, b)
                return a.value < b.value
            end,
            map_fn = function(_, key)
                return key
            end,
        }),
        camp_log = combo:new(nil, {
            sort_fn = function(a, b)
                return a.value < b.value
            end,
            map_fn = function(_, key)
                return key
            end,
        }),
        chat_log = combo:new(nil, {
            sort_fn = function(a, b)
                return a.value < b.value
            end,
            map_fn = function(_, key)
                return key
            end,
        }),
        lobby_log = combo:new(nil, {
            sort_fn = function(a, b)
                return a.value < b.value
            end,
            map_fn = function(_, key)
                return key
            end,
        }),
        auto_id = combo:new(nil, {
            sort_fn = function(a, b)
                return a.value < b.value
            end,
            translate_fn = function(key, _)
                local ret = ace_map.auto_id_to_text[e.get("app.Communication.AUTO_ID")[key]] --[[@as string]]
                if not ret then
                    ret = config.lang:tr("misc.text_unknown")
                end
                return ret
            end,
            map_fn = function(_, key)
                return key
            end,
        }),
        object_category = combo:new(nil, {
            sort_fn = function(a, b)
                return a.value < b.value
            end,
            map_fn = function(_, key)
                return key
            end,
        }),
        npc_type = combo:new(nil, {
            sort_fn = function(a, b)
                return a.value < b.value
            end,
            map_fn = function(_, key)
                return key
            end,
        }),
        enemy_type = combo:new(nil, {
            sort_fn = function(a, b)
                return a.value < b.value
            end,
            map_fn = function(_, key)
                return key
            end,
        }),
        panel_type = combo:new(nil, {
            sort_fn = function(a, b)
                return a.value < b.value
            end,
            map_fn = function(_, key)
                return key
            end,
        }),
        gossip_type = combo:new(nil, {
            sort_fn = function(a, b)
                return a.value < b.value
            end,
            map_fn = function(_, key)
                return key
            end,
        }),
        nameplate_type = combo:new(nil, {
            sort_fn = function(a, b)
                return a.value < b.value
            end,
            map_fn = function(_, key)
                return key
            end,
        }),
    },
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
    this.combo.npc_type:swap(e.get("app.GUI020001PanelParams.NPC_TYPE"))
    this.combo.enemy_type:swap({ "BOSS", "ZAKO", "ANIMAL" })
    this.combo.panel_type:swap(e.get("app.GUI020001PanelParams.PANEL_TYPE"))
    this.combo.gossip_type:swap(e.get("app.GUI020001PanelParams.GOSSIP_TYPE"))
    this.combo.nameplate_type:swap(
        util_table.merge({ ALL = -100 }, e.get("app.cGUIMemberPartsDef.MemberType").field_to_enum)
    )

    init_condition_combo()
    this.translate_combo()
end

return this
