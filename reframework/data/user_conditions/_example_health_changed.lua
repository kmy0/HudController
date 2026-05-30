local ace_player = require("HudController.util.ace.player")
local custom_condition = require("HudController.hud.bind_weapon.conditions.custom")
local frame_counter = require("HudController.util.misc.frame_counter")
local timer = require("HudController.util.misc.timer")

local this = {}
this.__index = this
setmetatable(this, { __index = custom_condition })

function this:new()
    local o = custom_condition.new(self, "Health Changed", true)
    setmetatable(o, self)
    o.timer = timer:new(3)
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

function this:reset()
    self.timer:abort()
    self.health_last_frame = -1
end

return this
