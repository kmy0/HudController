---@class (exact) DebugSettings : SettingsBase
---@field debug {
--- show_disabled: boolean,
--- is_filter :boolean,
--- is_debug: boolean,
--- filter_known_errors: boolean,
--- combo_elem_cache: integer,
--- slider_frame: integer,
--- slider_jitter: integer,
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
        filter_known_errors = false,
        combo_elem_cache = 2,
        slider_frame = 60,
        slider_jitter = 120,
    },
}
