local call_queue = require("HudController.hud.call_queue")
local common = require("HudController.hud.hook.common")
local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local hud = require("HudController.hud.init")
local util_ref = require("HudController.util.ref.init")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map
local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

local this = {}
local dmg_static = false

--#region update
function this.update_pre(args)
    if not common.is_ok() then
        return
    end

    util_ref.capture_this(args, 3)
end

function this.update_post(retval)
    if not common.is_ok() then
        return
    end

    local disp_ctrl = util_ref.get_this() --[[@as app.cGUIHudDisplayControl?]]
    if not disp_ctrl then
        return
    end

    local hudbase = disp_ctrl:get_Owner()
    local gui_id = hudbase:get_ID()

    call_queue.consume(gui_id)

    local hud_elem = hud.get_element_by_guiid(gui_id)

    -- NamesAccess is updated here @update_name_access_icons_post
    if not hud_elem or hud_elem.hud_id == rl(ace_enum.hud, "NAME_ACCESSIBLE") then
        return
    end

    hud_elem:write(hudbase, gui_id, disp_ctrl._TargetControl)
end
--#endregion

function this.update_target_reticle_post(retval)
    local hud_elem, guiid = common.get_elem_consume_t(
        "TargetReticle",
        ace_map.additional_hud_to_guiid_name["TARGET_RETICLE"]
    )
    if not hud_elem then
        return
    end

    local hudbase = util_ref.get_this() --[[@as app.GUI020021]]
    ---@diagnostic disable-next-line: param-type-mismatch
    hud_elem:write(hudbase, guiid, hudbase:get__Main())
end

function this.update_menu_button_guide_post(retval)
    local hud_elem, guiid =
        common.get_elem_consume_t(nil, ace_map.additional_hud_to_guiid_name["MENU_BUTTON_GUIDE"])
    if not hud_elem then
        return
    end

    local hudbase = util_ref.get_this() --[[@as app.GUI000008]]
    ---@diagnostic disable-next-line: param-type-mismatch
    hud_elem:write(hudbase, guiid, hudbase:get_Control())
end

--#region damage_numbers
function this.update_damage_numbers_static_pre(args)
    dmg_static = util_ref.to_bool(args[9])
end

function this.update_damage_numbers_post(retval)
    local dmg, guiid = common.get_elem_consume_t(
        "DamageNumbers",
        ace_map.additional_hud_to_guiid_name["DAMAGE_NUMBERS"]
    )
    if dmg and guiid then
        util_table.do_something(
            dmg_static and dmg:get_dmg_static() or dmg:get_dmg(),
            function(_, key, _)
                dmg:write(key, guiid, nil)
            end
        )
    end

    dmg_static = false
end
--#endregion

function this.update_training_room_hud_post(retval)
    local training_room_hud, guiid = common.get_elem_consume_t(
        "TrainingRoomHud",
        ace_map.additional_hud_to_guiid_name["TRAINING_ROOM_HUD"]
    )
    if training_room_hud then
        local hudbase = util_ref.get_this() --[[@as app.GUI600100]]
        local ctrl = training_room_hud:get_pnl_all()
        if ctrl then
            ---@diagnostic disable-next-line: param-type-mismatch
            training_room_hud:write(hudbase, guiid, ctrl)
        end
    end
end

function this.update_name_access_icons_post(retval)
    local name_access = common.get_elem_t("NameAccess")
    if name_access then
        local GUI020001PanelBase = util_ref.get_this() --[[@as app.GUI020001PanelBase]]
        local params = GUI020001PanelBase:get_Params()
        local owner = params:get_MyOwner()

        name_access:write(owner, owner:get_ID(), GUI020001PanelBase:get_BasePanel())
    end
end

function this.update_subtitles_pre(args)
    local subtitles, guiid =
        common.get_elem_consume_t("Subtitles", ace_map.additional_hud_to_guiid_name["SUBTITLES"])
    if subtitles then
        local subman = sdk.to_managed_object(args[2])--[[@as app.cDialogueSubtitleManager]]
        local GUI020400 = subman._SubtitlesGUI

        if not GUI020400 then
            return
        end

        ---@diagnostic disable-next-line: param-type-mismatch
        subtitles:write(GUI020400, guiid, subtitles:get_scale_panel(GUI020400))
    end

    local subtitles_choice, guiid = common.get_elem_consume_t(
        "SubtitlesChoice",
        ace_map.additional_hud_to_guiid_name["SUBTITLES_CHOICE"]
    )
    if subtitles_choice then
        local subman = sdk.to_managed_object(args[2])--[[@as app.cDialogueSubtitleManager]]
        local GUI020401 = subman._ChoiceGUI

        if not GUI020401 then
            return
        end

        ---@diagnostic disable-next-line: param-type-mismatch
        subtitles_choice:write(GUI020401, guiid, subtitles_choice:get_scale_panel(GUI020401))
    end
end

function this.update_barrel_score_post(retval)
    local barrel_score, guiid = common.get_elem_consume_t("BarrelScore", "UI090901")
    if barrel_score and guiid then
        local GUI090901 = util_ref.get_this() --[[@as app.GUI090901]]
        local disp_ctrl = GUI090901._DisplayControl
        barrel_score:write(GUI090901, guiid, disp_ctrl._TargetControl)
    end
end

return this
