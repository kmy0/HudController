---@class SharpnessIntegerDef : ElementOptionDef<Sharpness, SharpnessConfig, integer>

local config = require("HudController.config.init")
local data = require("HudController.data.init")
local set = require("HudController.gui.set")
local util_opt = require("HudController.data.option.util")
local util_table = require("HudController.util.misc.table")

local mod = data.mod
local this = {
    opt = {
        ---@type SharpnessIntegerDef
        state = {
            key = "state",
            lang_key = "hud_element.entry.state",
            bindable = true,
            draw = function(_, label, config_key)
                local values = util_table.extend(
                    { config.lang:tr("hud.option_disable") },
                    util_table.values(mod.map.slider_sharpness_state, function(o)
                        return config.lang:tr("hud_element.entry." .. o)
                    end)
                )
                return set:slider_list(
                    util_opt.get_label(label, config_key),
                    config_key,
                    -1,
                    #mod.map.slider_sharpness_state - 1,
                    values
                )
            end,
            format = function(_, value)
                if value == -1 then
                    return config.lang:tr("hud.option_disable")
                end
                local key = mod.map.slider_sharpness_state[value + 1]
                return config.lang:tr("hud_element.entry." .. key)
            end,
            apply = function(_, ctx, value)
                ctx.elem:set_state(value)
            end,
        },
    },
}

return this
