local config = require("HudController.config.init")
local def = require("HudController.data.option.element.main.slinger_reticle")
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")

---@param elem SlingerReticle
---@param elem_config SlingerReticleConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_slinger_behavior"))
    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }
    local slinger_ctx = util_opt.resolve_elem_ctx(ctx, "children.slinger")

    util_opt.draw_apply_elem(def.opt.hide_slinger_empty, slinger_ctx)
end
