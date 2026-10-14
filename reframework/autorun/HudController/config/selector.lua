---@class SelectorConfig : ConfigBase
---@field current SelectorSettings
---@field default SelectorSettings
---
---@field ref MainConfig
---@field data_path string
---@field path_backup string
---@field files table<string, ConfigFile>
---@field files_backup table<string, ConfigFile>
---@field sorted string[]
---@field sorted_backup string[]
---@field default_name string
---@field new_name string
---@field next_file ConfigFile?

---@class (exact) ConfigFile
---@field display_name string
---@field name string
---@field file_name string
---@field path string

local config_base = require("HudController.util.misc.config_base")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@class SelectorConfig
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = config_base })

this.default_name = "Default Config"
this.new_name = "New Config"

---@param default_settings SelectorSettings
---@param path string
---@param ref MainConfig
---@return SelectorConfig
function this:new(default_settings, path, ref)
    local o = config_base.new(self, default_settings, path)
    setmetatable(o, self)
    ---@cast o SelectorConfig
    o.ref = ref
    o.files = {}
    o.sorted = {}
    o.files_backup = {}
    o.sorted_backup = {}
    o.data_path = o.ref.name
    o.path_backup = util_misc.join_paths_b(o.data_path, "backups")
    return o
end

---@param path string
---@param no_subfolders boolean?
---@return table<string, ConfigFile>
function this:get_files(path, no_subfolders)
    ---@type table<string, ConfigFile>
    local ret = {}
    local files = fs.glob(path .. [[\\.*config.json]])
    no_subfolders = no_subfolders or false

    for i = 1, #files do
        local file = files[i]
        if (no_subfolders and not file:find("[/\\].+[/\\]")) or not no_subfolders then
            local name = util_misc.get_file_name(file, false)
            name = name:match("(.+)[_.]config")
            if name == "" or name == this.default_name then
                goto continue
            end

            local display_name = name or this.default_name
            name = name or ""

            ret[display_name] = {
                path = file,
                name = name,
                file_name = util_misc.get_file_name(file),
                display_name = display_name,
            }
        end
        ::continue::
    end

    return ret
end

---@param files table<string, ConfigFile>
---@return string[]
function this:sort_files(files)
    return util_table.sort(util_table.keys(files))
end

function this:load()
    self.files = self:get_files(self.data_path, true)
    self.sorted = self:sort_files(self.files)
    self.files_backup = self:get_files(self.path_backup)
    self.sorted_backup = self:sort_files(self.files_backup)

    local loaded_config = json.load_file(self.path) --[[@as SelectorSettings?]]
    if loaded_config then
        self.current = util_table.merge(self.default, loaded_config)
        self.current.combo_file = util_table.index(self.sorted, function(o)
            return self.files[o].file_name == loaded_config.file
        end) --[[@as integer]]
        self:_swap_config_path(self.current.file)
        self:save_no_timer()
    end
end

function this:reload()
    self.current.combo_file_backup = 1
    self.files_backup = self:get_files(self.path_backup)
    self.sorted_backup = self:sort_files(self.files_backup)

    local file = self.files[self.sorted[self.current.combo_file]]
    self.files = self:get_files(self.data_path, true)

    if not self.files[file.display_name] then
        self.ref:save_no_timer()
        self.files[file.display_name] = file
    end

    self.sorted = self:sort_files(self.files)
    self.current.combo_file = util_table.index(self.sorted, function(o)
        return o == file.display_name
    end) --[[@as integer]]
    self:save_no_timer()
end

function this:swap()
    local file = self.files[self.sorted[self.current.combo_file]]
    if file.file_name ~= self.current.file then
        self.next_file = file
    else
        self.next_file = nil
    end

    self:save_no_timer()
end

---@return string
function this:get_message()
    if not self.next_file then
        return self:get_current_display_name()
    end

    return string.format(
        "%s -> %s (%s)",
        self:get_current_display_name(),
        self.next_file.display_name,
        self.ref.lang:tr("selector.text_wait_reset")
    )
end

---@return string
function this:get_current_display_name()
    for display_name, file in pairs(self.files) do
        if file.file_name == self.current.file then
            return display_name
        end
        ---@diagnostic disable-next-line: missing-return
    end
end

function this:on_reset()
    if self.next_file then
        self.current.file = self.next_file.file_name
        self.next_file = nil
        self:save_no_timer()
    end
end

---@return ConfigFile
function this:new_file()
    local file = self.files[self.sorted[self.current.combo_file]]
    local new_file = {
        display_name = self:get_name(this.new_name),
    }
    new_file.file_name = self:get_file_name(new_file.display_name)
    new_file.path = util_misc.join_paths(self.ref.name, new_file.file_name)

    self.files[new_file.display_name] = new_file --[[@as ConfigFile]]
    self.sorted = self:sort_files(self.files)
    self.current.combo_file = util_table.index(self.sorted, function(o)
        return o == file.display_name
    end) --[[@as integer]]
    self:save_no_timer()
    json.dump_file(new_file.path, self.ref.default)
    return new_file --[[@as ConfigFile]]
