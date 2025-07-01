---@class GuiState
---@field combo GuiCombo
---@field input_action string?
---@field grid_ratio string[]
---@field expanded_itembar_control string[]
---@field listener NewBindListener?

---@class (exact) GuiCombo
---@field hud_elem Combo
---@field hud Combo
---@field item_decide Combo
---@field control_point Combo
---@field blend Combo
---@field alpha_channel Combo
---@field option_bind Combo

---@class (exact) NewBindListener
---@field opt HudProfileConfig | string
---@field listener BindListener
---@field collision string?

local combo = require("HudController.gui.combo")
local config = require("HudController.config")
local data = require("HudController.data")
local game_data = require("HudController.util.game.data")

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
                    return config.lang.tr("hud_element.name." .. key)
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
            mod.map.hud_options,
            function(a, b)
                return a.key < b.key
            end,
            nil,
            function(key)
                return config.lang.tr("hud." .. mod.map.hud_options[key])
            end
        ),
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
this.combo.item_decide._tr = function(key)
    if key == "option_disable" then
        return config.lang.tr("hud.option_disable")
    end
    return this.item_decide[key].value
end

function this.tr_combo()
    this.combo.item_decide:tr()
    this.combo.option_bind:tr()
    this.combo.hud_elem:tr()
end

function this.init()
    this.combo.hud_elem:swap(ace_map.hudid_name_to_local_name)
    this.combo.hud:swap(config.current.mod.hud)
    this.combo.control_point:swap(ace_enum.control_point)
    this.combo.blend:swap(ace_enum.blend)
    this.combo.alpha_channel:swap(ace_enum.alpha_channel)
    this.combo.item_decide:swap(this.item_decide)
    this.tr_combo()
end

return this
