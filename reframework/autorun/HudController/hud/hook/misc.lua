local play_object_defaults = require("HudController.hud.defaults.play_object")

local this = {}

function this.reset_hud_default_post(retval)
    play_object_defaults.clear()
end

return this
