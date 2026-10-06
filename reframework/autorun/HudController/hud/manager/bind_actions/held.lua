---@class BindActionHeld
---@field holds table<ManagerName, table<any, HoldState>>
---@field restores table<ManagerName, table<any, any>>
---@field COND string

---@class (exact) HoldEntry
---@field owner string
---@field value any

---@class (exact) HoldState
---@field original any
---@field hud_key integer
---@field owned_by_condition boolean true while a condition rule is writing this slot every frame, keeps the original from being restored until it stops
---@field keys HoldEntry[]

local handlers = require("HudController.hud.manager.bind_actions.handlers")
local slot = require("HudController.hud.manager.bind_actions.slot")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.init"
local hud = util_misc.lazy_require("HudController.hud.init")

---@class BindActionHeld
local this = {
    COND = "BIND_CONDITION",
    holds = {},
    restores = {},
}

---@param name string
---@param key any
---@param value any
local function queue_restore(name, key, value)
    if value == nil then
        return
    end

    this.restores[name] = this.restores[name] or {}
    this.restores[name][key] = util_table.deep_copy(value)
end

---@param name ManagerName
---@param key any
---@param owner string
---@param value any
---@return boolean pushed
function this.push_hold(name, key, owner, value)
    local by_name = this.holds[name]
    if not by_name then
        by_name = {}
        this.holds[name] = by_name
    end

    local state = by_name[key]
    if not state then
        local ok, current = handlers[name].get_current(key, value)
        if not ok then
            return false
        end

        state = {
            original = util_table.deep_copy(current),
            hud_key = hud.get_current().key,
            owned_by_condition = false,
            keys = {},
        }
        by_name[key] = state
    end

    if owner == this.COND then
        if state.owned_by_condition then
            return false
        end

        state.owned_by_condition = true
        return true
    end

    for _, entry in ipairs(state.keys) do
        if entry.owner == owner then
            entry.value = util_table.deep_copy(value)
            return false
        end
    end

    table.insert(state.keys, { owner = owner, value = util_table.deep_copy(value) })
    return true
end

---@param name ManagerName
---@param key any
---@param owner string
---@return any? value
function this.release_hold(name, key, owner)
    ---@type HoldState
    local state = util_table.get_nested_value(this.holds, { name, key })
    if not state then
        return nil
    end

    if owner == this.COND then
        state.owned_by_condition = false
    else
        for i = #state.keys, 1, -1 do
            if state.keys[i].owner == owner then
                table.remove(state.keys, i)
                break
            end
        end
    end

    local top = state.keys[#state.keys]
    ---@type any
    local value

    if top then
        value = top.value
    elseif state.owned_by_condition then
        return nil
    else
        value = state.original
        this.holds[name][key] = nil
    end

    if not handlers[name].is_hold_valid(state) or value == nil then
        return nil
    end

    if owner == this.COND then
        queue_restore(name, key, value)
        return nil
    end

    return util_table.deep_copy(value)
end

---@param cond_requests ConditionEvalResult
function this.apply_restores(cond_requests)
    for name, by_key in pairs(this.restores) do
        for key, value in pairs(by_key) do
            if slot.get(cond_requests, name, key) == nil then
                slot.set(cond_requests, name, key, util_table.deep_copy(value))
            end
        end
    end

    this.restores = {}
end

function this.release_all_holds()
    for name, by_key in pairs(this.holds) do
        for key, state in pairs(by_key) do
            if handlers[name].is_hold_valid(state) then
                queue_restore(name, key, state.original)
            end
        end
    end

    this.holds = {}
end

return this
