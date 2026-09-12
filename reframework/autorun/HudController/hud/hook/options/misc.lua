local common = require("HudController.hud.hook.common")
local hud = require("HudController.hud.init")

local this = {}

function this.disable_area_intro_pre(_)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_area_intro") then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

return this
