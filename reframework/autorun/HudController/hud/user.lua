local config = require("HudController.config")
local util_misc = require("HudController.util.misc.util")

local this = {
    ---@type table<string, table>
    scripts = {},
}

local files = fs.glob(util_misc.join_paths_b(config.name, "user_scripts", ".*lua"))
for _, file in pairs(files) do
    local name = util_misc.get_file_name(file, false)
    if name ~= "example" then
        this[name] = require(string.format("reframework.data.%s.user_scripts.%s", config.name, name))
    end
end

return this
