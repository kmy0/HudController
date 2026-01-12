local cache = require("HudController.util.misc.cache")
local play_object_defaults = require("HudController.hud.defaults.init").play_object

local this = {}

function this.reset_hud_default_post(retval)
    play_object_defaults:clear()
    cache.clear_all()
end

function this.reset_cache_post(retval)
    cache.clear_all()
end

return this
