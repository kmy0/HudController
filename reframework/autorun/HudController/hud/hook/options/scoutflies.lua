local common = require("HudController.hud.hook.common")
local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local hud = require("HudController.hud.init")
local s = require("HudController.util.ref.singletons")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

local this = {}

function this.disable_scoutflies_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_scoutflies") then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.disable_scoutflies_target_tracking_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_scoutflies") then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end

    if hud_config and hud.get_hud_option("hide_monster_icon") then
        local target_access = sdk.to_valuetype(args[3], "app.TARGET_ACCESS_KEY") --[[@as app.TARGET_ACCESS_KEY]]
        if target_access.Category == rl(ace_enum.target_access, "ENEMY") then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.disable_scoutflies_post(retval)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_scoutflies") then
        return false
    end
end

function this.hide_map_navi_points_post(retval)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_scoutflies") then
        return false
    end

    if hud_config and hud.get_hud_option("hide_monster_icon") then
        local insman = s.get("app.GuideInsectManager")
        local ctrl = insman:getMasterEntityNavigationController()

        if not ctrl then
            return
        end

        local ctx = ctrl:get_Context()
        local target_info = ctx.TargetInfo
        local nav_info = target_info:get_CurrentNavigationTargetInfoGuideInsect()
        if nav_info then
            local target_access = nav_info:getTargetAccessKey()
            if target_access.Category == rl(ace_enum.target_access, "ENEMY") then
                return false
            end
        end
    end
end

return this
