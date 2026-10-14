local def = require("HudController.data.option.element.sub.progress_text")
local util_opt = require("HudController.data.option.util")

local draw_progress_part = require("HudController.gui.elements.profile.panel.sub.progress_part")
local draw_text = require("HudController.gui.elements.profile.panel.sub.text")

---@param elem ProgressPartText
---@param elem_config ProgressPartTextConfig
---@param config_key string
return function(elem, elem_config, config_key)
    draw_text(elem, elem_config, config_key)
    draw_progress_part(elem, elem_config, config_key)

    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }
    util_opt.draw_apply_elem(def.opt.align_left, ctx)
end
