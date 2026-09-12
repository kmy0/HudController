local config = require("HudController.config.init")
local data = require("HudController.data.init")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod
local set = state.set

---@param elem Sharpness
---@param elem_config SharpnessConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_state_behavior"))
    local item_config_key = config_key .. ".state"
    local values = util_table.extend(
        { config.lang:tr("hud.option_disable") },
        util_table.values(mod.map.slider_sharpness_state, function(o)
            return config.lang:tr("hud_element.entry." .. o)
        end)
    )

    if
        set:slider_list(
            util_gui.tr("hud_element.entry.state"),
            item_config_key,
            -1,
            #mod.map.slider_sharpness_state - 1,
            values
        ) and operations.is_current_profile(elem)
    then
        elem:set_state(elem_config.state)
    end
end
