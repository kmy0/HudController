local config = require("HudController.config.init")
local def = require("HudController.data.option.element.main.stamina")
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")

---@param elem Stamina
---@param elem_config StaminaConfig
---@param config_key string
return function(elem, elem_config, config_key)
    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }
    local ex_ctx = util_opt.resolve_elem_ctx(ctx, "children.ex")

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_extra_bar_behavior"))
    util_opt.draw_apply_elem(def.opt.hide_pulse, ex_ctx)
end
