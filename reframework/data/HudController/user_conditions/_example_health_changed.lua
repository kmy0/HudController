local ace_player = require("HudController.util.ace.player")
local custom_condition = require("HudController.hud.bind_condition.conditions.custom")
local frame_counter = require("HudController.util.misc.frame_counter")
local timer = require("HudController.util.misc.timer")

local this = {}
this.__index = this
setmetatable(this, { __index = custom_condition })

function this:new()
    local o = custom_condition.new(self, "Health Changed")
    setmetatable(o, self)

    local options = o:get_additional_options_table()
    -- when condition is created for the first time, option table wont be available in the config
    o.timer = timer:new(options and options.duration or 3)
    o.health_last_frame = -1
    o.last_frame = frame_counter.frame

    return o
end

function this:update()
    local char = ace_player.get_master_char()
    if not char then
        return false
    end

    local health = char:get_HunterHealth()
    local health_manager = health:get_HealthMgr()

    if not health_manager then
        return false
    end

    local current_health = health_manager:get_Health()

    if
        self.health_last_frame ~= -1
        and self.health_last_frame ~= current_health
        and math.abs(frame_counter.frame - self.last_frame) <= 30
    then
        self.timer:restart()
    end

    self.health_last_frame = current_health
    self.last_frame = frame_counter.frame
    return self.timer:active()
end

function this:new_additional_options()
    return {
        duration = 3,
    }
end

function this:draw_additional_options()
    local options = self:get_additional_options_table()
    local changed

    changed, options.duration = imgui.slider_int("Duration", options.duration, 1, 10)

    if changed then
        self.timer:update_args(options.duration)
        self:save_config()
    end
end

function this:reset()
    self.timer:abort()
    self.health_last_frame = -1
end

return this
