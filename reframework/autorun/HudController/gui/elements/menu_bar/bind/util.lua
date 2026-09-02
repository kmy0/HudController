local config = require("HudController.config.init")
local mod = require("HudController.data.mod")
local operations = require("HudController.hud.manager.operations")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local this = {}

---@generic T
---@param values T[]
---@param get_key fun(value: T): integer
---@param get_label fun(value: T): string
---@param bits integer
---@return string[] options
---@return boolean[] selected
local function values_to_multi_combo(values, get_key, get_label, bits)
    local selected_keys = util_misc.unpack_bits(bits)
    ---@type string[]
    local options = {}
    ---@type boolean[]
    local selected = {}

    ---@diagnostic disable-next-line: no-unknown
    for i, value in ipairs(values) do
        options[i] = get_label(value)
        selected[i] = util_table.contains(selected_keys, get_key(value))
    end

    return options, selected
end

---@generic T
---@param values T[]
---@param choice boolean[]
---@param get_key fun(value: T): integer
---@return integer
local function multi_combo_choice_to_bits(values, choice, get_key)
    local bits = 0

    for i, enabled in ipairs(choice) do
        if enabled then
            bits = bits | (1 << (get_key(values[i]) - 1))
        end
    end

    return bits
end

---@param values HudBaseConfigProfileForShow[]
---@param bits integer
---@return string[]
---@return boolean[]
local function profile_multi_combo_values(values, bits)
    return values_to_multi_combo(values, function(v)
        return v.key
    end, function(v)
        return v.name
    end, bits)
end

---@param values HudBaseConfigProfileForShow[]
---@param choice boolean[]
---@return integer
local function profile_multi_combo_bits(values, choice)
    return multi_combo_choice_to_bits(values, choice, function(v)
        return v.key
    end)
end

---@param name string
---@param config_key string
---@param values HudBaseConfigProfileForShow[]
---@param disabled boolean?
---@param width number?
---@return boolean
function this.profile_multi_combo(name, config_key, values, disabled, width)
    local options, selected = profile_multi_combo_values(values, config:get(config_key))
    local changed, choice = util_imgui.multi_combo(
        name,
        config.lang:tr("misc.text_none"),
        options,
        selected,
        disabled,
        width or util_gui.get_item_size()
    )

    if changed then
        config:set(config_key, profile_multi_combo_bits(values, choice))
    end

    return changed
end

---@param hud_config ModProfileConfig
---@param bits integer
---@return string
function this.elem_profiles_to_name(hud_config, bits)
    local elem_profile_keys = util_misc.unpack_bits(bits)
    ---@type string[]
    local names = {}
    for _, key in ipairs(elem_profile_keys) do
        local profile = util_table.value(hud_config.profile, function(_, value)
            return value.key == key
        end) --[[@as HudBaseConfigProfileForShow]]
        table.insert(names, profile.name)
    end

    return table.concat(names, ", ")
end

---@param opt string
---@return string
function this.get_option_hud_bind_name(opt)
    return config.lang:tr("hud." .. mod.map.options_hud[opt])
end

---@param opt string
---@return string
function this.get_option_mod_bind_name(opt)
    return config.lang:tr("menu.config." .. mod.map.options_mod[opt])
end

---@param opt {hud: integer, profile: integer}
---@return string
function this.get_hud_bind_name(opt)
    local hud_profile = operations.get_hud_by_key(opt.hud)
    local name = hud_profile.name

    if opt.profile ~= 0 then
        name = string.format("%s | %s", name, this.elem_profiles_to_name(hud_profile, opt.profile))
    end

    return name
end

return this
