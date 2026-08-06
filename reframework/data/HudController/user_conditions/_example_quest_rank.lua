local combo = require("HudController.util.imgui.combo")
local custom_condition = require("HudController.hud.bind_condition.conditions.custom")
local e = require("HudController.util.game.enum")
local gui_util = require("HudController.gui.util")
local util_table = require("HudController.util.misc.table")
local set = require("HudController.gui.state").set
local s = require("HudController.util.ref.singletons")

local this = {}
this.__index = this
setmetatable(this, { __index = custom_condition })

function this:new()
    local o = custom_condition.new(self, "Quest Rank")
    setmetatable(o, self)

    o.rank_to_name = {}
    for _, rank in e.iter("app.QuestDef.EM_REWARD_RANK") do
        o.rank_to_name[rank] = rank .. "★"
    end

    o.combo_add = combo:new(o.rank_to_name, {
        sort_fn = function(a, b)
            return a.key < b.key
        end,
    })
    o.combo_remove = combo:new(o.rank_to_name)

    local options = o:get_additional_options_table() or {}
    local combo_remove = {}
    for _, rank in pairs(options.ranks or {}) do
        combo_remove[rank] = o.rank_to_name[rank]
    end

    o.combo_add:disable_items(util_table.keys(combo_remove))
    o.combo_remove:disable_all_items()
    o.combo_remove:enable_items(util_table.keys(combo_remove))

    return o
end

function this:update()
    local quest_data = s.get("app.MissionManager"):get_ActiveQuestData()
    if not quest_data then
        return false
    end

    local options = self:get_additional_options_table()
    local quest_rank = quest_data:getTargetEmDifficulityRank()

    for _, rank in pairs(options.ranks) do
        if quest_rank:Contains(rank) then
            return true
        end
    end

    return false
end

function this:draw_options()
    imgui.push_item_width(gui_util.get_item_size())
    set:combo("##QuestRankAdd", self:get_config_key_option("combo_add"), self.combo_add.values)
    imgui.pop_item_width()

    imgui.same_line()
    imgui.begin_disabled(util_table.empty(self.combo_add.values))
    if imgui.button("Add##QuestRankAdd") then
        local options = self:get_additional_options_table()
        local key = self.combo_add:get_key(options.combo_add)
        options.combo_add = self.combo_add:disable_item(key)
        options.combo_remove = self.combo_remove:enable_item(key)

        table.insert(options.ranks, key)
        self:save_config()
    end
    imgui.end_disabled()

    imgui.push_item_width(gui_util.get_item_size())
    set:combo(
        "##QuestRankRemove",
        self:get_config_key_option("combo_remove"),
        self.combo_remove.values
    )
    imgui.pop_item_width()

    imgui.same_line()
    imgui.begin_disabled(util_table.empty(self.combo_remove.values))
    if imgui.button("Remove##QuestRankRemove") then
        local options = self:get_additional_options_table()
        local key = self.combo_remove:get_key(options.combo_remove)
        options.combo_remove = self.combo_remove:disable_item(key)
        options.combo_add = self.combo_add:enable_item(key)

        local index = util_table.index(options.ranks, key)
        table.remove(options.ranks, index)
        self:save_config()
    end
    imgui.end_disabled()
end

function this:get_selected_option_string()
    local ret = self:get_display_name()
    local options = self:get_additional_options_table()

    if not util_table.empty(options.ranks) then
        local names = {}
        for _, rank in ipairs(options.ranks) do
            table.insert(names, self.rank_to_name[rank])
        end

        ret = string.format("%s - %s", ret, table.concat(names, ", "))
    end

    return ret
end

function this:new_additional_options()
    return { combo_add = 1, combo_remove = 1, ranks = {} }
end

return this
