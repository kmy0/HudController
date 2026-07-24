---@class OptionManager
---@field overridden_options TableProxy<string, boolean>
---@field override_fns table<string, fun(key: string, value: boolean)>

local hud_base = require("HudController.hud.def.hud_base")
local util_misc = require("HudController.util.misc.init")
---@module "HudController.hud.hook.init"
local hook = util_misc.lazy_require("HudController.hud.hook.init")
local profile_switcher = require("HudController.hud.manager.profile_switcher")
local table_proxy = require("HudController.util.misc.table_proxy")

---@class OptionManager
local this = {
    overridden_options = table_proxy.new(),
    override_fns = {},
}

---@param key string
---@param value boolean
local function override_scar_option(key, value)
    if value then
        local t = { "hide_scar", "show_scar", "disable_scar" }
        for _, k in pairs(t) do
            if k ~= key then
                this.overridden_options[k] = false
            end
        end
    end
end

---@param option_name string
---@param option_value integer
function this.apply_option(option_name, option_value)
    hud_base.apply_option(option_name, option_value)
end

---@param options table<string, integer>
function this.apply_option_many(options)
    for option, value in pairs(options) do
        this.apply_option(option, value)
    end
end

---@param key string
---@param new_value boolean? nil for toggle
---@return boolean? -- changed value
function this.overwrite_hud_option(key, new_value)
    local current_hud = profile_switcher.current_hud
    if not current_hud then
        return
    end

    if new_value == nil then
        if this.overridden_options[key] ~= nil then
            this.overridden_options[key] = not this.overridden_options[key]
        else
            this.overridden_options[key] = not current_hud[key]
        end
    else
        if this.overridden_options[key] ~= new_value then
            this.overridden_options[key] = new_value
        else
            return
        end
    end

    local func = this.override_fns[key]
    if func then
        func(key, this.overridden_options[key])
    end

    hook.hook_option(key)
    return this.overridden_options[key]
end

function this.clear()
    this.overridden_options.clear()
end

this.override_fns["hide_scar"] = override_scar_option
this.override_fns["show_scar"] = override_scar_option
this.override_fns["disable_scar"] = override_scar_option

return this
