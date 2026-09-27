local common = require("HudController.hud.hook.common")
local hud = require("HudController.hud.init")
local hud_def = require("HudController.data.option.hud").opt

local this = {}

function this.disable_area_intro_pre(_)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option(hud_def.disable_area_intro) then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

return this
