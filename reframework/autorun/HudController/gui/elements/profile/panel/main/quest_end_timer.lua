local config = require("HudController.config.init")
local def = require("HudController.data.option.element.main.quest_end_timer")
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")

---@param elem QuestEndTimer
---@param elem_config QuestEndTimerConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_quest_end_timer_behavior"))
    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }
    util_opt.draw_apply_elem(def.opt.quest_end_timer, ctx)
end
