local ace_porter = require("HudController.util.ace.porter")
local common = require("HudController.hud.hook.common")
local config = require("HudController.config.init")
local e = require("HudController.util.game.enum")
local hud = require("HudController.hud.init")
local timer = require("HudController.util.misc.timer")

local this = {}
local porter = {
    hide_timer = timer:new(config.porter_timeout, nil, true),
    call_timer = timer:new(config.porter_timeout),
    hidden = false,
}

function this.disable_porter_call_cmd_pre(_)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_porter_call") then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.update_porter_call_post(_)
    local hud_config = common.get_hud()
    if
        hud_config
        and hud.get_hud_option("hide_porter")
        and not hud.get_hud_option("disable_porter_call")
    then
        porter.call_timer:restart()
    end
end

function this.hide_porter_post(_)
    local hud_config = common.get_hud()
    if not hud_config then
        return
    end

    if
        hud_config
        and hud.get_hud_option("hide_porter")
        and not ace_porter.is_master_riding()
        and not porter.call_timer:active()
        and not ace_porter.is_master_quest_interrupt()
    then
        if
            not porter.hide_timer:started()
            or (not porter.hidden and porter.hide_timer:active() and ace_porter.is_master_touch())
        then
            porter.hide_timer:restart()
        end

        if porter.hidden or porter.hide_timer:finished() then
            ace_porter.change_fade_speed(0.5)
            ace_porter.set_master_continue_flag(
                e.get("app.PorterDef.CONTINUE_FLAG").DISABLE_RIDE_HUNTER,
                true
            )
            ace_porter.set_master_continue_flag(
                e.get("app.PorterDef.CONTINUE_FLAG").ALPHA_ZERO,
                true
            )
            porter.hidden = true
        end
    elseif porter.hide_timer:finished() then
        porter.hide_timer:abort()
        ace_porter.change_fade_speed(5.0)
        porter.hidden = false
    end
end

function this.disable_porter_nav_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_porter_tracking") then
        local target_access = sdk.to_valuetype(args[3], "app.TARGET_ACCESS_KEY") --[[@as app.TARGET_ACCESS_KEY]]
        if target_access.Category == e.get("app.TARGET_ACCESS_KEY.CATEGORY").ENEMY then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

return this
