local config = require("HudController.config.init")
local draw_control_child = require("HudController.gui.elements.profile.panel.sub.control_child")
local generic = require("HudController.gui.elements.profile.panel.generic")
local operations = require("HudController.hud.manager.operations")
local util_imgui = require("HudController.util.imgui.init")

---@param elem Material
---@param elem_config MaterialConfig
---@param config_key string
return function(elem, elem_config, config_key)
    draw_control_child(elem, elem_config, config_key)

    local is_current_profile = operations.is_current_profile(elem)
    for i = 0, 4 do
        local var_key = "var" .. i
        if elem_config["enabled_" .. var_key] ~= nil then
            util_imgui.separator_text(config.lang:tr("hud_element.entry.category_animation"))
            break
        end
    end

    for i = 0, 4 do
        local var_key = "var" .. i
        if elem_config["enabled_" .. var_key] ~= nil then
            local var_config = elem_config[var_key] --[[@as MaterialVarFloat]]
            local changed = generic.draw_slider_settings(
                {
                    config_key = string.format("%s.enabled_%s", config_key, var_key),
                },
                {
                    {
                        config_key = string.format("%s.%s.value", config_key, var_key),
                    },
                },
                0.01,
                0,
                5,
                0.01,
                "%.2f",
                config.lang:tr("hud_element.entry.box_enable_" .. var_config.name_key)
            )

            if changed and is_current_profile then
                ---@cast elem Material
                elem:set_var(
                    elem_config["enabled_" .. var_key] and elem_config[var_key].value or nil,
                    var_key
                )
            end
        end
    end
end
