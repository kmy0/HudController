---@class UserOption
---@field name string
---@field label string
---@field default any
---@field group string?
---@field draw fun(value: any, config_key: string): (boolean, any)?
---@field format (fun(value: any): string)?

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
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.init"
local hud = util_misc.lazy_require("HudController.hud.init")

---@class UserOptions
local this = {
    mod = {},
    hud = {},
    element = {},
    all = {},
}

---@param option UserOption
local function assert_option(option)
    assert(type(option) == "table", "Option must be a table!")
    assert(type(option.name) == "string" and option.name ~= "", "Option name is required!")
    assert(not option.name:find("%."), "Option name cannot contain dots!")
    assert(type(option.label) == "string" and option.label ~= "", "Option label is required!")
    assert(option.default ~= nil, "Option default is required!")
    assert(type(option.draw) == "function", "Option draw function is required!")
end

---@param option UserOption
function this.register_mod(option)
    assert_option(option)
    ---@cast option RegisteredUserOption
    option.module = "mod"
    option.key = this.make_key(option)
    assert(this.mod[option.name] == nil, string.format("Option %s already exists!", option.name))
    assert(this.all[option.key] == nil, string.format("Option %s already exists!", option.key))
    this.mod[option.name] = option
    this.all[option.key] = option
end

---@param option UserOption
function this.register_hud(option)
    assert_option(option)
    ---@cast option RegisteredUserOption
    option.module = "hud"
    option.key = this.make_key(option)
    assert(this.hud[option.name] == nil, string.format("Option %s already exists!", option.name))
    assert(this.all[option.key] == nil, string.format("Option %s already exists!", option.key))
    this.hud[option.name] = option
    this.all[option.key] = option
end

---@param element_name string
---@param option UserOption
function this.register_element(element_name, option)
    assert_option(option)
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
    assert(this.all[option.key] == nil, string.format("Option %s already exists!", option.key))
    util_table.set_nested_value(this.element, { element_name, option.name }, option)
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

    local elems = util_table.sort(util_table.keys(this.element))
    for _, elem in ipairs(elems) do
        local sorted = this.get_sorted_options(this.element[elem])
        for _, group in ipairs(sorted) do
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
function this.get_hud_option_value(option_name)
    local hud_config = hud.get_current()
    if not hud_config then
        return
    end

    return hud_config.user_options[option_name]
end

---@param option_name string
---@return any
function this.get_mod_option_value(option_name)
    return config.current.mod.user_options[option_name]
end

---@param registered_option RegisteredUserOption
---@return any
function this.get_current_value(registered_option)
    if registered_option.module == "hud" then
        return this.get_hud_option_value(registered_option.name)
    elseif registered_option.module == "element" then
        return this.get_element_current_profile_option_value(
            registered_option.element,
            registered_option.name
        )
    end

    return this.get_mod_option_value(registered_option.name)
end

---@param option_name string
---@param value any
function this.set_hud_option_value(option_name, value)
    local hud_config = hud.get_current()
    if not hud_config then
        return
    end

    hud_config.user_options[option_name] = util_table.deep_copy(value)
end

---@param option_name string
---@param value any
function this.set_mod_option_value(option_name, value)
    config.current.mod.user_options[option_name] = util_table.deep_copy(value)
end

---@param element_name string
---@param option_name string
---@param value any
function this.set_element_current_profile_option_value(element_name, option_name, value)
    local elem_config = hud.get_element_config(element_name)
    if not elem_config then
        return
    end

    elem_config.user_options[option_name] = util_table.deep_copy(value)
end

---@param registered_option RegisteredUserOption
---@param value any
function this.set_option_value(registered_option, value)
    if registered_option.module == "hud" then
        this.set_hud_option_value(registered_option.name, value)
    elseif registered_option.module == "element" then
        this.set_element_current_profile_option_value(
            registered_option.element,
            registered_option.name,
            value
        )
    elseif registered_option.module == "mod" then
        this.set_mod_option_value(registered_option.name, value)
    end
end

---@param registered_option RegisteredUserOption
---@return any
function this.get_default(registered_option)
    return util_table.deep_copy(registered_option.default)
end

---@param option RegisteredUserOption
---@param value any
---@return string
function this.format_value(option, value)
    if option.format then
        return option.format(value)
    elseif value == true then
        return config.lang:tr("misc.text_on")
    elseif value == false then
        return config.lang:tr("misc.text_off")
    end

    return util_table.repr_any(value)
end

return this
