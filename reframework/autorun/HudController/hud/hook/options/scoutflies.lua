local common = require("HudController.hud.hook.common")
local hud = require("HudController.hud.init")

local this = {}

function this.disable_scoutflies_pre(_)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_scoutflies") then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.disable_scoutflies_post(_)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_scoutflies") then
        return false
    end
end

return this
