local ace_player = require("HudController.util.ace.player")
local common = require("HudController.hud.hook.common")
local e = require("HudController.util.game.enum")
local play_object = require("HudController.hud.play_object.init")

local this = {}
local ammo_slider = {
    open = false,
    item_slider_open = false,
}

function this.no_hide_ammo_slider_parts_pre(args)
    local ammo = common.get_elem_t("Ammo")
    if ammo and not ammo.hide and ammo.no_hide_parts then
        -- setting slider status to Active before its actually open
        -- app.GUI020007.controlSliderStatus closes parts when BulletSliderStatus transitions from Default to Active
        -- or its opened with ctrl
        local GUI020007 = sdk.to_managed_object(args[2]) --[[@as app.GUI020007]]
        local flag =
            ace_player.check_continue_flag(e.get("app.HunterDef.CONTINUE_FLAG").OPEN_ITEM_SLIDER)
        local open_timer = GUI020007:get__OpenTimer()
        local is_rapid = GUI020007:get_IsRapidMode()

        if
            (not flag and ammo_slider.item_slider_open)
            or (not flag and open_timer <= 0 and is_rapid)
        then
            -- this is necessary when in rapid mode, to avoid fade in of energy bar
            GUI020007:setBulletSliderState("UNFOCUS")
            GUI020007:set__SliderStatus(e.get("app.GUI020007.BulletSliderStatus").Default)

            -- prevents lingering after opening with ctrl
            GUI020007:set__OpenTimer(0.0)
            ammo_slider.open = false
            ammo_slider.item_slider_open = false
        end

        if GUI020007:get__SliderStatus() == e.get("app.GUI020007.BulletSliderStatus").Default then
            ammo_slider.open = false
            ammo_slider.item_slider_open = false
        end

        -- opened with scroll
        if open_timer > 0 then
            GUI020007:set__SliderStatus(e.get("app.GUI020007.BulletSliderStatus").Active)
            ammo_slider.open = true
        end

        -- opened with ctrl
        if flag and not ammo_slider.open then
            ammo_slider.open = true
            ammo_slider.item_slider_open = true

            GUI020007:set__SliderStatus(e.get("app.GUI020007.BulletSliderStatus").Active)
            -- opening with scroll instead,
            GUI020007:callbackOther(GUI020007.SLOT_DOWN, nil, nil, 0)
            GUI020007:callbackOther(GUI020007.SLOT_UP, nil, nil, 0)
            -- stoping scroll animation
            GUI020007:setBulletSliderState("FOCUS")
        end

        -- function has to be skipped when in rapid mode, something there spams fadein on energy bar,
        -- not sure how else deal with it
        if GUI020007:get_IsRapidMode() then
            local pnl_slider = GUI020007:get__PanelBulletSlider()
            local pnl_pat = play_object.control.get_parent(pnl_slider, "PNL_Pat00") --[[@as via.gui.Control]]
            local pnl_change = play_object.control.get(pnl_pat, "PNL_change") --[[@as via.gui.Control]]

            -- force opacity
            local scale = pnl_change:get_ColorScale()
            scale.w = 1.0
            pnl_change:set_ColorScale(scale)

            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end

function this.no_hide_ammo_slider_reload_pre(args)
    local ammo = common.get_elem_t("Ammo")
    if ammo and not ammo.hide and ammo.no_hide_parts and not ammo.children.reload.hide then
        local GUI020007 = sdk.to_managed_object(args[2]) --[[@as app.GUI020007]]
        local slider_pnl = GUI020007:get__PanelBulletSlider()
        local pnl = play_object.control.get(slider_pnl, {
            "PNL_reload",
        }) --[[@as via.gui.Control]]

        if GUI020007:get__SliderStatus() ~= e.get("app.GUI020007.BulletSliderStatus").Active then
            return
        end

        local req_playstate = (sdk.to_managed_object(args[3]) --[[@as System.String]]):ToString()
        if req_playstate ~= "FADE_OUT" then
            pnl:set_PlayState("DEFAULT")
            pnl:set_Visible(true)
        else
            pnl:set_PlayState("HIDDEN")
            pnl:set_Visible(false)
        end

        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

return this
