local condition_base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local s = require("HudController.util.ref.singletons")
local util_table = require("HudController.util.misc.table")

local minimap_state = { "DEFAULT", "BLACK_CIRCLE", "RED_CIRCLE", "WHITE_CIRCLE", "PURPLE_CIRCLE" }

---@class MinimapStateCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@return MinimapStateCondition
function this:new()
    local o = condition_base.new(
        self,
        "_MINIMAP_STATE",
        config.lang.make_placeholder("menu.bind.condition.condition_minimap_state"),
        util_table.collect(util_table.iterator(function(index)
            if minimap_state[index] then
                return string.format(
                    config.lang.make_placeholder(
                        "menu.bind.condition.condition_minimap_state_values.%s"
                    ),
                    minimap_state[index]
                )
            end
        end))
    )
    setmetatable(o, self)
    ---@cast o MinimapStateCondition

    return o
end

---@param option_key integer
---@return boolean
function this:update(option_key)
    local map = s.get("app.GUIManager"):get_MAP3D()
    if not map then
        return false
    end

    local radar_front = map:get_GUIRadarFront()
    local radar = radar_front:get_Radar()
    local pnl = radar._PerimeterChangerPanel
    return pnl:get_PlayState() == minimap_state[option_key]
end

return this
