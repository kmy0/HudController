---@class BindActionHandler<K, V>
---@field apply fun(key: K, value: V)
---@field notification fun(key: K, value: V)

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

---@class BindActionManager
---@field applied_requests table<string, table<string, any>>

local ace_misc = require("HudController.util.ace.misc")
local bind_condition = require("HudController.hud.bind.condition.init")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local def = require("HudController.data.option.init")
local elements = require("HudController.hud.manager.elements")
local options = require("HudController.hud.manager.options")
local user_option = require("HudController.hud.user.option")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.hook.init"
local hook = util_misc.lazy_require("HudController.hud.hook.init")

local mod = data.mod
local ace = data.ace

---@class BindActionManager
local this = {
    applied_requests = {},
}
---@class BindActionHandlers
local handlers = {
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
    },
}

---@param key_requests BindEvalResult
---@param cond_requests ConditionEvalResult
---@return ConditionEvalResult
function this.merge_requests(key_requests, cond_requests)
    if key_requests.hud then
        if not cond_requests.hud or key_requests.hud.key ~= cond_requests.hud.key then
            local applied_hud = bind_condition.applied_hud

            if applied_hud and applied_hud.key ~= key_requests.hud.key then
                for _, path in ipairs(applied_hud.paths) do
                    bind_condition.demote_path(path)
                end
            end

            cond_requests.hud = key_requests.hud
        elseif key_requests.hud.profile[1] ~= mod.enum.elem_profile.DEFAULT then
            table.insert(cond_requests.hud.profile, 1, key_requests.hud.profile[1])
        end
    end

    for opt_manager, _ in pairs(handlers) do
        if opt_manager ~= "hud" then
            for opt_name, opt_value in
                pairs(key_requests[opt_manager] or {} --[[@as table<string, any>]])
            do
                local by = bind_condition.applied_by[opt_manager]
                bind_condition.demote_path(by and by[opt_name])

                util_table.set_nested_value(cond_requests, { opt_manager, opt_name }, opt_value)
            end
        end
    end

    return cond_requests
end

---@param requests ConditionEvalResult
function this.apply_requests(requests)
    local config_mod = config.current.mod

    for name, handler in pairs(handlers) do
        local current = requests[name] or {} --[[@as table<string, any>]]
        local previous = this.applied_requests[name] or {}

        for key, value in pairs(current) do
            handler.apply(key, value)

            if
                config_mod.enable_notification
                and handler.notification
                and not util_table.equal(previous[key], value)
            then
                handler.notification(key, value)
            end
        end

        this.applied_requests[name] = current
    end
end

function this.clear()
    this.applied_requests = {}
end

return this
