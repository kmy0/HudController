---@class GuiState
---@field combo GuiCombo
---@field bind_condition_options table<string, Combo>
---@field input_action string?
---@field listener NewBindListener?
---@field set ImguiConfigSet

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

---@class (exact) NewBindListener
---@field opt HudProfileConfig | string
---@field opt_name string
---@field listener BindListener
---@field collision string?

local bind_manager = require("HudController.hud.bind.init")
local combo = require("HudController.util.imgui.combo")
local config = require("HudController.config.init")
local config_set = require("HudController.util.imgui.config_set")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local game_lang = require("HudController.util.game.lang")
local gui_util = require("HudController.gui.util")
local util_misc = require("HudController.util.misc.init")
local util_ref = require("HudController.util.ref.init")
local util_table = require("HudController.util.misc.table")

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
                    "%s - %s",
                    id,
                    util_misc.trunc_string(ace_map.log_id_to_text[id], 50)
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
                local bind_condition = require("HudController.hud.bind_condition.init")
                return bind_condition.conditions[key]:get_display_name()
            end,
            sort_fn = function(a, b)
                return a.value < b.value
            end,
        }),
    },
    bind_condition_options = {},
    set = config_set:new(config),
}

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

---@param conditions ConditionBase[]
function this.init_condition_combo(conditions)
    ---@type table<string, string>
    local names = {}
    for _, cond in pairs(conditions) do
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
end

---@return boolean, string
function this.get_input()
    local changed = false
    changed, this.input_action =
        imgui.input_text(gui_util.tr("hud.input"), this.input_action, 1 << 6)
    return changed, this.input_action
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
    this.combo.log_id:swap(e.get("app.ChatDef.LOG_ID").enum_to_field)
    this.combo.map_filter:swap(mod.map.combo_map_filter_init)
    this.combo.hud:swap(config.current.mod.hud)
    this.translate_combo()
end

return this
