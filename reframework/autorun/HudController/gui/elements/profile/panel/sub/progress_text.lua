local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")

local draw_progress_part = require("HudController.gui.elements.profile.panel.sub.progress_part")
local draw_text = require("HudController.gui.elements.profile.panel.sub.text")
local set = state.set

---@param elem ProgressPartText
---@param elem_config ProgressPartTextConfig
---@param config_key string
return function(elem, elem_config, config_key)
    draw_text(elem, elem_config, config_key)
    draw_progress_part(elem, elem_config, config_key)

    if elem_config.align_left ~= nil then
        if
            set:checkbox(
                util_gui.tr("hud_element.entry.box_align_left"),
                config_key .. ".align_left"
            ) and operations.is_current_profile(elem)
        then
            elem:set_align_left(elem_config.align_left)
        end
    end
end
