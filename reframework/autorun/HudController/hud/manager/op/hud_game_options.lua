local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local options = require("HudController.hud.manager.options")
local util_table = require("HudController.util.misc.table")

local this = {}

---@param option_name string
---@param value boolean|nil
local function set_game_option_hud(option_name, value)
    local config_mod = config.current.mod
    local hud_value = value and -1 or nil
    config_mod.game_options.hud[option_name] = value

    for _, hud in pairs(config_mod.hud) do
        hud.options[option_name] = hud_value
    end
end

---@param elem_name string
---@param option_name string
---@param value boolean|nil
local function set_game_option_elem(elem_name, option_name, value)
    local config_mod = config.current.mod
    local elem_value = value and -1 or nil
    util_table.set_nested_value(config_mod.game_options.elements, { elem_name, option_name }, value)

    for _, hud in pairs(config_mod.hud) do
        local elem = hud.elements[elem_name]

        if elem then
            elem.options[option_name] = elem_value
            for _, profile in pairs(elem.profile) do
                profile.options[option_name] = elem_value
            end
        end
    end

    if util_table.empty(config_mod.game_options.elements[elem_name]) then
        config_mod.game_options.elements[elem_name] = nil
    end
end

local function refresh_combo_option_game_bind()
    cd.init_combo_option_game_bind()
    local config_mod = config.current.mod
    for _, cond_set in pairs(config_mod.bind.condition.hud) do
        ---@type ConditionSetConfig[]
        local res = {}
        for _, cond_child in ipairs(cond_set.game_option or {}) do
            local new_index = cd.combo.option_game_bind:get_index(cond_child.key)
            if new_index then
                cond_child.combo_profile = new_index
                table.insert(res, cond_child)
            end
        end

        cond_set.game_option = res
    end
end

---@param elem_name string
---@param option_name string
function this.add_game_option_elem(elem_name, option_name)
    if elem_name == "GLOBAL" then
        set_game_option_hud(option_name, true)
    else
        set_game_option_elem(elem_name, option_name, true)
    end

    refresh_combo_option_game_bind()
end

---@param elem_name string
---@param option_name string
function this.remove_game_option_elem(elem_name, option_name)
    if elem_name == "GLOBAL" then
        set_game_option_hud(option_name, nil)
    else
        set_game_option_elem(elem_name, option_name, nil)
    end

    options.apply_option(option_name, -1)
    refresh_combo_option_game_bind()
end

return this
