local ace_item = require("HudController.util.ace.item")
local common = require("HudController.hud.hook.common")
local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local hud = require("HudController.hud.init")
local s = require("HudController.util.ref.singletons")
local util_game = require("HudController.util.game.init")
local util_ref = require("HudController.util.ref.init")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

local this = {}

---@return boolean?, boolean?
local function is_result_skip()
    local hud_config = common.get_hud()
    local skip = hud_config and hud.get_hud_option("skip_quest_result")
    local notice = common.get_elem_t("Notice")
    local skip_seamless = notice
        and (notice.hide or notice.system_log.ALL or notice.system_log["QUEST_RESULT"])
    return skip, skip_seamless
end

function this.disable_quest_end_camera_post(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_quest_end_camera") then
        return false
    end
end

--#region disable_quest_end_outro/disable_quest_intro
function this.disable_quest_intro_outro_post(retval)
    local hud_config = common.get_hud()
    if hud_config then
        local GUI020201 = util_ref.get_this() --[[@as app.GUI020201]]
        local type = GUI020201._CurType
        local name = ace_enum.quest_gui_type[type]

        if
            (name == "START" and hud.get_hud_option("disable_quest_intro"))
            or hud.get_hud_option("disable_quest_end_outro")
        then
            local pnl = GUI020201._StampPanels:get_Item(type) --[[@as via.gui.Panel]]
            pnl:set_PlayState("DISABLE")
        end
    end
end

function this.stop_hide_gui_post(retval)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_quest_end_outro") then
        local quest_dir = util_ref.get_this() --[[@as app.cQuestDirector]]
        local flow = quest_dir:get_CurFlow()

        if not flow then
            return
        end

        local flows = {
            "app.cQuestSuccessShowingBefore",
            "app.cQuestSuccessShowing",
            "app.cQuestResult",
        }

        if
            util_table.any(flows, function(key, value)
                return util_ref.is_a(flow, value)
            end)
        then
            local guiman = s.get("app.GUIManager")
            local flags = guiman:get_AppContinueFlag()
            flags:off(rl(ace_enum.gui_continue_flag, "HIDE_GUI"))
        end
    end
end

function this.skip_quest_end_animation_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("disable_quest_end_outro") then
        local flow = sdk.to_managed_object(args[3]) --[[@as app.cQuestFlowPartsBase]]
        local before_flows = {
            "app.cQuestSuccessShowingBefore",
            "app.cQuestLeaveShowingBefore",
            "app.cQuestFailedShowingBefore",
        }
        local flows = {
            "app.cQuestFailedShowing",
            "app.cQuestSuccessShowing",
            "app.cQuestLeaveShowing",
            "app.cQuestResult",
        }

        for _, fl in pairs(before_flows) do
            if util_ref.is_a(flow, fl) then
                -- cba to type those
                flow:set_field("_ShowingBeforeTimer", 0.0)
                return sdk.PreHookResult.SKIP_ORIGINAL
            end
        end

        if
            util_table.any(flows, function(key, value)
                return util_ref.is_a(flow, value)
            end)
        then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end
--#endregion

--#region result skip
function this.hide_quest_result_setup_post(retval)
    local skip, skip_seamless = is_result_skip()
    if not skip and not skip_seamless then
        return
    end

    local flow = util_ref.get_this() --[[@as app.GUIFlowQuestResult.cContext]]
    if skip then
        flow:set_SkipReward(true)
    elseif skip_seamless then
        local mode = flow:getMode()
        if ace_enum.quest_result_mode[mode] == "SEAMLESS" then
            flow:set_SkipReward(true)
        end
    end
end

function this.hide_quest_result_pre(args)
    local skip, skip_seamless = is_result_skip()
    if
        skip
        or (
            skip_seamless
            and util_ref.is_a(
                sdk.to_managed_object(args[2]) --[[@as REManagedObject]],
                "app.GUIFlowQuestResult.Flow.SeamlessResultList"
            )
        )
    then
        util_ref.capture_this(args)
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.hide_quest_result_post(retval)
    local skip, skip_seamless = is_result_skip()
    if not skip and not skip_seamless then
        return
    end

    local flow = util_ref.get_this() --[[@as app.GUIFlowQuestResult.Flow.SeamlessResultList | app.GUIFlowQuestResult.Flow.FixResultList?]]
    if not flow then
        return
    end

    local flow_ctx = flow:get_Context()
    if flow_ctx:get_IsJudge() then
        local module_quest_result = s.get("app.GUIManager"):getQuestResult()
        local quest_result = module_quest_result:get_QuestResult()
        local judge_items = quest_result:get_JudgeItems()
        local item_infos = judge_items:get_ItemInfoList()

        util_game.do_something(item_infos, function(system_array, index, value)
            value:getReward(true, false)
        end)
    end

    if skip then
        flow:endFlow()
    elseif
        skip_seamless and util_ref.is_a(flow, "app.GUIFlowQuestResult.Flow.SeamlessResultList")
    then
        flow:endFlow()
    end
end
--#endregion

--#region skip_quest_end_timer/hide_quest_end_timer
function this.skip_quest_end_timer_open_pre(args)
    local hud_config = common.get_hud()
    if
        hud_config
        and (hud.get_hud_option("skip_quest_end_timer"))
        and sdk.to_int64(args[3]) == rl(ace_enum.gui_id, "UI020202")
    then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.skip_quest_end_timer_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("skip_quest_end_timer") then
        local quest_dir = s.get("app.MissionManager"):get_QuestDirector()
        quest_dir:QuestReturnSkip()
    end
end

function this.hide_quest_end_input_pre(args)
    local GUI020202 = sdk.to_managed_object(args[2]) --[[@as app.GUI020202]]
    local skip_panel = GUI020202._SkipPanel
    local input = GUI020202._Input
    local hud_config = common.get_hud()

    if
        hud_config
        and (
            not hud.get_hud_option("skip_quest_end_timer")
            and hud.get_hud_option("hide_quest_end_timer")
        )
    then
        input:setEnableCtrl(false)
        skip_panel:set_ForceInvisible(true)
    else
        input:setEnableCtrl(true)
        skip_panel:set_ForceInvisible(false)
    end
end
--#endregion

function this.skip_bowling_result_pre(args)
    local hud_config = common.get_hud()
    if hud_config and hud.get_hud_option("skip_quest_result") then
        local bowlfac = s.get("app.FacilityManager"):get_Bowling()
        local bowlup = s.get("app.GameMiniEventManager"):get_Bowling()
        local reward_rank = bowlup:get_TotalScoreRank()
        local rewards = bowlfac:getRewardItems(reward_rank)

        util_game.do_something(rewards, function(system_array, index, value)
            ace_item.add_item(value:get_ItemId(), value.Num)
        end)

        local reult_end = sdk.to_managed_object(args[2]) --[[@as app.cBowlingUpdater.cUpdater_ResultEnd]]
        reult_end._isEnd = true
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

return this
