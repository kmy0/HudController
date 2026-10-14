local def = require("HudController.data.option.element.sub.control_child")
local util_opt = require("HudController.data.option.util")

---@param elem CtrlChild
---@param elem_config CtrlChildConfig
---@param config_key string
return function(elem, elem_config, config_key)
    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }

    util_opt.draw_apply_elem(def.opt.size_x, ctx)
    util_opt.draw_apply_elem(def.opt.size_y, ctx)
    util_opt.draw_apply_elem(def.opt.color, ctx)
end
