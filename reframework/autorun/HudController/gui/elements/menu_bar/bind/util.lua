local ace = require("HudController.data.ace")
local config = require("HudController.config.init")
local mod = require("HudController.data.mod")
local op = require("HudController.hud.manager.op.init")
local options = require("HudController.hud.manager.options")
local user_option = require("HudController.hud.user.option")
local util_gui = require("HudController.gui.util")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local this = {}

---@param hud_config ModProfileConfig
---@param bits integer
---@return string
function this.elem_profiles_to_name(hud_config, bits)
    local elem_profile_keys = util_misc.unpack_bits(bits)
    ---@type string[]
    local names = {}
    for _, key in ipairs(elem_profile_keys) do
        local profile = util_table.find_value(hud_config.profile, function(_, value)
            return value.key == key
        end) --[[@as HudBaseConfigProfileForShow]]
        if profile then
            table.insert(names, profile.name)
        end
    end

    return table.concat(names, ", ")
end

---@param bind ModBind
---@return string
function this.get_action_name(bind)
    local action = bind.action_type
    if action == "NONE" then
        action = "SET"
    end

    return string.format("[%s]", config.lang:tr("menu.bind.key.action_type." .. action))
end

---@param bind ModBind
---@return string
function this.get_trigger_name(bind)
    return string.format(
        "[%s]",
        config.lang:tr(
            "menu.bind.key.trigger_type." .. (bind.trigger_repeat and "REPEAT" or "ONCE")
        )
    )
end

---@param bind ModBind
---@return string
function this.get_key_bind_name(bind)
    return string.format("[%s]", bind.name_display)
end

---@param bind ModBind | BindOpt
---@return string
function this.get_option_mod_bind_name(bind)
    local key = ""
    local value = 0
    if bind.bound_value then
        key = bind.bound_value.key --[[@as string]]
        value = bind.bound_value.value --[[@as integer]]
    else
        key = bind.key
        value = bind.value
    end

    return string.format(
        "%s (%s)",
        config.lang:tr("menu.config." .. mod.map.options_mod[key]),
        util_gui.format_boolean(value)
    )
end

---@param bind ModBind | BindOpt
---@return string
function this.get_option_hud_bind_name(bind)
    local key = ""
    local value = 0
    if bind.bound_value then
        key = bind.bound_value.key --[[@as string]]
        value = bind.bound_value.value --[[@as integer]]
    else
        key = bind.key
        value = bind.value
    end

    return string.format(
        "%s (%s)",
        config.lang:tr("hud." .. mod.map.options_hud[key]),
        util_gui.format_boolean(value)
    )
end

---@param bind ModBind | BindOpt
---@return string
function this.get_option_user_bind_name(bind)
    local key = ""
    ---@type any
    local value = 0
    if bind.bound_value then
        key = bind.bound_value.key --[[@as string]]
        value = bind.bound_value.value --[[@as any]]
    else
        key = bind.key
        value = bind.value
    end

    local user_opt = user_option.all[key]
    return string.format("%s (%s)", user_opt.label, user_option.format_value(user_opt, value))
end

---@param bind ModBind | BindOpt
---@return string
function this.get_option_game_bind_name(bind)
    local key = ""
    ---@type any
    local value = 0
    if bind.bound_value then
        key = bind.bound_value.key --[[@as string]]
        value = bind.bound_value.value --[[@as integer]]
    else
        key = bind.key
        value = bind.value
    end

    return string.format(
        "%s (%s)",
        ace.map.option[key].name_local,
        options.get_option_setting_name(key, value)
    )
end

---@param bind ModBind | BindOpt
---@return string
function this.get_hud_bind_name(bind)
    local hud = 0
    local profile = 0
    if bind.bound_value then
        hud = bind.bound_value.key --[[@as integer]]
        profile = bind.bound_value.value --[[@as integer]]
    else
        hud = bind.key
        profile = bind.value
    end

    local hud_profile = op.hud_profile.get_hud_by_key(hud)
    local name = hud_profile.name

    if profile ~= 0 then
        local profiles = this.elem_profiles_to_name(hud_profile, profile)
        return string.format("%s (%s)", name, profiles)
    end

    return name
end

return this
