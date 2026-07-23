---@class (exact) MainSettings : SettingsBase
---@field version string
---@field mod ModSettings

---@class (exact) ModLanguage
---@field file string
---@field fallback boolean
---@field font_size integer

---@class (exact) GridConfig
---@field draw boolean
---@field combo_grid_ratio integer
---@field color_center integer
---@field color_grid integer
---@field color_fade integer
---@field fade_alpha number

---@class (exact) ConditionConfigBase
---@field class string
---@field combo integer

---@class (exact) ConditionBindOptionsBase

---@class (exact) ConditionSetConfig
---@field hud_key integer
---@field conditions ConditionConfigBase[]
---@field combo_hud integer
---@field combo_condition integer
---@field collapsed boolean

---@class (exact) ConditionBindStateConfig
---@field condition_options table<string, ConditionBindOptionsBase>
---@field hud ConditionSetConfig[]
---@field switchback boolean
---@field highlight_pass boolean

---@class (exact) ModSettings
---@field enabled boolean
---@field enable_fade boolean
---@field enable_notification boolean
---@field enable_key_binds boolean
---@field enable_condition_binds boolean
---@field disable_condition_binds_timed boolean
---@field disable_condition_binds_held boolean
---@field disable_condition_binds_time number
---@field user_scripts table<string, boolean>
---@field hud HudProfileConfig[]
---@field bind {
--- condition: ConditionBindStateConfig,
--- key: {
---     hud: BindBase[],
---     option_hud: BindBase[],
---     option_mod: BindBase[],
---     buffer: integer,
---  },
--- slider: {
---     weapon_bind: integer,
---     key_bind: integer,
---     },
--- },
---@field grid GridConfig
---@field combo {
--- hud: integer,
--- hud_elem: integer,
--- key_bind: {
---     hud: integer,
---     option_hud: integer,
---     option_mod: integer,
---     action_type: integer,
---     },
--- }
---@field lang ModLanguage

local version = require("HudController.config.version")

---@type MainSettings
return {
    version = version.version,
    mod = {
        lang = {
            file = "en-us",
            fallback = true,
            font_size = 16,
        },
        enabled = true,
        enable_fade = true,
        enable_notification = true,
        enable_key_binds = true,
        enable_condition_binds = false,
        disable_condition_binds_held = false,
        disable_condition_binds_timed = false,
        disable_condition_binds_time = 30,
        user_scripts = {},
        grid = {
            draw = false,
            color_center = 4278190335,
            color_grid = 1692721426,
            color_fade = 0,
            fade_alpha = 0,
            combo_grid_ratio = 3,
        },
        bind = {
            key = {
                hud = {},
                option_hud = {},
                option_mod = {},
                buffer = 2,
            },
            condition = {
                condition_options = {},
                hud = {},
                switchback = false,
                highlight_pass = false,
            },
            slider = {
                key_bind = 1,
            },
        },
        hud = {},
        combo = {
            hud = 1,
            hud_elem = 1,
            key_bind = {
                hud = 1,
                option_hud = 1,
                option_mod = 1,
                action_type = 1,
            },
        },
    },
}
