local ace_player = require("HudController.util.ace.player")
local custom_condition = require("HudController.hud.bind_weapon.conditions.custom")

return function()
    return custom_condition.new_condition("In Combat", function(self)
        return ace_player.is_combat()
    end, true)
end
