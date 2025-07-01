local config = require("HudController.config")

local this = {}

---@param name string
---@param config_key string
---@param func fun(...): boolean, any
---@return boolean
function this.generic_config(name, config_key, func, ...)
    local changed, value
    changed, value = func(name, config.get(config_key), ...)
    if changed then
        config.set(config_key, value)
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
---@return boolean
function this.slider_int(name, config_key, ...)
    return this.generic_config(name, config_key, imgui.slider_int, ...)
end

return this
