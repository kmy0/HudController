local ace_player = require("HudController.util.ace.player")
local custom_condition = require("HudController.hud.bind_condition.conditions.custom")
local frame_counter = require("HudController.util.misc.frame_counter")
local timer = require("HudController.util.misc.timer")
local value_checker = require("HudController.util.misc.value_checker")

local this = {}
this.__index = this
setmetatable(this, { __index = custom_condition })

function this:new()
    local o = custom_condition.new(self, "Stamina Changed")
    setmetatable(o, self)

    local options = o:get_additional_options_table()
    -- when condition is created for the first time, option table wont be available in the config
    o.timer = timer:new(options and options.duration or 3)
    o.stamina = value_checker:new()
    o.frame = value_checker:new(frame_counter.frame, function(old_value, new_value)
        -- this makes sure that condtion wont trigger if last stamina check was over 30 frames ago
        return new_value - old_value <= 30
    end)

    return o
end

function this:update()
    local char = ace_player.get_master_char()
    if not char then
        return false
    end

    local stamina = char:get_HunterStamina()
    if not stamina then
        return false
    end

    local current_stamina = stamina:get_Stamina()
    local stamina_changed = self.stamina:is_changed(current_stamina)
    local frame_ok = self.frame:is_changed(frame_counter.frame)
    if stamina_changed and frame_ok then
        self.timer:restart()
    end

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
    self.stamina:reset()
    self.frame:reset()
end

return this
