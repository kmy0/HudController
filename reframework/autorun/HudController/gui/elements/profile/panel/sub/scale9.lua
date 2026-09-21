local config = require("HudController.config.init")
local def = require("HudController.data.option.element.sub.scale9")
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")

local draw_control_child = require("HudController.gui.elements.profile.panel.sub.control_child")

---@param elem Scale9
---@param elem_config Scale9Config
---@param config_key string
return function(elem, elem_config, config_key)
    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }

    draw_control_child(elem, elem_config, config_key)

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_texture"))
    util_opt.draw_apply_elem(def.opt.control_point, ctx)
    util_opt.draw_apply_elem(def.opt.blend, ctx)
    util_opt.draw_apply_elem(def.opt.alpha_channel, ctx)
    util_opt.draw_apply_elem(def.opt.ignore_alpha, ctx)
end
