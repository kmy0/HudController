---@class OptionManager
---@field overridden_options TableProxy<string, any>
---@field override_fns table<string, fun(key: string, value: boolean)>

local ace = require("HudController.data.ace")
local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local hud_base = require("HudController.hud.def.hud_base")
local m = require("HudController.util.ref.methods")
local profile_switcher = require("HudController.hud.manager.profile_switcher")
local table_proxy = require("HudController.util.misc.table_proxy")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.hook.init"
local hook = util_misc.lazy_require("HudController.hud.hook.init")

---@class OptionManager
local this = {
    overridden_options = table_proxy.new(),
    override_fns = {},
}

---@param option_name string
---@param option_value integer
function this.apply_option(option_name, option_value)
    hud_base.apply_option(option_name, option_value)
end

---@param option_name string
---@return integer
function this.get_option(option_name)
    local option = ace.map.option[option_name]
    return m.getOptionValue(option.id)
end

---@param option_name string
---@param option_value integer
---@return string | integer
function this.get_option_setting_name(option_name, option_value)
    local option = ace.map.option[option_name]
    ---@type string | integer
    local ret = option_value
    if ret == -1 then
        return config.lang:tr("hud.option_disable")
    elseif not util_table.empty(option.items) then
        ret = option.items[option_value + 1].name_local
    elseif option.type == e.get("app.Option.TYPE").CHOICE then
        ret = option_value == 0 and config.lang:tr("misc.text_off")
            or config.lang:tr("misc.text_on")
    elseif option.type == e.get("app.Option.TYPE").VALUE and option.decimal_place ~= 0 then
        ret = option_value / (10 ^ option.decimal_place) --[[@as number]]
    end

    return ret
end

---@param options table<string, integer>
function this.apply_option_many(options)
    for option, value in pairs(options) do
        this.apply_option(option, value)
    end
end

---@param key string
---@param new_value any?
---@return any? -- changed value
function this.overwrite_hud_option(key, new_value)
    local current_hud = profile_switcher.current_hud
    if not current_hud then
        return
    end

    if this.overridden_options[key] ~= new_value then
        this.overridden_options[key] = new_value
    else
        return
    end

    local func = this.override_fns[key]
    if func then
        func(key, this.overridden_options[key])
    end

    hook.hook_option(key)
    return this.overridden_options[key]
end

---@param key string
function this.clear_overridden(key)
    this.overridden_options[key] = nil
end

function this.clear()
    this.overridden_options.clear()
end

return this
