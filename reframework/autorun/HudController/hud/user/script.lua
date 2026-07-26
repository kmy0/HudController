local config = require("HudController.config.init")
local util_misc = require("HudController.util.misc.util")
local logger = require("HudController.util.misc.logger").g
local user_base = require("HudController.hud.def.user_file_manager_base")

---@class UserScriptManager : UserManager
local this = user_base:new("user_scripts")

---@param file_name string
function this:load_file(file_name)
    util_misc.try(function()
        self.loaded[file_name] =
            require(string.format("reframework.data.%s.user_scripts.%s", config.name, file_name))
        logger:info(string.format("[UserScript] %s loaded.", file_name))
    end, function(err)
        self.failed[file_name] =
            util_misc.wrap_text(string.format("[UserScript] %s failed: %s.", file_name, err), 100)
        logger:error(self.failed[file_name])
    end)
end

return this
