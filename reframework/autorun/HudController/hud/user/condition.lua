local bind_condition = require("HudController.hud.bind_condition.init")
local util_misc = require("HudController.util.misc.util")
local logger = require("HudController.util.misc.logger").g
local config = require("HudController.config.init")
local user_base = require("HudController.hud.def.user_file_manager_base")

---@class UserConditionManager : UserManager
local this = user_base:new("user_conditions")

---@param file_name string
function this:load_file(file_name)
    util_misc.try(function()
        local module =
            require(string.format("reframework.data.%s.user_conditions.%s", config.name, file_name)) --[[@as CustomCondition | fun()]]
        ---@type CustomCondition
        local cond

        if type(module) == "function" then
            cond = module() --[[@as CustomCondition]]
        else
            cond = module:new() --[[@as CustomCondition]]
        end

        bind_condition.register_condition(cond)
        ---@diagnostic disable-next-line: assign-type-mismatch
        self.loaded[file_name] = module
        logger:info(string.format("[UserCondition] %s loaded.", file_name))
    end, function(err)
        self.failed[file_name] = util_misc.wrap_text(
            string.format("[UserCondition] %s failed: %s.", file_name, err),
            100
        )
        logger:error(string.format("[UserCondition] %s failed: %s.", file_name, err))
    end)
end

return this
