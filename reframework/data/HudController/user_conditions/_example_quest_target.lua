local combo = require("HudController.util.imgui.combo")
local custom_condition = require("HudController.hud.bind_condition.conditions.custom")
local e = require("HudController.util.game.enum")
local game_lang = require("HudController.util.game.lang")
local gui_util = require("HudController.gui.util")
local m = require("HudController.util.ref.methods")
local util_table = require("HudController.util.misc.table")
local set = require("HudController.gui.state").set
local s = require("HudController.util.ref.singletons")

m.isBossID = m.wrap(m.get("app.EnemyDef.isBossID(app.EnemyDef.ID)"))
m.isEmValid = m.wrap(m.get("app.EnemyDef.isValid(app.EnemyDef.ID)"))
m.getEnemyNameGuid = m.wrap(m.get("app.EnemyDef.EnemyName(app.EnemyDef.ID)"))

local this = {}
this.__index = this
setmetatable(this, { __index = custom_condition })

function this:new()
    local o = custom_condition.new(self, "Quest Target")
    setmetatable(o, self)

    o.em_to_name = {}
    for _, em_id in e.iter("app.EnemyDef.ID") do
        if not m.isEmValid(em_id) or not m.isBossID(em_id) then
            goto continue
        end

        local name_guid = m.getEnemyNameGuid(em_id)
        o.em_to_name[em_id] = game_lang.get_message_local2(name_guid)

        ::continue::
    end

    o.combo_add = combo:new(o.em_to_name, {
        sort_fn = function(a, b)
            return a.value < b.value
        end,
    })
    o.combo_remove = combo:new(o.em_to_name)

    local options = o:get_additional_options_table() or {}
    local combo_remove = {}
    for _, em in pairs(options.ems or {}) do
        combo_remove[em] = o.em_to_name[em]
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

    local quest_ems = quest_data:getTargetEmId()
    local options = self:get_additional_options_table()

    for _, em in pairs(options.ems) do
        if quest_ems:Contains(em) then
            return true
        end
    end

    return false
end

function this:draw_options()
    imgui.push_item_width(gui_util.get_item_size())
    set:combo("##QuestTargetAdd", self:get_config_key_option("combo_add"), self.combo_add.values)
    imgui.pop_item_width()

    imgui.same_line()
    imgui.begin_disabled(util_table.empty(self.combo_add.values))
    if imgui.button("Add##QuestTargetAdd") then
        local options = self:get_additional_options_table()
        local key = self.combo_add:get_key(options.combo_add)
        options.combo_add = self.combo_add:disable_item(key)
        options.combo_remove = self.combo_remove:enable_item(key)

        table.insert(options.ems, key)
        self:save_config()
    end
    imgui.end_disabled()

    imgui.push_item_width(gui_util.get_item_size())
    set:combo(
        "##QuestTargetRemove",
        self:get_config_key_option("combo_remove"),
        self.combo_remove.values
    )
    imgui.pop_item_width()

    imgui.same_line()
    imgui.begin_disabled(util_table.empty(self.combo_remove.values))
    if imgui.button("Remove##QuestTargetRemove") then
        local options = self:get_additional_options_table()
        local key = self.combo_remove:get_key(options.combo_remove)
        options.combo_remove = self.combo_remove:disable_item(key)
        options.combo_add = self.combo_add:enable_item(key)

        local index = util_table.index(options.ems, key)
        table.remove(options.ems, index)
        self:save_config()
    end
    imgui.end_disabled()
end

function this:get_selected_option_string()
    local ret = self:get_display_name()
    local options = self:get_additional_options_table()

    if not util_table.empty(options.ems) then
        local names = {}
        for _, em in ipairs(options.ems) do
            table.insert(names, self.em_to_name[em])
        end

        ret = string.format("%s - %s", ret, table.concat(names, ", "))
    end

    return ret
end

function this:new_additional_options()
    return { combo_add = 1, combo_remove = 1, ems = {} }
end

return this
