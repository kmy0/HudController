local base = require("HudController.hud.def.condition_base")
local cd = require("HudController.data.combo")
local config = require("HudController.config.init")
local set = require("HudController.gui.set")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@module "HudController.hud.init"
local hud = util_misc.lazy_require("HudController.hud.init")

---@class HudCondition : ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = base })

---@return HudCondition
function this:new()
    local o =
        base.new(self, "_HUD", config.lang.make_placeholder("menu.bind.condition.condition_hud"))
    setmetatable(o, self)
    ---@cast o HudCondition

    return o
end

---@param config_key string
---@return boolean
function this:draw_options(config_key)
    imgui.set_next_item_width(-3)

    local opt = self:get_option_table(config_key)
    local index = util_table.index(config.current.mod.hud, function(o)
        return opt.combo_key == o.key
    end)
    local combo_key = config_key .. ".combo"

    if index and index ~= opt.combo then
        config:set(combo_key, index)
    end

    local changed = set:combo("##" .. config_key, combo_key, cd.combo.hud.values)
    if changed then
        config:set(config_key .. ".combo_key", config.current.mod.hud[config:get(combo_key)].key)
    end

    return changed
end

---@param hud_key integer
---@return boolean
function this:update(hud_key)
    local current = hud.get_current()
    return current and current.key == hud_key or false
end

---@param options ConditionConfigBase
---@return integer
function this:get_update_arg(options)
    return options.combo_key
end

return this
