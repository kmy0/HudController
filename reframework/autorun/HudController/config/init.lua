---@class MainConfig : ConfigBase
---@field current MainSettings
---@field default MainSettings
---
---@field lang Language
---@field gui GuiConfig
---@field debug DebugConfig
---@field selector SelectorConfig
---
---@field version string
---@field commit string
---@field name string
---
---@field hud_default_path string
---@field option_default_path string
---@field default_config_path string
---
---@field grid_size integer
---@field porter_timeout number
---@field handler_timeout number

local config_base = require("HudController.util.misc.config_base")
local lang = require("HudController.config.lang")
local migration = require("HudController.config.migration")
local selector_config = require("HudController.config.selector")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")
local version = require("HudController.config.version")

local mod_name = "HudController"
local config_path = util_misc.join_paths(mod_name, "config.json")

---@class MainConfig
local this = config_base:new(require("HudController.config.defaults.mod"), config_path)

this.version = version.version
this.commit = version.commit
this.name = mod_name

this.default_config_path = config_path
this.hud_default_path = util_misc.join_paths(this.name, "default", "hud.json")
this.option_default_path = util_misc.join_paths(this.name, "default", "option.json")

this.grid_size = 160
this.porter_timeout = 3
this.handler_timeout = 5

this.gui = config_base:new(
    require("HudController.config.defaults.gui"),
    util_misc.join_paths(this.name, "other_configs", "gui.json")
) --[[@as GuiConfig]]
this.debug = config_base:new(
    require("HudController.config.defaults.debug"),
    util_misc.join_paths(this.name, "other_configs", "debug.json")
) --[[@as DebugConfig]]
this.selector = selector_config:new(
    require("HudController.config.defaults.selector"),
    util_misc.join_paths(this.name, "other_configs", "selector.json"),
    this
)
this.lang = lang:new(
    require("HudController.config.defaults.lang"),
    util_misc.join_paths(this.name, "lang"),
    "en-us.json",
    this
)

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
        self.selector:load()
    end

    if migration.need_migrate(current_version, self.commit) then
        self:backup()
        migration.migrate(current_version, self.commit, self.current)
        self:save_no_timer()
    end
end

---@return string
function this:get_backup_path()
    return util_misc.join_paths(
        self.name,
        "backups",
        string.format(
            "%s_backup_v%s_%s",
            os.time(),
            self.current.version,
            util_misc.get_file_name(self.path)
        )
    )
end

function this:backup()
    self:save_no_timer(self:get_backup_path())
end

---@return boolean
function this.init()
    this.selector:load()
    this:load()
    this.gui:load()
    this.debug:load()
    this.lang:load()

    return true
end

return this
