---@class NameAccessNumberDef : ElementOptionDef<NameAccess, NameAccessConfig, number>

local config = require("HudController.config.init")
local set = require("HudController.gui.set")
local util_opt = require("HudController.data.option.util")

local this = {
    opt = {
        ---@type NameAccessNumberDef
        npc_draw_distance = {
            key = "npc_draw_distance",
            lang_key = "hud_element.entry.slider_npc_draw_distance",
            bindable = true,
            format = util_opt.format_disabled_number,
            draw = function(self, label, config_key)
                local value = config:get(config_key)
                return set:slider_float(
                    util_opt.get_label(label, config_key),
                    config_key,
                    0,
                    50,
                    self:format(value)
                )
            end,
            apply = function(_, ctx, value)
                ctx.elem:set_npc_draw_distance(value)
            end,
        },
    },
}

return this
