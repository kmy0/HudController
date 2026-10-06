---@alias ManagerName "option_hud" | "option_mod" | "option_game" | "option_user" | "option_elem" | "hud"

---@class BindActionManager
---@field applied_requests table<ManagerName, table<string, any>>

local bind_condition = require("HudController.hud.bind.condition.init")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local handlers = require("HudController.hud.manager.bind_actions.handlers")
local held = require("HudController.hud.manager.bind_actions.held")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

---@class BindActionManager
local this = {
    applied_requests = {},
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

    held.apply_restores(cond_requests)
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
    held.holds = {}
    held.restores = {}
end

return this
