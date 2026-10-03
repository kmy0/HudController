local base = require("HudController.hud.def.condition_base")
local bind_manager = require("HudController.hud.bind.key.init")
local config = require("HudController.config.init")
local set = require("HudController.gui.set")
local util_table = require("HudController.util.misc.table")

---@class KeyCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = base })

---@return KeyCondition
function this:new()
    local o =
        base.new(self, "_KEY", config.lang.make_placeholder("menu.bind.condition.condition_key"))
    setmetatable(o, self)
    ---@cast o KeyCondition

    return o
end

---@param config_key string
---@return boolean
function this:draw_options(config_key)
    imgui.set_next_item_width(-3)

    local opt = self:get_option_table(config_key)
    ---@type string[]
    local values = {}
    util_table.do_something_ordered(bind_manager.condition:get_base_binds(), function(_, _, value)
        table.insert(values, value.name)
    end)

    local index = util_table.index(values, function(o)
        return opt.combo_key == o
    end)
    local combo_key = config_key .. ".combo"

    if index and index ~= opt.combo then
        config:set(combo_key, index)
    end

    local changed = set:combo("##" .. config_key, combo_key, values)
    if changed then
        config:set(config_key .. ".combo_key", values[config:get(combo_key)])
    end

    return changed
end

---@param bind_name string
---@return boolean
function this:update(bind_name)
    return util_table.get_nested_value(
        bind_manager.monitor.frame_storage,
        { "condition", bind_name }
    ) == true
end

---@param options ConditionConfigBase
---@return integer
function this:get_update_arg(options)
    return options.combo_key
end

return this
