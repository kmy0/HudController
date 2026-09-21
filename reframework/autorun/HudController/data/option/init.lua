---@class OptionDef<T>
---@field key string
---@field config_key string | fun(self: OptionDef<T>, ...): string
---@field lang_key string
---@field bindable boolean
---@field combo Combo?
---@field draw fun(self: OptionDef<T>, label: string?, config_key: string): boolean
---@field format fun(self: OptionDef<T>, val: T): string
---@field active (fun(self: OptionDef<T>, val: T): boolean)?

---@class OptionDrawArgs
---@field label boolean?
---@field id (string | number)[]?

local util_opt = require("HudController.data.option.util")

local this = {
    hud = require("HudController.data.option.hud"),
    mod = require("HudController.data.option.mod"),
    elem = require("HudController.data.option.element.init"),
}

---@param opt OptionDef<any>
---@param ... any config key args
---@return string
function this.get_config_key(opt, ...)
    if type(opt.config_key) == "function" then
        return opt:config_key(...)
    end
    ---@diagnostic disable-next-line: return-type-mismatch
    return opt.config_key
end

---@param opt OptionDef<any>
---@param args OptionDrawArgs?
---@param ... any config key args
---@return boolean
function this.draw(opt, args, ...)
    args = args or {}

    local config_key = this.get_config_key(opt, ...)
    ---@type string?
    local label
    if args.label ~= false then
        label = util_opt.tr(opt.lang_key, table.unpack(args.id or {}))
    end

    --- @diagnostic disable-next-line: param-type-mismatch cannot assign `string?` to parameter `string?` ????
    return opt:draw(label, config_key)
end

---@param opt OptionDef<any>
---@param ... any config key args
---@return boolean
function this.draw_menu(opt, ...)
    return util_opt.menu_item(opt, this.get_config_key(opt, ...))
end

---@param opt OptionDef<any>
---@param value any
---@return boolean
function this.is_active(opt, value)
    return opt.active == nil or opt:active(value)
end

function this.init()
    return this.elem.init()
end

return this