end

---@param new_name string
function this:rename_current_file(new_name)
    if not self:is_valid_name(new_name) or new_name == this.default_name then
        return
    end

    local old_key = self.sorted[self.current.combo_file]
    local file = self.files[old_key]
    local old_path = file.path
    new_name = self:get_name(new_name)

    file.display_name = new_name
    file.file_name = self:get_file_name(new_name)
    file.path = util_misc.join_paths(self.ref.name, file.file_name)

    self.ref.save_timer:abort()
    self:_swap_config_path(file.file_name)
    if not util_misc.file_exists(old_path) then
        self.ref:save_no_timer()
    else
        hudcontroller_util.rename(old_path, file.path)
    end

    self.files[old_key] = nil
    self.files[file.display_name] = file
    self.sorted = self:sort_files(self.files)
    self.current.combo_file = util_table.index(self.sorted, function(o)
        return o == file.display_name
    end) --[[@as integer]]
    self:save_no_timer()
end

---@return boolean
function this:delete_current_file()
    local file = self.files[self.sorted[self.current.combo_file]]
    if not util_misc.file_exists(file.path) or hudcontroller_util.remove(file.path) then
        if file == self.next_file then
            self.next_file = nil
        end

        self.files[file.display_name] = nil
        self.sorted = self:sort_files(self.files)
        self.current.combo_file = math.max(self.current.combo_file - 1, 1)
        self:save_no_timer()
        return true
    end

    return false
end

---@return boolean
function this:restore_backup()
    local name = self.sorted_backup[self.current.combo_file_backup]
    if not name then
        return false
    end

    local file = self.files_backup[name]
    if not util_misc.file_exists(file.path) then
        return false
    end

    local file_name = self:get_file_name(self:get_name(name))
    local ret = hudcontroller_util.rename(file.path, util_misc.join_paths(self.ref.name, file_name))

    if ret then
        local combo_index = self.current.combo_file_backup
        self:reload()
        self.current.combo_file_backup = math.max(combo_index - 1, 1)
    end

    return ret
end

---@return boolean
function this:delete_current_backup()
    local file = self.files_backup[self.sorted_backup[self.current.combo_file_backup]]
    if not util_misc.file_exists(file.path) or hudcontroller_util.remove(file.path) then
        self.files_backup[file.display_name] = nil
        self.sorted_backup = self:sort_files(self.files_backup)
        self.current.combo_file_backup = math.max(self.current.combo_file_backup - 1, 1)
        self:save_no_timer()
        return true
    end

    return false
end

---@protected
---@param file string
function this:_swap_config_path(file)
    self.ref.path = util_misc.join_paths(self.ref.name, file)
end

function this:duplicate_current_file()
    local file = self.files[self.sorted[self.current.combo_file]]
    local new_file = {
        display_name = self:get_name(file.display_name),
    }
    new_file.file_name = self:get_file_name(new_file.display_name)
    new_file.path = util_misc.join_paths(self.ref.name, new_file.file_name)

    self.files[new_file.display_name] = new_file --[[@as ConfigFile]]
    self.sorted = self:sort_files(self.files)
    self.current.combo_file = util_table.index(self.sorted, function(o)
        return o == file.display_name
    end) --[[@as integer]]
    self:save_no_timer()
    json.dump_file(new_file.path, self.ref.current)
end

---@param display_name string
---@return string
function this:get_file_name(display_name)
    assert(self:is_valid_name(display_name), "Invalid config filename")
    return display_name .. ".config.json"
end

---@protected
---@param display_name string
---@return string
function this:_get_file_name_old(display_name)
    return display_name .. "_config.json"
end

---@param display_name string
---@return string
function this:get_name(display_name)
    if display_name == this.default_name then
        display_name = display_name .. 1
    end

    local ret = display_name
    local i = 1

    while
        util_misc.file_exists(util_misc.join_paths(self.ref.name, self:get_file_name(ret)))
        or util_misc.file_exists(util_misc.join_paths(self.ref.name, self:_get_file_name_old(ret)))
    do
        ret = display_name .. i
        i = i + 1
    end

    return ret
end

---@param name string
---@return boolean
function this:is_valid_name(name)
    if type(name) ~= "string" or name == "" then
        return false
    end

    if not name:match("^[%w _%.%-]+$") then
        return false
    end

    return name ~= "." and name ~= ".."
end

function this:export()
    imgui.set_clipboard(json.dump_string(self.ref.current))
end

function this:import()
    local file = self.files[self.sorted[self.current.combo_file]]
    local config_data = json.load_string(imgui.get_clipboard()) --[[@as MainSettings]]
    json.dump_file(file.path, config_data)
end

---@return boolean
function this:try_import()
    local config_data = json.load_string(imgui.get_clipboard())
    if not config_data then
        return false
    end

    if not config_data.mod then
        return false
    end

    return true
end

return this
