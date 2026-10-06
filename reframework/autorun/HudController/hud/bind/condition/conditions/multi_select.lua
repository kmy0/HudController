---@class MultiSelectCondition : ConditionBase
---@field values table<any, string>
---@field sorted { key: any, value: string }[]
---@field sorted_values string[]

---@class MultiSelectConditionConfig : ConditionConfigBase
---@field selection table<string, boolean>

local base = require("HudController.hud.def.condition_base")
local combo_multi = require("HudController.util.imgui.combo.combo_multi")
local config = require("HudController.config.init")
local util_table = require("HudController.util.misc.table")

---@class MultiSelectCondition
local this = {}
this.__index = this
setmetatable(this, { __index = base })

---@generic K
---@param condition_name string
---@param display_name string
---@param values table<K, string>
---@param sort_fn (fun(a: { key: K, value: string }, b: { key: K, value: string }): boolean)?
---@return MultiSelectCondition
function this:new(condition_name, display_name, values, sort_fn)
    local o = base.new(self, condition_name, display_name)
    setmetatable(o, self)
    ---@cast o MultiSelectCondition

    if not sort_fn then
        sort_fn = function(a, b)
            return a.value < b.value
        end
    end

    o.values = values
    o.sorted = util_table.sort(util_table.entries(values), sort_fn)
    o.sorted_values = util_table.transform(o.sorted, function(value)
        return value.value
    end)
    return o
end

---@param config_key string
---@return boolean
function this:draw_options(config_key)
    imgui.set_next_item_width(-3)

    local opt = self:get_option_table(config_key) --[[@as MultiSelectConditionConfig]]
    ---@type boolean[]
    local selection_idx = {}
    for _, struct in ipairs(self.sorted) do
        table.insert(selection_idx, opt.selection[tostring(struct.key)] ~= nil)
    end

    ---@type string[]
    local sorted_values = {}
    for _, value in ipairs(self.sorted_values) do
        table.insert(sorted_values, config.lang:try_replace(value))
    end

    local changed, out = combo_multi.combo_multi_filter(
        "##" .. config_key,
        selection_idx,
        config.lang:tr("misc.text_none"),
        sorted_values
    )

    if changed then
        for i, b in pairs(out) do
            local struct = self.sorted[i]
            local key = tostring(struct.key)
            if not b then
                opt.selection[key] = nil
            else
                opt.selection[key] = true
            end
        end

        config:save()
    end

    return changed
end

---@param options MultiSelectConditionConfig
---@return table<any, boolean>
function this:get_update_arg(options)
    return options.selection
end

---@return MultiSelectConditionConfig
function this:new_config()
    local ret = base.new_config(self)
    return util_table.merge(ret, {
        selection = {},
    }) --[[@as MultiSelectConditionConfig]]
end

return this
