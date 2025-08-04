---@class (exact) WindowState
---@field pos_x integer
---@field pos_y integer
---@field size_x integer
---@field size_y integer
---@field is_opened boolean

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

---@class (exact) GuiLanguage
---@field file string
---@field fallback boolean

---@class (exact) GuiSettings
---@field main WindowState
---@field debug WindowState
---@field lang GuiLanguage

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

---@class (exact) DebugSettings
---@field show_disabled boolean
---@field is_filter boolean
---@field is_debug boolean

---@class (exact) Settings
---@field version string
---@field gui GuiSettings
---@field mod ModSettings
---@field debug DebugSettings

---@class Config
---@field lang Language
---@field version string
---@field commit string
---@field name string
---@field grid_size integer
---@field porter_timeout number
---@field handler_timeout number
---@field default_lang_path string
---@field hud_default_path string
---@field option_default_path string
---@field config_path string
---@field default Settings
---@field current Settings
---@field save_timer Timer

local migration = require("HudController.config.migration")
local timer = require("HudController.util.misc.timer")
local util_table = require("HudController.util.misc.table")
local version = require("HudController.config.version")

---@class Config
local this = {
    lang = require("HudController.config.lang"),
}

this.version = version.version
this.commit = version.commit
this.name = "HudController"
this.config_path = this.name .. "/config.json"
this.default_lang_path = this.name .. "/lang/en-us.json"
this.hud_default_path = this.name .. "/hud_default.json"
this.option_default_path = this.name .. "/option_default.json"
this.grid_size = 160
this.porter_timeout = 3
this.handler_timeout = 5

---@diagnostic disable-next-line: missing-fields
this.current = {}
this.default = {
    version = this.version,
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
        lang = {
            file = "en-us",
            fallback = true,
        },
    },
    mod = {
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

---@param key string
---@return any
function this.get(key)
    return util_table.get_by_key(this.current, key)
end

---@param key string
---@param value any
function this.set(key, value)
    util_table.set_by_key(this.current, key, value)
end

function this.load()
    local loaded_config = json.load_file(this.config_path) --[[@as Settings?]]
    ---@type string?
    local current_version
    if loaded_config then
        current_version = loaded_config.version
        this.current = util_table.merge_t(this.default, loaded_config)
    else
        current_version = this.commit
        this.current = util_table.deep_copy(this.default)
    end

    if migration.need_migrate(current_version, this.commit) then
        this.backup()
        migration.migrate(current_version, this.commit, this.current)
        this.save_no_timer()
    end
end

function this.backup()
    json.dump_file(
        string.format("%s/%s_backup_v%s_config.json", this.name, os.time(), this.current.version),
        this.current
    )
end

function this.save()
    this.save_timer:restart()
end

function this.save_no_timer()
    json.dump_file(this.config_path, this.current)
end

function this.run_save()
    this.save_timer:update()
end

function this.restore()
    this.current = util_table.deep_copy(this.default)
    this.save_no_timer()
    this.lang.change()
end

---@return boolean
function this.init()
    this.load()
    this.lang.init(this)
    return true
end

this.save_timer = timer.new("config_save_timer", 0.5, this.save_no_timer, true)

return this
