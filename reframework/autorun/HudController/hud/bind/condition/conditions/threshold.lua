---@class ThresholdCondition : ConditionBase

---@class ThresholdConditionConfig : ConditionConfigBase
---@field v_lo number
---@field v_hi number

local base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local set = require("HudController.gui.set")
local util_table = require("HudController.util.misc.table")

---@class ThresholdCondition
local this = {}
this.__index = this
setmetatable(this, { __index = base })

---@generic K
---@param condition_name string
---@param display_name string
---@return ThresholdCondition
function this:new(condition_name, display_name)
    local o = base.new(self, condition_name, display_name)
    setmetatable(o, self)
    ---@cast o ThresholdCondition
    return o
end

---@param config_key string
---@return boolean
function this:draw_options(config_key)
    local v_lo = config_key .. ".v_lo"
    local v_hi = config_key .. ".v_hi"
    imgui.set_next_item_width(-1)
    return set:range_slider_int(
        "##" .. config_key,
        v_lo,
        v_hi,
        0,
        100,
        nil,
        string.format(
            config.lang:tr("menu.bind.condition.text_threshold"),
            config:get(v_lo),
            config:get(v_hi)
        )
    )
end

---@param options ThresholdConditionConfig
---@return number, number
function this:get_update_arg(options)
    return options.v_lo, options.v_hi
end

---@return ThresholdConditionConfig
function this:new_config()
    local ret = base.new_config(self)
    return util_table.merge(ret, {
        v_hi = 100,
        v_lo = 0,
    }) --[[@as ThresholdConditionConfig]]
end

return this
