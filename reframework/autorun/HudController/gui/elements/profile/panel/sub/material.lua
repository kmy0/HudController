local config = require("HudController.config.init")
local def = require("HudController.data.option.element.sub.material")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")
local util_opt = require("HudController.data.option.util")

local draw_control_child = require("HudController.gui.elements.profile.panel.sub.control_child")

---@param elem Material
---@param elem_config MaterialConfig
---@param config_key string
return function(elem, elem_config, config_key)
    draw_control_child(elem, elem_config, config_key)

    local ctx = { elem = elem, elem_config = elem_config, config_key = config_key }

    for i = 0, 4 do
        local var_key = "var" .. i
        if elem_config[var_key] ~= nil then
            util_imgui.separator_text(config.lang:tr("hud_element.entry.category_animation"))
            break
        end
    end

    for i = 0, 4 do
        local var_key = "var" .. i
        local var_config = elem_config[var_key] --[[@as EnabledMaterialVarFloat?]]
        if var_config then
            local opt = def.opt[var_key]
            util_opt.draw_apply_elem(
                opt,
                ctx,
                util_gui.tr(("hud_element.entry.box_enable_" .. var_config.name_key), config_key)
            )
        end
    end
end
