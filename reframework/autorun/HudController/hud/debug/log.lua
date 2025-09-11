local logger = require("HudController.util.misc.logger").g
local config = require("HudController.config.init")

local this = {
    ---@type table<string, boolean>
    cache = {},
}

---@enum LogDebugType
this.log_debug_type = {
    BASE = 1,
    CONTROL_GETTER = 2,
    CACHE = 3,
    GAME_CLASS = 4,
    CONTROL_GETTER_ITER = 5,
}
---@type table<LogDebugType, string[]>
this.known_errors = {
    [this.log_debug_type.BASE] = {},
    [this.log_debug_type.CONTROL_GETTER] = {
        "hud_base%.hud_child%.part_base%.timer%.quest_timer%.best_timer",
        "hud_base%.hud_child%.part_base%.timer%.quest_timer",
        "hud_base%.hud_child%.part_base%.task%.faint",
        "hud_base%.hud_child%.focus",
    },
    [this.log_debug_type.CACHE] = {},
    [this.log_debug_type.GAME_CLASS] = {
        "Game Classes: app%.GUI020000, app%.GUI020002.*Class Chain: hud_base%.slinger_reticle",
        "Game Classes: app%.GUI020023, app%.GUI020024, app%.GUI020027, app%.GUI020029, app%.GUI020030, app%.GUI020033, app%.GUI020034.*Class Chain: hud_base%.weapon,",
        "Game Classes: app%.GUI060010, app%.GUI060011,.*Class Chain: hud_base%.minimap",
    },
    [this.log_debug_type.CONTROL_GETTER_ITER] = {
        'Ctrl: PNL_Scale\nArguments: {{"PNL_Pat00", "PNL_Radar", "PNL_OutFrameIconMain"}, "PNL_OutFrameIcon00", true}',
    },
}

---@param message string
---@param log_type LogDebugType?
function this.log(message, log_type)
    if config.debug.current.debug.filter_known_errors then
        if this.cache[message] == nil then
            log_type = log_type or this.log_debug_type.BASE

            for _, pattern in pairs(this.known_errors[log_type]) do
                if message:match(pattern) then
                    this.cache[message] = true
                    break
                end
            end

            this.cache[message] = this.cache[message] or false
        end

        if this.cache[message] then
            return
        end
    end

    logger:debug(message)
end

return this
