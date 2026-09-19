---@class UserOption
---@field name string
---@field label string
---@field default any
---@field group string?
---@field draw fun(value: any, config_key: string): (boolean, any)?

---@class RegisteredUserOption : UserOption
---@field module "hud" | "mod" | "element"
---@field key string
---@field element string?
---@field sort integer?

---@class UserOptions
---@field mod table<string, RegisteredUserOption>
---@field hud table<string, RegisteredUserOption>
---@field element table<string, table<string, RegisteredUserOption>>
---@field all table<string, RegisteredUserOption>

local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local util_misc = require("HudController.util.misc.init")
---@module "HudController.hud.init"
local hud = util_misc.lazy_require("HudController.hud.init")
local util_table = require("HudController.util.misc.table")

---@class UserOptions
local this = {
    mod = {},
    hud = {},
    element = {},
    all = {},
}

---@param option UserOption
function this.register_mod(option)
    ---@cast option RegisteredUserOption
    option.module = "mod"
    option.key = this.make_key(option)
    assert(this.mod[option.name] == nil, string.format("Option %s already exists!", option.name))
    this.mod[option.name] = option
    this.all[option.key] = option
end

---@param option UserOption
function this.register_hud(option)
    ---@cast option RegisteredUserOption
    option.module = "hud"
    option.key = this.make_key(option)
    assert(this.hud[option.name] == nil, string.format("Option %s already exists!", option.name))
    this.hud[option.name] = option
    this.all[option.key] = option
end

---@param element_name string
---@param option UserOption
function this.register_element(element_name, option)
    assert(type(element_name) == "string", string.format("Bad element name: %s", element_name))
    assert(
        e.get("app.GUIHudDef.TYPE")[element_name] ~= nil,
        string.format("Bad element name: %s", element_name)
    )
    assert(
        util_table.get_nested_value(this.element, { element_name, option.name }) == nil,
        string.format("Option %s already exists!", option.name)
    )
    ---@cast option RegisteredUserOption
    option.module = "element"
    option.element = element_name
    option.key = this.make_key(option)
    util_table.set_nested_value(this.element, { element_name, option.key }, option)
    this.all[option.key] = option
end

---@param opt RegisteredUserOption
---@return string
function this.make_key(opt)
    if opt.module ~= "element" then
        return string.format("%s.%s", opt.module, opt.name)
    end

    return string.format("%s.%s.%s", opt.module, opt.element, opt.name)
end

---@param user_options table<string, RegisteredUserOption>
---@return RegisteredUserOption[][]
function this.get_sorted_options(user_options)
    local grouped = util_table.groupby(user_options, function(_, _, value)
        return value.group or "_"
    end)
    local groups = util_table.sort(util_table.keys(grouped))
    ---@type RegisteredUserOption[][]
    local ret = {}

    for _, g in ipairs(groups) do
        ---@type RegisteredUserOption[]
        local t = {}
        local keys = util_table.sort(util_table.keys(grouped[g]))

        for _, k in ipairs(keys) do
            local opt = grouped[g][k][1]
            table.insert(t, opt)
        end

        table.insert(ret, t)
    end

    return ret
end

---@return table<RegisteredUserOption, string>
function this.get_combo_values()
    local mod_opt = this.get_sorted_options(this.mod)
    local hud_opt = this.get_sorted_options(this.hud)
    ---@type table<RegisteredUserOption, string>
    local ret = {}

    local i = 1
    for _, options in ipairs({ mod_opt, hud_opt }) do
        for _, group in ipairs(options) do
            for _, opt in ipairs(group) do
                opt.sort = i
                i = i + 1
                ret[opt] = opt.label
            end
        end
    end

    return ret
end

---@param element_name string
---@param option_name string
---@return any
function this.get_element_current_profile_option_value(element_name, option_name)
    local elem_config = hud.get_element_config(element_name)
    if not elem_config then
        return
    end

    return elem_config.user_options[option_name]
end

---@param option_name string
---@return any
function this.get_hud_option_value(option_name) end

---@param option_name string
---@return any
function this.get_mod_option_value(option_name) end

---@param registered_option RegisteredUserOption
---@return any
function this.get_current_value(registered_option) end

---@return boolean
function this.init()
    --TODO: mvoe this to op?
    local config_mod = config.current.mod
    for k, opt in pairs(this.mod) do
        if not config_mod.user_options[k] then
            config_mod.user_options[k] = opt.default
        end
    end

    ---@type BindBase[]
    local res = {}
    for _, b in ipairs(config_mod.bind.key.option_user) do
        if this.all[b.bound_value.key] then
            table.insert(res, b)
        end
    end
    --TODO: cond filter
    config_mod.bind.key.option_user = res

    return true
end

return this
