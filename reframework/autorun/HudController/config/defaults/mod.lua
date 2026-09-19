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

---@class (exact) GameOptionsConfig
---@field hud table<string, boolean>
---@field elements table<string, table<string, boolean>>
---@field display_full_path boolean

---@class (exact) CanvasConfig
---@field draw boolean
---@field display_name boolean
---@field display_value boolean
---@field color_default integer
---@field color_hover integer
---@field color_select integer
---@field color_outline integer
---@field anchor {
--- offset_x: number,
--- offset_y: number,
--- radius: integer,
--- }
---@field hide_elem_not_present boolean
---@field hide_elem_disabled boolean
---@field keybinds {
--- draw: boolean,
--- pos_x: number,
--- pos_y: number,
--- }

---@class (exact) ConditionConfigBase
---@field class string
---@field combo integer
---@field expected_result ExpectedResult

---@class (exact) ConditionBindOptionsBase

---@class (exact) ConditionSetConfig
---@field key integer | string
---@field conditions ConditionConfigBase[]
---@field combo_profile integer
---@field combo_condition integer
---@field collapsed boolean
---@field parent_key (integer | string)?
---@field element_profile ConditionSetConfig[]
---@field hud_option ConditionSetConfig[]
---@field mod_option ConditionSetConfig[]
---@field game_option ConditionSetConfig[]
---@field free_value any?

---@class (exact) ConditionBindStateConfig
---@field condition_options table<string, ConditionBindOptionsBase>
---@field hud ConditionSetConfig[]
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
---@field block_input boolean
---@field user_scripts table<string, boolean>
---@field user_conditions table<string, boolean>
---@field hud ModProfileConfig[]
---@field game_options GameOptionsConfig
---@field bind {
--- condition: ConditionBindStateConfig,
--- key: {
---     hud: BindBase[],
---     option_hud: BindBase[],
---     option_mod: BindBase[],
---     option_game: BindBase[],
---     buffer: integer,
---  },
--- slider: {
---     weapon_bind: integer,
---     key_bind: integer,
---     },
--- },
---@field grid GridConfig
---@field canvas CanvasConfig
---@field combo {
--- hud: integer,
--- hud_elem: integer,
--- game_option: integer,
--- key_bind: {
---     target: integer,
---     action_type: integer,
---     trigger_type: integer,
---     value: integer,
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
        block_input = false,
        user_scripts = {},
        user_conditions = {},
        game_options = {
            hud = {
                DAMAGE_DISPLAY = true,
                SKILL_EFFECT = true,
                TALISMAN_EFFECT = true,
            },
            elements = {
                MINIMAP = {
                    MAP_RADAR_FIXNORTH = true,
                    MAP_RADAR_PITCH_TYPE = true,
                },
                COMPANION = {
                    AUTO_SCALING_FELLOW_FITNESS = true,
                },
                HEALTH = {
                    AUTO_SCALING_FITNESS = true,
                    ALERT_EFFECT = true,
                },
                PROGRESS = {
                    ELAPSED_TIME_DISP = true,
                },
                STAMINA = {
                    AUTO_SCALING_STAMINA = true,
                },
                SHARPNESS = {
                    AUTO_SCALING_SHARPNESS = true,
                },
            },
            display_full_path = true,
        },
        grid = {
            draw = false,
            color_center = 4278190335,
            color_grid = 1692721426,
            color_fade = 0,
            fade_alpha = 0,
            combo_grid_ratio = 3,
        },
        canvas = {
            draw = false,
            display_name = true,
            display_value = true,
            color_default = 0xFFFFFFFF,
            color_hover = 0xffe3dfdd,
            color_select = 0xffc8b8b0,
            color_outline = 0xff0000ff,
            hide_elem_not_present = false,
            hide_elem_disabled = false,
            anchor = {
                offset_x = 0,
                offset_y = 0,
                radius = 6,
            },
            keybinds = {
                draw = true,
                pos_x = 9,
                pos_y = 364,
            },
        },
        bind = {
            key = {
                hud = {},
                option_hud = {},
                option_mod = {},
                option_game = {},
                buffer = 2,
            },
            condition = {
                condition_options = {},
                hud = {},
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
            game_option = 1,
            key_bind = {
                target = 1,
                action_type = 1,
                trigger_type = 1,
                value = 1,
            },
        },
    },
}
