local config = require("HudController.config.init")
local data = require("HudController.data.init")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state.init")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod
local set = state.set

---@param elem QuestEndTimer
---@param elem_config QuestEndTimerConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_quest_end_timer_behavior"))
    local item_config_key = config_key .. ".quest_end_timer"
    local values = util_table.extend(
        { config.lang:tr("hud.option_disable") },
        util_table.values(mod.map.slider_quest_end_timer, function(o)
            return config.lang:tr("hud." .. o)
        end)
    )

    if
        set:slider_list(
            util_gui.tr("hud_element.entry.slider_quest_end_timer"),
            item_config_key,
            -1,
            #mod.map.slider_quest_end_timer - 1,
            values
        ) and operations.is_current_profile(elem)
    then
        elem:set_quest_end_timer(elem_config.quest_end_timer)
    end
end
