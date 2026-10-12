---@class (exact) HudBaseFn
---@field fn fun()
---@field timer Timer?
---@field execute_on_expire boolean?

local data = require("HudController.data.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map

local this = {
    ---@type table<app.GUIHudDef.TYPE, HudBaseFn[]>
    fns = {},
    ---@type table<app.GUIHudDef.TYPE, HudBaseFn[]>
    pending_fns = {},
    ---@type table<app.GUIID.ID, HudBaseFn[]>
    fns_guiid = {},
    ---@type table<app.GUIID.ID, HudBaseFn[]>
    pending_fns_guiid = {},
}

---@param fns_table table<app.GUIHudDef.TYPE, HudBaseFn[]>|table<app.GUIID.ID, HudBaseFn[]>
---@param pending_table table<app.GUIHudDef.TYPE, HudBaseFn[]>|table<app.GUIID.ID, HudBaseFn[]>
---@param key app.GUIHudDef.TYPE|app.GUIID.ID
local function consume_fns(fns_table, pending_table, key)
    ---@type HudBaseFn[]?
    local fns = fns_table[key]
    if not fns then
        return
    end

    for i = 1, #fns do
        local f = fns[i]
        if f then
            f.fn()
            fns[i] = nil
        end
    end

    if pending_table[key] then
        ---@diagnostic disable-next-line: no-unknown
        fns_table[key] = pending_table[key]
        ---@diagnostic disable-next-line: no-unknown
        pending_table[key] = nil
    else
        ---@diagnostic disable-next-line: no-unknown
        fns_table[key] = nil
    end
end

---@param id app.GUIID.ID
local function consume_hudid(id)
    local hud_id = ace_map.guiid_to_hudid[id]
    consume_fns(this.fns, this.pending_fns, hud_id)
end

---@param id app.GUIID.ID
local function consume_guiid(id)
    consume_fns(this.fns_guiid, this.pending_fns_guiid, id)
end

---@param func fun()|HudBaseFn
---@return HudBaseFn
local function normalize_fn(func)
    if type(func) == "function" then
        return { fn = func }
    end

    return func
end

---@param id app.GUIHudDef.TYPE
---@param func fun()|HudBaseFn
function this.queue_func(id, func)
    util_table.insert_nested_value(this.fns, { id }, normalize_fn(func))
end

---@param id app.GUIHudDef.TYPE
---@param func fun()|HudBaseFn
function this.queue_func_next(id, func)
    util_table.insert_nested_value(this.pending_fns, { id }, normalize_fn(func))
end

---@param id app.GUIID.ID
---@param func fun()|HudBaseFn
function this.queue_func_guiid(id, func)
    util_table.insert_nested_value(this.fns_guiid, { id }, normalize_fn(func))
end

---@param id app.GUIID.ID
---@param func fun()|HudBaseFn
function this.queue_func_next_guiid(id, func)
    util_table.insert_nested_value(this.pending_fns_guiid, { id }, normalize_fn(func))
end

---@param id app.GUIID.ID
function this.consume(id)
    consume_hudid(id)
    consume_guiid(id)
end

function this.consume_expired()
    local function consume_expired_fns(fns_table)
        for id, fns in pairs(fns_table) do
            for i = #fns, 1, -1 do
                local f = fns[i]

                if f and f.timer and f.timer:finished() then
                    if f.execute_on_expire then
                        util_misc.try(function()
                            f.fn()
                        end)
                    end

                    table.remove(fns, i)
                end
            end

            if #fns == 0 then
                ---@diagnostic disable-next-line: no-unknown
                fns_table[id] = nil
            end
        end
    end

    consume_expired_fns(this.fns)
    consume_expired_fns(this.pending_fns)
    consume_expired_fns(this.fns_guiid)
    consume_expired_fns(this.pending_fns_guiid)
end

function this.clear()
    this.fns = {}
    this.pending_fns = {}
    this.fns_guiid = {}
    this.pending_fns_guiid = {}
end

return this
