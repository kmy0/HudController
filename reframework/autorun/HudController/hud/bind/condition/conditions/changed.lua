---@class ChangedCondition : ConditionBase
---@field timer Timer
---@field frame ValueChecker
---@field get_additional_options_table fun(self: ConditionBase): ChangedConditionConfig

---@class ChangedConditionConfig : ConditionBindOptionsBase
---@field duration integer

local base = require("HudController.hud.def.condition_base")
local config = require("HudController.config.init")
local frame_counter = require("HudController.util.misc.frame_counter")
local set = require("HudController.gui.set")
local timer = require("HudController.util.misc.timer")
local util_imgui = require("HudController.util.imgui.init")
local value_checker = require("HudController.util.misc.value_checker")

---@class ChangedCondition
local this = {}
this.__index = this
setmetatable(this, { __index = base })

---@param condition_name string
---@param display_name string
---@return ChangedCondition
function this:new(condition_name, display_name)
    local o = base.new(self, condition_name, display_name)
    setmetatable(o, self)
    ---@cast o ChangedCondition

    local options = o:get_additional_options_table()

    o.timer = timer:new(options and options.duration or 3)
    o.frame = value_checker:new(frame_counter.frame, function(old_value, new_value)
        return new_value - old_value <= 30
    end)

    return o
end

---@param value_changed boolean
---@return boolean
function this:check(value_changed)
    local frame_ok = self.frame:is_changed(frame_counter.frame)

    if value_changed and frame_ok then
        self.timer:restart()
    end

    return self.timer:active()
end

---@return ChangedConditionConfig
function this:new_additional_options()
    return {
        duration = 3,
    }
end

function this:draw_additional_options()
    local options = self:get_additional_options_table()

    imgui.set_next_item_width(util_imgui.get_drag_with())
    if
        set:drag_int(
            string.format(
                "%s %s##%s",
                config.lang:try_replace(self.display_name),
                config.lang:tr("menu.bind.condition.text_trigger_duration"),
                self.condition_name
            ),
            self:get_config_key_option("duration"),
            0.1,
            1,
            10,
            "%d " .. config.lang:tr("misc.text_seconds_short")
        )
    then
        self.timer:update_args({ duration = options.duration })
    end
end

---@return string
function this:get_options_category()
    return config.lang:tr("menu.bind.condition.category_condition_changed")
end

function this:reset()
    self.timer:abort()
    self.frame:reset()
end

return this
