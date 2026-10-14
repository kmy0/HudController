local config = require("HudController.config.init")
local multi_select = require("HudController.hud.bind.condition.conditions.multi_select")
local s = require("HudController.util.ref.singletons")

local minimap_state = { "DEFAULT", "BLACK_CIRCLE", "RED_CIRCLE", "WHITE_CIRCLE", "PURPLE_CIRCLE" }

---@class MinimapStateCondition : MultiSelectCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = multi_select })

---@return MinimapStateCondition
function this:new()
    ---@type table<string, string>
    local values = {}
    for _, state in pairs(minimap_state) do
        values[state] = string.format(
            config.lang.make_placeholder("menu.bind.condition.condition_minimap_state_values.%s"),
            state
        )
    end

    local o = multi_select.new(
        self,
        "_MINIMAP_STATE",
        config.lang.make_placeholder("menu.bind.condition.condition_minimap_state"),
        values
    )
    setmetatable(o, self)
    ---@cast o MinimapStateCondition

    return o
end

---@param selected table<string, boolean>
---@return boolean
function this:update(selected)
    local map = s.get("app.GUIManager"):get_MAP3D()
    if not map then
        return false
    end

    local radar_front = map:get_GUIRadarFront()
    local radar = radar_front:get_Radar()
    local pnl = radar._PerimeterChangerPanel
    return selected[pnl:get_PlayState()]
end

return this
