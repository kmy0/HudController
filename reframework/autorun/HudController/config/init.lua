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

---@class MainConfig : ConfigBase
---@field current MainSettings
---@field default MainSettings
---
---@field lang Language
---@field gui GuiConfig
---@field debug DebugConfig
---
---@field version string
---@field commit string
---@field name string
---
---@field default_lang_path string
---@field hud_default_path string
---@field option_default_path string
---@field default_config_path string
---
---@field grid_size integer
---@field porter_timeout number
---@field handler_timeout number

local config_base = require("HudController.util.misc.config")
local debug_config = require("HudController.config.debug")
local gui_config = require("HudController.config.gui")
local migration = require("HudController.config.migration")
local util_misc = require("HudController.util.misc")
local util_table = require("HudController.util.misc.table")
local version = require("HudController.config.version")

---@type MainSettings
local default = {
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
local mod_name = "HudController"
local config_path = util_misc.join_paths(mod_name, "config.json")

---@class MainConfig
local this = config_base:new(default, config_path)

this.version = version.version
this.commit = version.commit
this.name = mod_name

this.default_lang_path = util_misc.join_paths(this.name, "lang", "en-us.json")
this.default_config_path = config_path
this.hud_default_path = util_misc.join_paths(this.name, "default", "hud.json")
this.option_default_path = util_misc.join_paths(this.name, "default", "option.json")

this.lang = require("HudController.config.lang")
this.gui = gui_config.new(util_misc.join_paths(this.name, "other_configs", "gui.json"))
this.debug = debug_config.new(util_misc.join_paths(this.name, "other_configs", "debug.json"))

this.grid_size = 160
this.porter_timeout = 3
this.handler_timeout = 5

function this:load()
    local loaded_config = json.load_file(self.path) --[[@as MainSettings?]]
    ---@type string?
    local current_version
    if loaded_config then
        current_version = loaded_config.version
        self.current = util_table.merge_t(self.default, loaded_config)
    else
        current_version = self.commit
        self.current = util_table.deep_copy(self.default)
        self:save_no_timer()
    end

    if migration.need_migrate(current_version, self.commit) then
        self:backup()
        migration.migrate(current_version, self.commit, self.current)
        self:save_no_timer()
    end
end

---@return string
function this.get_backup_path()
    return util_misc.join_paths(
        this.name,
        string.format("%s_backup_v%s_%s", os.time(), this.current.version, util_misc.get_file_name(this.path))
    )
end

function this:backup()
    self:save_no_timer(this.get_backup_path())
end

---@return boolean
function this.init()
    this:load()
    this.gui:load()
    this.debug:load()
    this.lang.init(this)
    return true
end

return this
