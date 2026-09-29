---@class ConditionBase
---@field display_name string
---@field condition_name string
---@field options string[]?
---@field protected _instances ConditionBase[]

local config = require("HudController.config.init")
local frame_cache = require("HudController.util.misc.frame_cache")
local util_table = require("HudController.util.misc.table")

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

    local mem_ok = true
    if o:_update_arg_changed() then
        local conf = o:new_config()
        local args = table.pack(o:get_update_arg(conf))

        if
            #args > 1
            or util_table.index({ "function", "table", "userdata", "thread" }, type(args[1]))
        then
            mem_ok = false
        end
    end

    if mem_ok then
        o.update = frame_cache.memoize(o.update, { key_index = 2, key_as_string = true })
    end

    return o
end

---@param ... any
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:update(...)
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
    ---@type ConditionConfigBase
    return { class = self.condition_name, combo = 1, negate = false }
end

-- imgui things drawn to the right of condition name
---@param config_key string -- path to ConditionConfigBase config:get(key .. ".combo")
---@diagnostic disable-next-line: unused-local
function this:draw_options(config_key) end

---@param config_key string
---@param param_key string
---@return string
function this:get_option_config_key_option(config_key, param_key)
    return string.format("%s.%s", config_key, param_key)
end

---@param options ConditionConfigBase
---@return integer
function this:get_update_arg(options)
    return options.combo
end

---@param config_key string
---@return ConditionConfigBase
function this:get_option_table(config_key)
    return config:get(config_key)
end

---@param options ConditionConfigBase
---@return boolean
---@diagnostic disable-next-line: unused-local
function this:validate(options)
    return true
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

---@return boolean
function this:has_custom_options()
    return this.draw_options ~= self.draw_options
end

---@protected
---@return boolean
function this:_update_arg_changed()
    return this.update ~= self.get_update_arg
end

---@return ConditionBindOptionsBase
function this:get_additional_options_table()
    return config:get(self:get_additional_options_config_key())
end

---@return string?
function this:get_options_category()
    return nil
end

---@return string
function this:get_additional_options_config_key()
    return string.format("mod.bind.condition.condition_options.%s", self.condition_name)
end

---@param option_key string
---@return string
function this:get_additional_options_config_key_option(option_key)
    return string.format("%s.%s", self:get_additional_options_config_key(), option_key)
end

function this:save_config()
    config:save()
end

function this:get_display_name()
    return config.lang:try_replace(self.display_name)
end

return this
