---@class (exact) HudBaseFn
---@field fn fun()
---@field timer Timer?
---@field execute_on_expire boolean?

---@alias HudFnKey app.GUIHudDef.TYPE|app.GUIID.ID

---@class HudFnQueue
---@field active table<HudFnKey, HudBaseFn[]>
---@field pending table<HudFnKey, HudBaseFn[]>

local data = require("HudController.data.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map

---@return HudFnQueue
local function new_queue()
    return {
        active = {},
        pending = {},
    }
end

local hud_queue = new_queue()
local gui_queue = new_queue()

local this = {}

---@param func fun()|HudBaseFn
---@return HudBaseFn
local function normalize_fn(func)
    if type(func) == "function" then
        return { fn = func }
    end

    return func
end

---@param queue HudFnQueue
---@param id HudFnKey
---@param func fun()|HudBaseFn
---@param next_cycle boolean?
local function queue_func(queue, id, func, next_cycle)
    local target = next_cycle and queue.pending or queue.active

    util_table.insert_nested_value(target, { id }, normalize_fn(func))
end

---@param queue HudFnQueue
---@param id HudFnKey
local function consume_fns(queue, id)
    if not id then
        return
    end

    local fns = queue.active[id]
    if not fns then
        return
    end

    queue.active[id] = nil
    for i = 1, #fns do
        local f = fns[i]
        if f then
            f.fn()
        end
    end

    local pending = queue.pending[id]
    if pending then
        local active = queue.active[id]

        if active then
            for i = 1, #pending do
                table.insert(active, pending[i])
            end
        else
            queue.active[id] = pending
        end

        queue.pending[id] = nil
    end
end

---@param id app.GUIHudDef.TYPE
---@param func fun()|HudBaseFn
function this.queue_func(id, func)
    queue_func(hud_queue, id, func)
end

---@param id app.GUIHudDef.TYPE
---@param func fun()|HudBaseFn
function this.queue_func_next(id, func)
    queue_func(hud_queue, id, func, true)
end

---@param id app.GUIID.ID
---@param func fun()|HudBaseFn
function this.queue_func_guiid(id, func)
    queue_func(gui_queue, id, func)
end

---@param id app.GUIID.ID
---@param func fun()|HudBaseFn
function this.queue_func_next_guiid(id, func)
    queue_func(gui_queue, id, func, true)
end

---@param id app.GUIID.ID
function this.consume(id)
    consume_fns(hud_queue, ace_map.guiid_to_hudid[id])
    consume_fns(gui_queue, id)
end

function this.consume_expired()
    local function consume_queue(queue)
        local function consume_table(fns_table)
            for id, fns in pairs(fns_table) do
                local remaining = {}

                for i = 1, #fns do
                    local f = fns[i]

                    if f and f.timer and f.timer:finished() then
                        if f.execute_on_expire then
                            util_misc.try(function()
                                f.fn()
                            end)
                        end
                    elseif f then
                        table.insert(remaining, f)
                    end
                end

                fns_table[id] = #remaining > 0 and remaining or nil
            end
        end

        consume_table(queue.active)
        consume_table(queue.pending)
    end

    consume_queue(hud_queue)
    consume_queue(gui_queue)
end

function this.clear()
    hud_queue = new_queue()
    gui_queue = new_queue()
end

return this
