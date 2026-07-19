---@class ConditionBase
---@field display_name string
---@field condition_name string
---@field options string[]?
---@field protected _instances ConditionBase[]

local config = require("HudController.config.init")
local frame_cache = require("HudController.util.misc.frame_cache")

---@class ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
this._instances = setmetatable({}, { __mode = "v" })

---@param condition_name string
---@param display_name string
---@param options string[]? combobox selectables
---@return ConditionBase
function this:new(condition_name, display_name, options)
    local o = {
        condition_name = condition_name,
        display_name = display_name,
        options = options,
    }
    setmetatable(o, self)
    ---@cast o ConditionBase
    table.insert(this._instances, o)

    o.update = frame_cache.memoize(o.update, { key_index = 2, key_as_string = true })

    return o
end

---@param option_key any?
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:update(option_key)
    return false
end

function this:reset() end

function this.reset_all()
    for _, t in pairs(this._instances) do
        t:reset()
    end
end

---@return ConditionConfigBase
function this:new_config()
    return { class = self.condition_name, combo = 1 }
end

-- imgui things drawn at bind > condition options
function this:draw_additional_options() end

-- values that are inserted into config, accessed at: config.current.mod.bind.condition.condition_options[self.condition_name] or self:get_additional_options_table()
---@return ConditionBindOptionsBase
function this:new_additional_options()
    return {}
end

---@return boolean
function this:has_additional_options()
    return this.draw_additional_options ~= self.draw_additional_options
end

---@return ConditionBindOptionsBase
function this:get_additional_options_table()
    return config:get(self:get_config_key())
end

---@return string
function this:get_config_key()
    return string.format("mod.bind.condition.condition_options.%s", self.condition_name)
end

---@param option_key string
---@return string
function this:get_config_key_option(option_key)
    return string.format("%s.%s", self:get_config_key(), option_key)
end

function this:save_config()
    config:save()
end

function this:get_display_name()
    if config.lang:exists(self.display_name) then
        return config.lang:tr(self.display_name)
    end
    return self.display_name
end

return this
