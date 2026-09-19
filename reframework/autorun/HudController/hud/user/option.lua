---@class UserOption
---@field name string
---@field label string
---@field default any
---@field group string?
---@field draw fun(value: any, config_key: string): (boolean, any)?

---@class UserOptions
---@field mod table<string, UserOption>
---@field hud table<string, UserOption>
---@field element table<string, table<string, UserOption>>

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
}

---@param option UserOption
function this.register_mod(option)
    assert(this.mod[option.name] == nil, string.format("Option %s already exists!", option.name))
    this.mod[option.name] = option
end

---@param option UserOption
function this.register_hud(option)
    assert(this.hud[option.name] == nil, string.format("Option %s already exists!", option.name))
    this.hud[option.name] = option
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
    util_table.set_nested_value(this.element, { element_name, option.name }, option)
end

---@return boolean
function this.any_to_bind()
    return not util_table.empty(this.mod) or not util_table.empty(this.hud)
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

---@return boolean
function this.init()
    local config_mod = config.current.mod
    for k, opt in pairs(this.mod) do
        if not config_mod.user_options[k] then
            config_mod.user_options[k] = opt.default
        end
    end

    return true
end

return this
