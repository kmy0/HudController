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
---@field subtitles Combo
---@field npc Combo
---@field dialogue_type Combo
---@field dialogue_actor_type Combo
---@field sfx_game_object Combo
---@field elem_option Combo

local bind_manager = require("HudController.hud.bind.key.init")
local combo = require("HudController.util.imgui.combo")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map
local mod = data.mod

---@module "HudController.hud.bind.condition.init"
local bind_condition = util_misc.lazy_require("HudController.hud.bind.condition.init")

local function sort_by_key(a, b)
    return a.key < b.key
end

local function sort_by_value(a, b)
    return a.value < b.value
end

local function map_key(_, key)
    return key
end

---@class GuiCombo
local this = {
    hud_elem = combo:new(nil, {
        sort_fn = function(a, b)
            local enum = e.get("app.GUIHudDef.TYPE")
            return enum[a.key] < enum[b.key]
        end,

        translate_fn = function(key)
            local val = ace_map.hudid_name_to_local_name[key]
            if val == ace_map.tr_flag then
                return config.lang:tr("hud_element.name." .. key)
            end
            return val
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
            return string.format("[%s]  %s##%s", npc_name, util_misc.trunc_string(value, 50), key)
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

        translate_fn = function(key, value)
            if value == ace_map.tr_flag then
                return config.lang:tr("hud_element.name." .. key)
            end
            return value
        end,
    }),
}

return this
