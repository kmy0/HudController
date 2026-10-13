local config = require("HudController.config.init")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local fade_manager = require("HudController.hud.fade.init")
local multi_select = require("HudController.hud.bind.condition.conditions.multi_select")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map

---@class FadingCondition : MultiSelectCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = multi_select })

---@return FadingCondition
function this:new()
    local o = multi_select.new(
        self,
        "_FADE",
        config.lang.make_placeholder("menu.bind.condition.condition_fade"),
        {}
    )
    setmetatable(o, self)
    ---@cast o FadingCondition

    return o
end

---@return { key: string, value: string }[], string[]
function this:get_sorted()
    ---@type { key: string, value: string }[]
    local sorted = util_table.sort(
        util_table.entries(ace_map.hudid_name_to_local_name),
        function(a, b)
            return a.key < b.key
        end
    )

    local sorted_values = util_table.transform(sorted, function(value)
        return value.value
    end)

    return sorted, sorted_values
end

---@param selection table<string, boolean>
---@return boolean
function this:update(selection)
    if util_table.empty(selection) and fade_manager.is_active() then
        return true
    end

    for elem_name, _ in pairs(selection) do
        if fade_manager.is_active_element(e.get("app.GUIHudDef.TYPE")[elem_name]) then
            return true
        end
    end

    return false
end

return this
