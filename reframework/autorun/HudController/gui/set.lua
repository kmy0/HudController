local config = require("HudController.config")
local util_misc = require("HudController.util.misc")

local this = {}

---@param name string
---@param config_key string
---@param func fun(...): boolean, any
---@return boolean
function this.generic_config(name, config_key, func, ...)
    local changed, value
    changed, value = func(name, config:get(config_key), ...)
    if changed then
        config:set(config_key, value)
    end
    return changed
end

---@param name string
---@param config_key string
---@return boolean
function this.checkbox(name, config_key)
    return this.generic_config(name, config_key, imgui.checkbox)
end

---@param name string
---@param config_key string
---@return boolean
function this.combo(name, config_key, ...)
    return this.generic_config(name, config_key, imgui.combo, ...)
end

---@param name string
---@param config_key string
---@return boolean
function this.color_edit(name, config_key, ...)
    return this.generic_config(name, config_key, imgui.color_edit, ...)
end

---@param name string
---@param config_key string
---@return boolean
function this.slider_float(name, config_key, ...)
    return this.generic_config(name, config_key, imgui.slider_float, ...)
end

---@param name string
---@param config_key string
---@param v_min integer
---@param v_max integer
---@param step number
---@param display_format string?
---@return boolean
function this.slider_float_step(name, config_key, v_min, v_max, step, display_format)
    local changed, value
    v_max = v_max / step
    v_min = v_min / step
    local v = config:get(config_key) / step --[[@as number]]

    changed, value = imgui.slider_int(name, v, v_min, v_max, display_format)
    if changed then
        config:set(config_key, util_misc.round(value * step, util_misc.get_decimals(step)))
    end
    return changed
end

---@param name string
---@param config_key string
---@return boolean
function this.slider_int(name, config_key, ...)
    return this.generic_config(name, config_key, imgui.slider_int, ...)
end

return this
