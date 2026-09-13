local ace_item = require("HudController.util.ace.item")
local common = require("HudController.hud.hook.common")
local e = require("HudController.util.game.enum")
local s = require("HudController.util.ref.singletons")
local util_game = require("HudController.util.game.init")
local mod_enum = require("HudController.data.mod").enum

local this = {}

function this.skip_quest_end_timer_open_pre(args)
    local quest_end_timer = common.get_elem_t("QuestEndTimer")
    if
        quest_end_timer
        and quest_end_timer.quest_end_timer == mod_enum.quest_end_timer.SKIP
        and sdk.to_int64(args[3]) == e.get("app.GUIID.ID").UI020202
    then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.skip_quest_end_timer_pre(_)
    local quest_end_timer = common.get_elem_t("QuestEndTimer")
    if quest_end_timer and quest_end_timer.quest_end_timer == mod_enum.quest_end_timer.SKIP then
        local quest_dir = s.get("app.MissionManager"):get_QuestDirector()
        quest_dir:QuestReturnSkip()
    end
end

function this.hide_quest_end_input_pre(args)
    local GUI020202 = sdk.to_managed_object(args[2]) --[[@as app.GUI020202]]
    local skip_panel = GUI020202._SkipPanel
    local input = GUI020202._Input
    local quest_end_timer = common.get_elem_t("QuestEndTimer")

    if quest_end_timer and quest_end_timer.quest_end_timer == mod_enum.quest_end_timer.HIDE then
        input:setEnableCtrl(false)
        skip_panel:set_ForceInvisible(true)
    else
        input:setEnableCtrl(true)
        skip_panel:set_ForceInvisible(false)
    end
end

function this.skip_bowling_result_pre(args)
    local quest_end_timer = common.get_elem_t("QuestEndTimer")
    if quest_end_timer and quest_end_timer.quest_end_timer == mod_enum.quest_end_timer.SKIP then
        local bowlfac = s.get("app.FacilityManager"):get_Bowling()
        local bowlup = s.get("app.GameMiniEventManager"):get_Bowling()
        local reward_rank = bowlup:get_TotalScoreRank()
        local rewards = bowlfac:getRewardItems(reward_rank)

        util_game.do_something(rewards, function(_, _, value)
            ace_item.add_item(value:get_ItemId(), value.Num)
        end)

        local reult_end = sdk.to_managed_object(args[2]) --[[@as app.cBowlingUpdater.cUpdater_ResultEnd]]
        reult_end:setEndTrue()
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

return this
