local config = require("HudController.config.init")
local op = require("HudController.hud.manager.op.init")
local set = require("HudController.gui.set")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")

---@param elem SlingerReticle
---@param elem_config SlingerReticleConfig
---@param config_key string
return function(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_slinger_behavior"))
    local item_config_key = config_key .. ".children.slinger.hide_slinger_empty"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_hide_slinger_empty", item_config_key),
            item_config_key
        ) and op.hud_elem.is_current_profile(elem)
    then
        elem.children.slinger:set_hide_slinger_empty(
            elem_config.children.slinger.hide_slinger_empty
        )
    end
end
