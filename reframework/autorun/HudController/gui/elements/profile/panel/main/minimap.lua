local config = require("HudController.config.init")
local def = require("HudController.data.option.element.main.minimap")
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")

---@param elem Minimap
---@param elem_config MinimapConfig
---@param config_key string
return function(elem, elem_config, config_key)
    local ctx = { elem = elem, config_key = config_key, elem_config = elem_config }
    local classic_ctx = util_opt.resolve_elem_ctx(ctx, "children.classic_minimap") --[[@as  ElementOptionContext<ClassicMinimap, ClassicMinimapConfig>]]

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_map"))
    util_opt.draw_apply_elem(def.opt.default_filter, ctx)

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_classic_minimap"))
    util_opt.draw_apply_elem(def.opt.classic_minimap, classic_ctx)
    util_imgui.begin_disabled(
        not util_opt.get_elem_config_value(def.opt.classic_minimap, classic_ctx.elem_config)
    )
    util_opt.draw_apply_elem(def.opt.classic_minimap_fov, classic_ctx)
    util_opt.draw_apply_elem(def.opt.classic_minimap_icon_scale, classic_ctx)
    util_opt.draw_apply_elem(def.opt.classic_minimap_rot, classic_ctx)
    util_opt.draw_apply_elem(def.opt.classic_minimap_angle, classic_ctx)
    util_opt.draw_apply_elem(def.opt.hide_pl_icon_pulse, classic_ctx)
    util_imgui.end_disabled()
end
