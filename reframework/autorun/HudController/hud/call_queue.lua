local data = require("HudController.data")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map

local this = {
    ---@type table<app.GUIHudDef.TYPE, fun()[]>
    fns = {},
}

---@param id app.GUIHudDef.TYPE
---@param func fun()
function this.queue_func(id, func)
    util_table.insert_nested_value(this.fns, { id }, func)
end

---@param id app.GUIID.ID
function this.consume(id)
    local hud_id = ace_map.guiid_to_hudid[id]
    local fns = this.fns[hud_id]
    if not fns then
        return
    end

    for i = 1, #fns do
        if fns[i] then
            fns[i]()
            fns[i] = nil
        end
    end
end

return this
