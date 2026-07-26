---@class UserManager
---@field loaded table<string, table>
---@field files table<string, boolean>
---@field failed table<string, string>
---@field dir string

local config = require("HudController.config.init")
local util_misc = require("HudController.util.misc.util")
local util_mod = require("HudController.util.mod.init")

---@class UserManager
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param dir string
---@return UserManager
function this:new(dir)
    local o = { loaded = {}, files = {}, failed = {}, dir = dir }
    return setmetatable(o, self)
end

---@protected
function this:_clear_config()
    local config_user = self:get_config()
    for name, _ in pairs(config_user) do
        if not self.files[name] then
            config_user[name] = nil
        end
    end
end

---@return table<string, boolean>
function this:get_config()
    return config:get("mod." .. self.dir)
end

---@return boolean
function this:is_need_attention()
    for name, enabled in pairs(self:get_config()) do
        if (enabled ~= (self.loaded[name] ~= nil)) or self.failed[name] then
            return true
        end
    end

    return false
end

---@param file_name string
---@diagnostic disable-next-line: unused-local
function this:load_file(file_name) end

---@return boolean
function this:init()
    local config_user = self:get_config()
    local files = util_mod.get_user_files(self.dir)

    for _, file in pairs(files) do
        local name = util_misc.get_file_name(file, false)

        if util_mod.is_ok_user_file(name) then
            self.files[name] = true

            if config_user[name] == nil then
                config_user[name] = true
            end

            if config_user[name] then
                self:load_file(name)
            end
        end
    end

    self:_clear_config()
    return true
end

function this:reinit()
    local config_user = self:get_config()
    for name, _ in pairs(self.files) do
        if config_user[name] == nil then
            if self.loaded[name] or self.failed[name] then
                config_user[name] = true
            else
                config_user[name] = false
            end
        end
    end

    self:_clear_config()
end

return this
