local def = require("HudController.data.option.element.sub.progress_part")
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")

---@param elem ProgressPartBase
---@param elem_config ProgressPartBaseConfig
---@param config_key string
return function(elem, elem_config, config_key)
    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }

    util_imgui.begin_disabled((elem_config.offset and elem_config.offset.enabled) or false)
    util_opt.draw_apply_elem(def.opt.offset_x, ctx)

    util_imgui.begin_disabled(not elem_config.offset_x or not elem_config.offset_x.enabled)
    util_opt.draw_apply_elem(def.opt.clock_offset_x, ctx)
    util_imgui.end_disabled()

    util_imgui.begin_disabled(not elem_config.offset_x or not elem_config.offset_x.enabled)
    util_opt.draw_apply_elem(def.opt.num_offset_x, ctx)
    util_imgui.end_disabled()

    util_imgui.end_disabled()
end
