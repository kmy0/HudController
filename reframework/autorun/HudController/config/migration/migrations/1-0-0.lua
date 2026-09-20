---@diagnostic disable: undefined-field, no-unknown, inject-field

local migration_base = require("HudController.util.misc.migration_base")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")
local mod_enum = require("HudController.data.mod").enum

---@module "HudController.hud.factory"
local factory = util_misc.lazy_require("HudController.hud.factory")
---@module "HudController.hud.elements.subtitles"
local subtitles = util_misc.lazy_require("HudController.hud.elements.subtitles")
---@module "HudController.hud.elements.quest_end_timer"
local quest_end_timer = util_misc.lazy_require("HudController.hud.elements.quest_end_timer")

local this = migration_base.new("1.0.0")

---@param t table<string, boolean>
---@return table<string, integer>
local function bool_table_to_ordered(t)
    local ret = {}
    local keys = util_table.keys(util_table.filter(t, function(_, value)
        return value
    end))
    table.sort(keys)
    for i, key in ipairs(keys) do
        ret[key] = i
    end

    return ret
end

---@param config MainSettings
function this.fns.notice(config)
    for _, profile in pairs(config.mod.hud) do
        for key, elem in pairs(profile.elements or {}) do
            if key == "NOTICE" then
                for _, entry in pairs({
                    "system_log",
                    "lobby_log",
                    "chat_log",
                    "enemy_log",
                    "camp_log",
                    "auto_id",
                }) do
                    elem[entry] = bool_table_to_ordered(elem[entry])
                end
            end
        end
    end
end

---@param config MainSettings
function this.fns.name_access(config)
    for _, profile in pairs(config.mod.hud) do
        for key, elem in pairs(profile.elements or {}) do
            if key == "NAME_ACCESSIBLE" then
                for _, entry in pairs({
                    "object_category",
                    "gossip_type",
                    "npc_type",
                    "panel_type",
                    "enemy_type",
                }) do
                    elem[entry] = bool_table_to_ordered(elem[entry])
                end
            end
        end
    end
end

---@param config MainSettings
function this.fns.name_other(config)
    for _, profile in pairs(config.mod.hud) do
        for key, elem in pairs(profile.elements or {}) do
            if key == "NAME_OTHER" then
                for _, entry in pairs({
                    "nameplate_type",
                }) do
                    elem[entry] = bool_table_to_ordered(elem[entry])
                end
            end
        end
    end
end

---@param config MainSettings
function this.fns.subtitles(config)
    for _, profile in pairs(config.mod.hud) do
        if profile.hide_subtitles or profile.mute_gossip then
            local elem = factory.merge(profile.elements.SUBTITLES or subtitles.get_config()) --[[@as SubtitlesConfig]]

            if profile.hide_subtitles then
                elem.hide_dialogue_type = {
                    GOSSIP = 1,
                    NAGARA = 2,
                }
            end

            if profile.mute_gossip then
                elem.mute_dialogue_type = {
                    GOSSIP = 1,
                    NAGARA = 2,
                }
            end

            profile.elements.SUBTITLES = elem
        end
    end
end

---@param config MainSettings
function this.fns.binds(config)
    for _, b in pairs(config.mod.bind.key.hud) do
        b.bound_value = { key = b.bound_value, value = 0 }
        b.trigger_repeat = false
    end

    for _, t in pairs({ config.mod.bind.key.option_hud, config.mod.bind.key.option_mod }) do
        for _, b in pairs(t) do
            b.bound_value = { key = b.bound_value, value = 0 }
            if b.action_type == "ENABLE" or b.action_type == "TOGGLE" then
                b.bound_value.value = 1
                b.action_type = "SET"
            elseif b.action_type == "TOGGLE_HOLD" then
                b.bound_value.value = 1
                b.action_type = "SET_HOLD"
            elseif b.action_type == "DISABLE" then
                b.action_type = "SET"
            end
            b.trigger_repeat = false
        end
    end
end

---@param config MainSettings
function this.fns.conditions(config)
    for _, b in pairs(config.mod.bind.condition.hud) do
        b.key = b.hud_key
        b.combo_profile = b.combo_hud
        b.expected_result = 1
    end
end

---@param config MainSettings
function this.fns.quest_end_timer(config)
    for _, profile in pairs(config.mod.hud) do
        if profile.skip_quest_end_timer or profile.hide_quest_end_timer then
            local elem =
                factory.merge(profile.elements.QUEST_END_TIMER or quest_end_timer.get_config()) --[[@as QuestEndTimerConfig]]

            if profile.skip_quest_end_timer then
                elem.quest_end_timer = mod_enum.quest_end_timer.SKIP
            elseif profile.hide_quest_end_timer then
                elem.quest_end_timer = mod_enum.quest_end_timer.HIDE
            end

            profile.elements.QUEST_END_TIMER = elem
        end
    end
end

return this
