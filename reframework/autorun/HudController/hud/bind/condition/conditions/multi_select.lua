---@class MultiSelectCondition : ConditionBase
---@field combo_add Combo
---@field combo_remove Combo
---@field values table<any, string>
---@field selected_key string
---@field get_additional_options_table fun(self: ConditionBase): MultiSelectConditionOptions

---@class (exact) MultiSelectConditionOptions : ConditionBindOptionsBase
---@field selected any[]
---@field combo_add integer
---@field combo_remove integer

local base = require("HudController.hud.def.condition_base")
local combo = require("HudController.util.imgui.combo")
local set = require("HudController.gui.set")
local util_imgui = require("HudController.util.imgui.init")
local util_table = require("HudController.util.misc.table")

---@class MultiSelectCondition
local this = {}
this.__index = this
setmetatable(this, { __index = base })

---@return MultiSelectCondition
function this:new(condition_name, display_name, values, sort_fn)
    local o = base.new(self, condition_name, display_name)
    setmetatable(o, self)
    ---@cast o MultiSelectCondition

    o.values = values

    o.combo_add = combo:new(values, {
        sort_fn = sort_fn,
    })
    o.combo_remove = combo:new(values)

    local options = o:get_additional_options_table() or {}
    local selected = options.selected or {}

    o.combo_add:disable_items(selected)
    o.combo_remove:disable_all_items()
    o.combo_remove:enable_items(selected)

    return o
end

function this:draw_options()
    local options = self:get_additional_options_table()
    local x_size = util_imgui.get_max_button_size("+", "-") + 4
    local item_width = util_imgui.get_available_width() - 16 - x_size

    imgui.push_item_width(item_width)
    set:combo_filter(
        "##" .. self.condition_name .. "Add",
        self:get_config_key_option("combo_add"),
        self.combo_add
    )
    imgui.pop_item_width()

    imgui.same_line()

    util_imgui.begin_disabled(util_table.empty(self.combo_add.values))
    if imgui.button("+##" .. self.condition_name, { x_size, 0 }) then
        local key = self.combo_add:get_key(options.combo_add)

        options.combo_add = self.combo_add:disable_item(key)
        options.combo_remove = self.combo_remove:enable_item(key)

        table.insert(options.selected, key)
        self:save_config()
    end
    util_imgui.end_disabled()

    imgui.push_item_width(item_width)
    set:combo_filter(
        "##" .. self.condition_name .. "Remove",
        self:get_config_key_option("combo_remove"),
        self.combo_remove
    )
    imgui.pop_item_width()

    imgui.same_line()

    util_imgui.begin_disabled(util_table.empty(self.combo_remove.values))
    if imgui.button("-##" .. self.condition_name, { x_size, 0 }) then
        local key = self.combo_remove:get_key(options.combo_remove)

        options.combo_remove = self.combo_remove:disable_item(key)
        options.combo_add = self.combo_add:enable_item(key)

        table.remove(options.selected, util_table.index(options.selected, key))
        self:save_config()
    end
    util_imgui.end_disabled()
end

function this:get_selected_option_string()
    local ret = self:get_display_name()
    local selected = self:get_additional_options_table().selected

    if not util_table.empty(selected) then
        local names = {}

        for _, value in ipairs(selected) do
            table.insert(names, self.values[value])
        end

        ret = string.format("%s - %s", ret, table.concat(names, ", "))
    end

    return ret
end

function this:new_additional_options()
    return {
        combo_add = 1,
        combo_remove = 1,
        selected = {},
    }
end

return this
