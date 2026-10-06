---@class BindActionHandler<K, V>
---@field apply fun(key: K, value: V)
---@field notification fun(key: K, value: V)
---@field get_current fun(key: K, value: V): boolean, V
---@field is_hold_valid fun(hold_state: HoldState): boolean

---@class BindActionOptionHud : BindActionHandler<string, any>
---@class BindActionOptionMod : BindActionHandler<string, any>
---@class BindActionOptionGame : BindActionHandler<string, integer>
---@class BindActionOptionUser : BindActionHandler<string, any>
---@class BindActionHud : BindActionHandler<string, {key: integer, profile: integer[]}>
---@class BindActionOptionElem : BindActionHandler<string, {value: any, ctx_path: OptionCtxPath}>

---@class BindActionHandlers
---@field option_hud BindActionOptionHud
---@field option_mod BindActionOptionMod
---@field option_game BindActionOptionGame
---@field option_user BindActionOptionUser
---@field option_elem BindActionOptionElem
---@field hud BindActionHud

local ace_misc = require("HudController.util.ace.misc")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local def = require("HudController.data.option.init")
local elements = require("HudController.hud.manager.elements")
local options = require("HudController.hud.manager.options")
local user_option = require("HudController.hud.user.option")
local util_misc = require("HudController.util.misc.init")
local util_opt = require("HudController.data.option.util")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.hook.init"
local hook = util_misc.lazy_require("HudController.hud.hook.init")
---@module "HudController.hud.init"
local hud = util_misc.lazy_require("HudController.hud.init")
---@module "HudController.hud.manager.profile_switcher"
local profile_switcher = util_misc.lazy_require("HudController.hud.manager.profile_switcher")

local ace = data.ace

---@class BindActionHandlers
local this = {
    option_hud = {
        apply = function(key, value)
            options.overwrite_hud_option(key, value)
        end,
        notification = function(key, value)
            local opt = def.hud.opt[key]
            ace_misc.send_message(
                string.format(
                    "%s %s %s",
                    config.lang:tr(opt.lang_key),
                    config.lang:tr("misc.text_override_notifcation_message"),
                    opt:format(value)
                )
            )
        end,
        get_current = function(key, _)
            local hud_profile = hud.get_current() --[[@as ModProfileConfig]]
            return true, hud.get_overridden(key) or hud_profile[key]
        end,
        is_hold_valid = function(hold_state)
            return hud.get_current().key == hold_state.hud_key
        end,
    },
    option_mod = {
        apply = function(key, value)
            local opt = def.mod.opt[key]
            config:set(opt.config_key, value)
            hook.hook_option_mod(opt.key)
        end,
        notification = function(key, value)
            local opt = def.mod.opt[key]
            ace_misc.send_message(
                string.format(
                    "%s %s %s",
                    config.lang:tr(opt.lang_key),
                    config.lang:tr("misc.text_changed_notifcation_message"),
                    opt:format(value)
                )
            )
        end,
        get_current = function(key, _)
            return true, config:get(def.mod.opt[key].config_key)
        end,
        is_hold_valid = function(_)
            return true
        end,
    },
    option_game = {
        apply = function(key, value)
            options.apply_option(key, value)
        end,
        notification = function(key, value)
            ace_misc.send_message(
                string.format(
                    "%s %s %s",
                    ace.map.option[key].name_local,
                    config.lang:tr("misc.text_changed_notifcation_message"),
                    options.get_option_setting_name(key, value)
                )
            )
        end,
        get_current = function(key, _)
            return true, options.get_option(key)
        end,
        is_hold_valid = function(_)
            return true
        end,
    },
    option_user = {
        apply = function(key, value)
            local opt = user_option.bindable[key]
            user_option.set_option_value(opt, value)
        end,
        notification = function(key, value)
            local opt = user_option.bindable[key]
            ace_misc.send_message(
                string.format(
                    "%s %s %s",
                    opt.label,
                    config.lang:tr("misc.text_changed_notifcation_message"),
                    user_option.format_value(opt, value)
                )
            )
        end,
        get_current = function(key, _)
            return true, user_option.get_current_value(user_option.bindable[key])
        end,
        is_hold_valid = function(_)
            return true
        end,
    },
    option_elem = {
        apply = function(key, value)
            local ctx = elements.get_element_ctx(value.ctx_path)

            if ctx then
                local opt = def.elem.get_opt(key)
                opt:apply(ctx, value.value)
                ctx.elem.overridden_options[opt.key] = util_table.deep_copy(value.value)
                local elem = ctx.elem:get_root()
                local opt_hook_table = hook.hud_option_hooks[elem.name_key]
                local opt_path = string.format("%s.%s", ctx.config_path, opt.key)

                if opt_hook_table then
                    local opt_hook = opt_hook_table[opt_path]
                    if opt_hook and not hook.is_option_mod_hooked[opt_path] then
                        opt_hook.force_once = true
                    end
                end

                hook.hook_hud(elem.hud_id, elem.name_key)
            end
        end,
        notification = function(key, value)
            local ctx = elements.get_element_ctx(value.ctx_path)
            if ctx then
                local opt = def.elem.get_opt(key)
                ace_misc.send_message(
                    string.format(
                        "%s %s %s",
                        table.concat(
                            util_table.slice(opt.name_path, #opt.name_path - 1, #opt.name_path),
                            " > "
                        ),
                        config.lang:tr("misc.text_changed_notifcation_message"),
                        opt:format(value.value)
                    )
                )
            end
        end,
        get_current = function(key, value)
            local ctx = elements.get_element_ctx(value.ctx_path)
            if not ctx then
                ---@diagnostic disable-next-line: missing-return-value
                return false
            end

            local opt = def.elem.get_opt(key)
            return true,
                {
                    value = ctx.elem.overridden_options[opt.key]
                        or util_opt.get_elem_config_value(opt, ctx.elem_config),
                    ctx_path = value.ctx_path,
                }
        end,
        is_hold_valid = function(hold_state)
            return hud.get_current().key == hold_state.hud_key
        end,
    },
    hud = {
        apply = function() end,
        notification = function() end,
        is_hold_valid = function()
            return true
        end,
        get_current = function()
            local current = profile_switcher.current_hud
            if not current then
                ---@diagnostic disable-next-line: missing-return-value
                return false
            end

            return true, { key = current.hud.key, profile = current.profile_bits }
        end,
    },
}

return this
