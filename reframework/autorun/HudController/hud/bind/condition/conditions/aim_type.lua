local ace_player = require("HudController.util.ace.player")
local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local multi_select = require("HudController.hud.bind.condition.conditions.multi_select")
local util_table = require("HudController.util.misc.table")

---@class AimTypeCondition : MultiSelectCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = multi_select })

---@return AimTypeCondition
function this:new()
    local o = multi_select.new(
        self,
        "_AIM_TYPE",
        config.lang.make_placeholder("menu.bind.condition.condition_aim_type"),
        {}
    )
    setmetatable(o, self)
    ---@cast o AimTypeCondition

    return o
end

---@return { key: string, value: string }[], string[]
function this:get_sorted()
    ---@type { key: string, value: string }[]
    local sorted = util_table.sort(
        util_table.entries(
            util_table.transform_items(
                e.get_noexact("app.HunterDef.AIM_TYPE").field_to_enum,
                function(key, _)
                    return key
                end,
                function(_, key)
                    return key
                end
            )
        ),
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
    local char = ace_player.get_master_char()
    if not char then
        return false
    end

    local ctx = char:get_HunterContext()
    if not ctx then
        return false
    end

    local aim_type = ctx:get_AimType()
    if util_table.empty(selection) and aim_type == e.get_noexact("app.HunterDef.AIM_TYPE").NONE then
        return true
    end

    return selection[e.get_noexact("app.HunterDef.AIM_TYPE")[aim_type]] ~= nil
end

return this
