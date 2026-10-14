local def = require("HudController.data.option.element.sub.text")
local util_opt = require("HudController.data.option.util")

local draw_control_child = require("HudController.gui.elements.profile.panel.sub.control_child")

---@param elem Text
---@param elem_config TextConfig
---@param config_key string
return function(elem, elem_config, config_key)
    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }

    draw_control_child(elem, elem_config, config_key)

    util_opt.draw_apply_elem(def.opt.font_size, ctx)
    util_opt.draw_apply_elem(def.opt.page_alignment, ctx)
    util_opt.draw_apply_elem(def.opt.hide_glow, ctx)
    util_opt.draw_apply_elem(def.opt.glow_color, ctx)
end
