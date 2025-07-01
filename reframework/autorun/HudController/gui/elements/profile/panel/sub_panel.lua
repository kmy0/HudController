local config = require("HudController.config")
local data = require("HudController.data")
local generic = require("HudController.gui.elements.profile.panel.generic")
local gui_util = require("HudController.gui.util")
local set = require("HudController.gui.set")
local state = require("HudController.gui.state")
local util_imgui = require("HudController.util.imgui")

local mod = data.mod

local this = {
    ---@type table<HudSubType, fun(elem: HudBase, elem_config: HudBaseConfig, config_key: string)>
    funcs = {},
}
local separator_material = gui_util.separator:new({
    "enabled_var0",
    "enabled_var1",
    "enabled_var2",
    "enabled_var3",
    "enabled_var4",
})
local separator_scale9 = gui_util.separator:new({
    "enabled_control_point",
    "enabled_blend",
    "enabled_ignore_alpha",
    "enabled_alpha_channel",
})
local separator_control_child = gui_util.separator:new({
    "enabled_size_x",
    "enabled_size_y",
    "enabled_color",
})

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_control_child(elem, elem_config, config_key)
    ---@cast elem CtrlChild
    ---@cast elem_config CtrlChildConfig

    local changed = false
    separator_control_child:refresh(elem_config)

    if separator_control_child:has_separators() then
        imgui.separator()
    end

    if elem_config.enabled_size_x ~= nil then
        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_size_x",
            label = gui_util.tr("hud_element.entry.box_enable_size_x"),
        }, {
            {
                config_key = config_key .. ".size_x",
                label = gui_util.tr("hud_element.entry.slider_x"),
            },
        }, -4000, 4000, 0.1, "%.1f")

        if changed then
            elem:set_size_x(elem_config.enabled_size_x and elem_config.size_x or nil)
            config.save()
        end

        separator_control_child:draw()
    end

    if elem_config.enabled_size_y ~= nil then
        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_size_y",
            label = gui_util.tr("hud_element.entry.box_enable_size_y"),
        }, {
            {
                config_key = config_key .. ".size_y",
                label = gui_util.tr("hud_element.entry.slider_y"),
            },
        }, -4000, 4000, 0.1, "%.1f")

        if changed then
            elem:set_size_y(elem_config.enabled_size_y and elem_config.size_y or nil)
            config.save()
        end

        separator_control_child:draw()
    end

    if elem_config.enabled_color ~= nil then
        local item_config_key = config_key .. ".enabled_color"
        changed = set.checkbox(gui_util.tr("hud_element.entry.box_enable_color", item_config_key), item_config_key)

        imgui.begin_disabled(not elem_config.enabled_color)

        item_config_key = config_key .. ".color"
        changed = set.color_edit("##" .. item_config_key, item_config_key) or changed

        if changed then
            elem:set_color(elem_config.enabled_color and elem_config.color or nil)
        end

        imgui.end_disabled()
        separator_control_child:draw()
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_material(elem, elem_config, config_key)
    draw_control_child(elem, elem_config, config_key)

    util_imgui.separator_text(config.lang.tr("hud_element.entry.category_animation"))
    separator_material:refresh(elem_config)

    for i = 0, 4 do
        local var_key = "var" .. i
        if elem_config["enabled_" .. var_key] ~= nil then
            local var_config = elem_config[var_key] --[[@as MaterialVarFloat]]
            local changed = generic.draw_slider_settings({
                config_key = string.format("%s.enabled_%s", config_key, var_key),
                label = gui_util.tr("hud_element.entry.box_enable_" .. var_config.name_key),
            }, {
                {
                    config_key = string.format("%s.%s.value", config_key, var_key),
                    label = "",
                },
            }, 0, 5, 0.01, "%.2f")

            if changed then
                ---@cast elem Material
                elem:set_var(elem_config["enabled_" .. var_key] and elem_config[var_key].value or nil, var_key)
                config.save()
            end

            separator_material:draw()
        end
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_scale9(elem, elem_config, config_key)
    draw_control_child(elem, elem_config, config_key)

    util_imgui.separator_text(config.lang.tr("hud_element.entry.category_texture"))

    ---@cast elem_config Scale9Config
    ---@cast elem Scale9

    separator_scale9:refresh(elem_config)
    ---@type string
    local item_config_key

    if elem_config.enabled_control_point ~= nil then
        item_config_key = config_key .. ".enabled_control_point"
        local changed = set.checkbox(
            gui_util.tr("hud_element.entry.box_enable_scale9_control_point", item_config_key),
            item_config_key
        )

        imgui.begin_disabled(not elem_config.enabled_control_point)

        item_config_key = config_key .. ".control_point"
        if not config.get(item_config_key .. "_combo") then
            config.set(
                item_config_key .. "_combo",
                state.combo.control_point:get_index(nil, config.get(item_config_key))
            )
        end

        changed = set.combo(
            "##" .. item_config_key .. "_combo",
            item_config_key .. "_combo",
            state.combo.control_point.values
        ) or changed

        if changed then
            local value = state.combo.control_point:get_value(config.get(item_config_key .. "_combo"))
            elem:set_control_point(value)
            config.set(item_config_key, value)
            config.save()
        end

        imgui.end_disabled()
        separator_scale9:draw()
    end

    if elem_config.enabled_blend ~= nil then
        item_config_key = config_key .. ".enabled_blend"
        local changed = set.checkbox(
            gui_util.tr("hud_element.entry.box_enable_scale9_blend_type", item_config_key),
            item_config_key
        )

        imgui.begin_disabled(not elem_config.enabled_blend)

        item_config_key = config_key .. ".blend"
        if not config.get(item_config_key .. "_combo") then
            config.set(item_config_key .. "_combo", state.combo.blend:get_index(nil, config.get(item_config_key)))
        end

        changed = set.combo("##" .. item_config_key .. "_combo", item_config_key .. "_combo", state.combo.blend.values)
            or changed

        if changed then
            local value = state.combo.blend:get_value(config.get(item_config_key .. "_combo"))
            elem:set_blend(value)
            config.set(item_config_key, value)
            config.save()
        end

        imgui.end_disabled()
        separator_scale9:draw()
    end

    if elem_config.enabled_alpha_channel ~= nil then
        item_config_key = config_key .. ".enabled_alpha_channel"
        local changed = set.checkbox(
            gui_util.tr("hud_element.entry.box_enable_scale9_alpha_channel", item_config_key),
            item_config_key
        )

        imgui.begin_disabled(not elem_config.enabled_alpha_channel)

        item_config_key = config_key .. ".alpha_channel"
        if not config.get(item_config_key .. "_combo") then
            config.set(
                item_config_key .. "_combo",
                state.combo.alpha_channel:get_index(nil, config.get(item_config_key))
            )
        end

        changed = set.combo(
            "##" .. item_config_key .. "_combo",
            item_config_key .. "_combo",
            state.combo.alpha_channel.values
        ) or changed

        if changed then
            local value = state.combo.alpha_channel:get_value(config.get(item_config_key .. "_combo"))
            elem:set_alpha_channel(value)
            config.set(item_config_key, value)
            config.save()
        end

        imgui.end_disabled()
        separator_scale9:draw()
    end

    if elem_config.enabled_ignore_alpha ~= nil then
        item_config_key = config_key .. ".enabled_ignore_alpha"
        local changed = set.checkbox(
            gui_util.tr("hud_element.entry.box_enable_scale9_ignore_alpha", item_config_key),
            item_config_key
        )

        imgui.begin_disabled(not elem_config.enabled_ignore_alpha)

        item_config_key = config_key .. ".ignore_alpha"
        changed = set.checkbox(
            gui_util.tr("hud_element.entry.box_scale9_ignore_alpha", item_config_key),
            item_config_key
        ) or changed

        if changed then
            elem:set_ignore_alpha(elem_config.enabled_ignore_alpha and elem_config.ignore_alpha or nil)
        end

        imgui.end_disabled()
        separator_scale9:draw()
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
function this.draw(elem, elem_config, config_key)
    local f = this.funcs[
        elem_config.hud_sub_type --[[@as HudSubType]]
    ]
    if f then
        f(elem, elem_config, config_key)
    end
end

this.funcs[mod.enum.hud_sub_type.MATERIAL] = draw_material
this.funcs[mod.enum.hud_sub_type.SCALE9] = draw_scale9

return this
