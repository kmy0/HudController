---@class GuiState
---@field combo GuiCombo
---@field input_action string?
---@field grid_ratio string[]
---@field expanded_itembar_control string[]
---@field listener NewBindListener?
---@field redo_win_pos RedoWinPos
---@field set ImguiConfigSet
---@field state {
--- l1_pressed: boolean,
--- }

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

---@class (exact) NewBindListener
---@field opt HudProfileConfig | string
---@field opt_name string
---@field listener BindListener
---@field collision string?

---@class (exact) RedoWinPos
---@field main boolean
---@field debug boolean

local ace_player = require("HudController.util.ace.player")
local bind_manager = require("HudController.hud.bind.init")
local combo = require("HudController.gui.combo")
local config = require("HudController.config.init")
local config_set = require("HudController.util.imgui.config_set")
local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local gui_util = require("HudController.gui.util")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local ace_map = data.ace.map
local mod = data.mod
local rl = game_data.reverse_lookup

---@class GuiState
local this = {
    combo = {
        hud_elem = combo:new(
            nil,
            function(a, b)
                return rl(ace_enum.hud, a.key) < rl(ace_enum.hud, b.key)
            end,
            nil,
            function(key)
                local val = ace_map.hudid_name_to_local_name[key]
                if val == ace_map.hud_tr_flag then
                    return config.lang:tr("hud_element.name." .. key)
                end
                return val
            end
        ),
        hud = combo:new(nil, function(a, b)
            return a.key < b.key
        end, function(value)
            return value.name
        end),
        item_decide = combo:new(nil, nil, function(value)
            return value.value
        end),
        control_point = combo:new(nil, function(a, b)
            return a.key < b.key
        end),
        blend = combo:new(nil, function(a, b)
            return a.key < b.key
        end),
        alpha_channel = combo:new(nil, function(a, b)
            return a.key < b.key
        end),
        option_bind = combo:new(
            mod.map.options_hud,
            function(a, b)
                return a.key < b.key
            end,
            nil,
            function(key)
                return config.lang:tr("hud." .. mod.map.options_hud[key])
            end
        ),
        option_mod_bind = combo:new(
            mod.map.options_mod,
            function(a, b)
                return a.key < b.key
            end,
            nil,
            function(key)
                return config.lang:tr("menu.config." .. mod.map.options_mod[key])
            end
        ),
        segment = combo:new(nil, function(a, b)
            return a.key < b.key
        end),
        page_alignment = combo:new(nil, function(a, b)
            return a.key < b.key
        end),
        enemy_msg_type = combo:new(nil, function(a, b)
            return a.value < b.value
        end),
        config = combo:new(),
        config_backup = combo:new(),
        bind_action_type = combo:new(
            util_table.filter(bind_manager.action_type, function(key, value)
                return value ~= bind_manager.action_type.NONE
            end),
            function(a, b)
                return a.key < b.key
            end,
            nil,
            function(key)
                return config.lang:tr("menu.bind.key.action_type." .. key)
            end
        ),
        log_id = combo:new(nil, function(a, b)
            return tonumber(a.key) < tonumber(b.key)
        end, function(value)
            local id = rl(ace_enum.log_id, value)
            return string.format(
                "%s - %s",
                id,
                util_misc.trunc_string(ace_map.log_id_to_text[id], 50)
            )
        end),
    },
    grid_ratio = {
        "1",
        "2",
        "4",
        "8",
        "16",
    },
    expanded_itembar_control = {
        "expanded_itembar_disable_dpad",
        "expanded_itembar_disable_face",
    },
    sharpnes_state = {
        "small",
        "big",
    },
    item_decide = {
        ["option_disable"] = { value = "option_disable", sort = -1 },
        ["LIST_TRIGGER_L_UP"] = { value = "L_UP", sort = 0 },
        ["LIST_TRIGGER_L_DOWN"] = { value = "L_DOWN", sort = 1 },
        ["LIST_TRIGGER_L_LEFT"] = { value = "L_LEFT", sort = 2 },
        ["LIST_TRIGGER_L_RIGHT"] = { value = "L_RIGHT", sort = 3 },
        ["LIST_TRIGGER_L1"] = { value = "L1", sort = 4 },
        ["LIST_TRIGGER_L2"] = { value = "L2", sort = 5 },
        ["OPEN_MYSET"] = { value = "L3", sort = 6 },
        ["OPEN_DEPARTURE_WINDOW_TRIGGER"] = { value = "C_LEFT", sort = 7 },
        ["MAP3D_CLOSE"] = { value = "C_CENTER", sort = 8 },
        ["CLOSE_ALL_MENU"] = { value = "C_RIGHT", sort = 9 },
        ["MAP3D_LOCK_TARGET"] = { value = "R3", sort = 10 },
        ["LIST_TRIGGER_R2"] = { value = "R2", sort = 11 },
        ["LIST_TRIGGER_R1"] = { value = "R1", sort = 12 },
        ["LIST_TRIGGER_RRIGHT"] = { value = "R_RIGHT", sort = 13 },
        ["LIST_TRIGGER_RLEFT"] = { value = "R_LEFT", sort = 14 },
        ["LIST_TRIGGER_RDOWN"] = { value = "R_DOWN", sort = 15 },
        ["LIST_TRIGGER_RUP"] = { value = "R_UP", sort = 16 },
    },
    redo_win_pos = {
        main = false,
        debug = false,
    },
    state = {
        l1_pressed = false,
    },
    set = config_set:new(config),
}
---@enum GuiColors
this.colors = {
    bad = 0xff1947ff,
    good = 0xff47ff59,
    info = 0xff27f3f5,
}

this.combo.item_decide.sort = function(a, b)
    return this.item_decide[a.key].sort < this.item_decide[b.key].sort
end
this.combo.item_decide._translate = function(key)
    if key == "option_disable" then
        return config.lang:tr("hud.option_disable")
    end
    return this.item_decide[key].value
end

function this.translate_combo()
    this.combo.item_decide:translate()
    this.combo.option_bind:translate()
    this.combo.option_mod_bind:translate()
    this.combo.hud_elem:translate()
    this.combo.bind_action_type:translate()
end

function this.reapply_win_pos()
    this.redo_win_pos.main = true
    this.redo_win_pos.debug = true
end

---@return boolean, string
function this.get_input()
    local changed = false
    changed, this.input_action =
        imgui.input_text(gui_util.tr("hud.input"), this.input_action, 1 << 6)
    return changed, this.input_action
end

function this.update_state()
    this.state.l1_pressed =
        ace_player.check_continue_flag(rl(ace_enum.hunter_continue_flag, "OPEN_ITEM_SLIDER"))
end

function this.init()
    this.combo.hud_elem:swap(ace_map.hudid_name_to_local_name)
    this.combo.hud:swap(config.current.mod.hud)
    this.combo.control_point:swap(ace_enum.control_point)
    this.combo.blend:swap(ace_enum.blend)
    this.combo.alpha_channel:swap(ace_enum.alpha_channel)
    this.combo.item_decide:swap(this.item_decide)
    this.combo.segment:swap(util_table.filter(ace_enum.draw_segment, function(key, value)
        return not value:match("RADAR.-")
    end))
    this.combo.page_alignment:swap(ace_enum.page_alignment)
    this.combo.enemy_msg_type:swap(ace_enum.enemy_log)
    this.combo.config:swap(config.selector.sorted)
    this.combo.config_backup:swap(config.selector.sorted_backup)
    this.combo.log_id:swap(ace_enum.log_id)
    this.translate_combo()
end

return this
