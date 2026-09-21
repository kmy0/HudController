local config = require("HudController.config.init")
local def = require("HudController.data.option.element.main.clock")
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")

---@param elem Clock
---@param elem_config ClockConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_clock_behavior"))

    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }
    util_opt.draw_apply_elem(def.opt.hide_map_visible, ctx)
end
