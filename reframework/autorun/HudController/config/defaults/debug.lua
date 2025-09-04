---@class (exact) DebugSettings : SettingsBase
---@field debug {
--- show_disabled: boolean,
--- is_filter :boolean,
--- is_debug: boolean,
--- disable_cache: boolean,
--- }

---@class DebugConfig : ConfigBase
---@field current DebugSettings
---@field default DebugSettings

---@type DebugSettings
return {
    debug = {
        show_disabled = false,
        is_filter = false,
        is_debug = false,
        disable_cache = false,
    },
}
