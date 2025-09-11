local config = require("HudController.config.init")
local util_misc = require("HudController.util.misc.util")
local logger = require("HudController.util.misc.logger").g

local this = {
    ---@type table<string, table>
    loaded = {},
    ---@type table<string, boolean>
    files = {},
    ---@type table<string, string>
    failed = {},
}

local function clear_config()
    local config_user = config.current.mod.user_scripts
    for name, _ in pairs(config_user) do
        if not this.files[name] then
            config_user[name] = nil
        end
    end
end

function this.reinit()
    local config_user = config.current.mod.user_scripts

    for name, _ in pairs(this.files) do
        if config_user[name] == nil then
            if this.loaded[name] or this.failed[name] then
                config_user[name] = true
            else
                config_user[name] = false
            end
        end
    end

    clear_config()
end

---@return boolean
function this.is_need_attention()
    for name, enabled in pairs(config.current.mod.user_scripts) do
        if (enabled ~= (this.loaded[name] ~= nil)) or this.failed[name] then
            return true
        end
    end

    return false
end

---@return boolean
function this.init()
    for k, v in
        pairs(package.loaded --[[@as table<string ,table>]])
    do
        k = string.match(k, "^(HudController.*)%.init$")
        if k then
            ---@diagnostic disable-next-line: no-unknown
            package.loaded[k] = v
        end
    end

    local config_user = config.current.mod.user_scripts
    local files = fs.glob(util_misc.join_paths_b(config.name, "user_scripts", ".*lua"))

    for _, file in pairs(files) do
        local name = util_misc.get_file_name(file, false)

        if not string.find(name, "example") and not string.match(name, "^_") then
            this.files[name] = true

            if config_user[name] == nil then
                config_user[name] = true
            end

            if config_user[name] then
                util_misc.try(function()
                    this.loaded[name] = require(
                        string.format("reframework.data.%s.user_scripts.%s", config.name, name)
                    )
                    logger:info(string.format("[UserScript] %s loaded.", name))
                end, function(err)
                    this.failed[name] = util_misc.wrap_text(
                        string.format("[UserScript] %s failed: %s.", name, err),
                        100
                    )
                    logger:error(this.failed[name])
                end)
            end
        end
    end

    clear_config()
    return true
end

return this
