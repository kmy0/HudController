---@class (exact) MainSettings : SettingsBase
---@field version string
---@field mod ModSettings

---@class (exact) ModLanguage
---@field file string
---@field fallback boolean

---@class (exact) GridConfig
---@field draw boolean
---@field combo_grid_ratio integer
---@field color_center integer
---@field color_grid integer
---@field color_fade integer
---@field fade_alpha number

---@class (exact) WeaponBindConfigData
---@field hud_key integer
---@field combo integer

---@class (exact) WeaponBindConfig
---@field weapon_id app.WeaponDef.TYPE
---@field enabled boolean
---@field name string
---@field combat_in WeaponBindConfigData
---@field combat_out WeaponBindConfigData
---@field camp WeaponBindConfigData

---@class (exact) WeaponStateBindConfig
---@field out_of_combat_delay integer
---@field in_combat_delay integer
---@field quest_in_combat boolean
---@field ride_ignore_combat boolean
---@field singleplayer table<string, WeaponBindConfig>
---@field multiplayer table<string, WeaponBindConfig>

---@class (exact) ModSettings
---@field enabled boolean
---@field enable_fade boolean
---@field enable_notification boolean
---@field enable_key_binds boolean
---@field enable_weapon_binds boolean
---@field disable_weapon_binds_timed boolean
---@field disable_weapon_binds_held boolean
---@field disable_weapon_binds_time number
---@field hud HudProfileConfig[]
---@field bind {
--- weapon: WeaponStateBindConfig,
--- key: {hud: HudBindBase[], option: OptionBindBase[]},
--- }
---@field grid GridConfig
---@field combo_hud_key_bind integer
---@field combo_hud integer
---@field combo_hud_elem integer
---@field combo_option_key_bind integer
---@field slider_weapon_bind integer
---@field slider_key_bind integer
---@field lang ModLanguage

local version = require("HudController.config.version")

---@type MainSettings
return {
    version = version.version,
    gui = {
        main = {
            pos_x = 50,
            pos_y = 50,
            size_x = 800,
            size_y = 700,
            is_opened = false,
        },
        debug = {
            pos_x = 50,
            pos_y = 50,
            size_x = 800,
            size_y = 700,
            is_opened = false,
        },
    },
    mod = {
        lang = {
            file = "en-us",
            fallback = true,
        },
        enabled = true,
        enable_fade = true,
        enable_notification = true,
        enable_key_binds = true,
        enable_weapon_binds = false,
        disable_weapon_binds_held = false,
        disable_weapon_binds_timed = false,
        disable_weapon_binds_time = 30,
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
                option = {},
            },
            weapon = {
                quest_in_combat = false,
                out_of_combat_delay = 0,
                in_combat_delay = 0,
                ride_ignore_combat = false,
                singleplayer = {},
                multiplayer = {},
            },
        },
        hud = {},
        combo_hud = 1,
        combo_hud_elem = 1,
        combo_hud_key_bind = 1,
        combo_option_key_bind = 1,
        slider_weapon_bind = 1,
        slider_key_bind = 1,
    },
    debug = {
        show_disabled = false,
        is_filter = false,
        is_debug = false,
    },
}
