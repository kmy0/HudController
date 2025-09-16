local call_queue = require("HudController.hud.call_queue")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local elements = require("HudController.hud.elements.init")
local game_data = require("HudController.util.game.data")
local hud = require("HudController.hud.init")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

local this = {}

function this.is_ok()
    return mod.initialized and config.current.mod.enabled
end

---@generic T
---@param name `T`
---@return T?
function this.get_elem_t(name)
    if not this.is_ok() then
        return
    end

    return hud.get_element(elements[name])
end

---@generic T
---@param element_type `T`?
---@param guiid_name string app.GUIID.ID name
---@return T | HudBase?, app.GUIID.ID?
function this.get_elem_consume_t(element_type, guiid_name)
    if not this.is_ok() then
        return
    end

    local guiid = rl(ace_enum.gui_id, guiid_name)
    call_queue.consume(guiid)

    ---@type HudBase?
    local ret
    if element_type then
        ret = hud.get_element(elements[element_type])
    else
        ret = hud.get_element_by_guiid(guiid)
    end

    return ret, guiid
end

---@return HudProfileConfig?
function this.get_hud()
    if not this.is_ok() then
        return
    end

    return hud.get_current()
end

return this
