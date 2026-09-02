local data = require("HudController.data.init")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map

local this = {
    ---@type table<app.GUIHudDef.TYPE, fun()[]>
    fns = {},
    ---@type table<app.GUIHudDef.TYPE, fun()[]>
    pending_fns = {},
    ---@type table<app.GUIID.ID, fun()[]>
    fns_guiid = {},
    ---@type table<app.GUIID.ID, fun()[]>
    pending_fns_guiid = {},
}

---@param fns_table table<app.GUIHudDef.TYPE, fun()[]>|table<app.GUIID.ID, fun()[]>
---@param pending_table table<app.GUIHudDef.TYPE, fun()[]>|table<app.GUIID.ID, fun()[]>
---@param key app.GUIHudDef.TYPE|app.GUIID.ID
local function consume_fns(fns_table, pending_table, key)
    ---@diagnostic disable-next-line: no-unknown
    local fns = fns_table[key]
    if not fns then
        return
    end

    for i = 1, #fns do
        if fns[i] then
            fns[i]()
            ---@diagnostic disable-next-line: no-unknown
            fns[i] = nil
        end
    end

    if pending_table[key] then
        ---@diagnostic disable-next-line: no-unknown
        fns_table[key] = pending_table[key]
        ---@diagnostic disable-next-line: no-unknown
        pending_table[key] = nil
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

---@param id app.GUIHudDef.TYPE
---@param func fun()
function this.queue_func(id, func)
    util_table.insert_nested_value(this.fns, { id }, func)
end

---@param id app.GUIHudDef.TYPE
---@param func fun()
function this.queue_func_next(id, func)
    util_table.insert_nested_value(this.pending_fns, { id }, func)
end

---@param id app.GUIID.ID
---@param func fun()
function this.queue_func_guiid(id, func)
    util_table.insert_nested_value(this.fns_guiid, { id }, func)
end

---@param id app.GUIID.ID
---@param func fun()
function this.queue_func_next_guiid(id, func)
    util_table.insert_nested_value(this.pending_fns_guiid, { id }, func)
end

---@param id app.GUIID.ID
function this.consume(id)
    consume_hudid(id)
    consume_guiid(id)
end

function this.clear()
    this.fns = {}
    this.pending_fns = {}
    this.fns_guiid = {}
    this.pending_fns_guiid = {}
end

return this
