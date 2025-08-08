local play_object = require("HudController.hud.play_object")

local this = {}

function this.reset_hud_default_post(retval)
    play_object.default.clear()
end

return this
