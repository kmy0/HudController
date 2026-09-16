local state = require("HudController.gui.state.init")
local util_table = require("HudController.util.misc.table")

local this = {}

---@param hud ModProfileConfig[]
---@param key integer
---@return integer?
function this.hud_index_by_key(hud, key)
    return util_table.index(hud, function(o)
        return o.key == key
    end)
end

---@param hud ModProfileConfig[]
---@param name string
---@return integer?
function this.hud_index_by_name(hud, name)
    return util_table.index(hud, function(o)
        return o.name == name
    end)
end

---@param config_mod ModSettings
function this.refresh_hud_combo(config_mod)
    state.combo.hud:swap(config_mod.hud)
    config_mod.combo.key_bind.hud = 1
end

---@param items HudBaseConfigProfileForShow[]|ModProfileConfig[]
---@param name string
---@return string
function this.get_unique_name(items, name)
    local key = 1
    local ret = name

    while
        util_table.find_value(items, function(_, value)
            return value.name == ret
        end)
    do
        key = key + 1
        ret = name .. key
    end

    return ret
end

return this
