local config = require("HudController.config")
local data = require("HudController.data")
local generic = require("HudController.gui.elements.profile.panel.generic")
local gui_util = require("HudController.gui.util")
local state = require("HudController.gui.state")
local util_game = require("HudController.util.game")
local util_imgui = require("HudController.util.imgui")

local mod = data.mod
local set = state.set

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
local separator_text = gui_util.separator:new({
    "hide_glow",
    "enabled_glow_color",
    "enabled_font_size",
    "enabled_page_alignment",
})
local separator_progress_text = gui_util.separator:new({
    "align_left",
})
local separator_progress_part = gui_util.separator:new({
    "enabled_offset_x",
    "enabled_clock_offset_x",
    "enabled_num_offset_x",
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
            config.save_global()
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
            config.save_global()
        end

        separator_control_child:draw()
    end

    if elem_config.enabled_color ~= nil then
        local item_config_key = config_key .. ".enabled_color"
        changed = set:checkbox(
            gui_util.tr("hud_element.entry.box_enable_color", item_config_key),
            item_config_key
        )

        imgui.begin_disabled(not elem_config.enabled_color)
        item_config_key = config_key .. ".color"
        changed = set:color_edit("##" .. item_config_key, item_config_key) or changed

        if changed then
            elem:set_color(elem_config.enabled_color and elem_config.color or nil)
            config.save_global()
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

    for i = 0, 4 do
        local var_key = "var" .. i
        if elem_config["enabled_" .. var_key] ~= nil then
            util_imgui.separator_text(config.lang:tr("hud_element.entry.category_animation"))
            separator_material:refresh(elem_config)
            break
        end
    end

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
                elem:set_var(
                    elem_config["enabled_" .. var_key] and elem_config[var_key].value or nil,
                    var_key
                )
                config.save_global()
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

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_texture"))

    ---@cast elem_config Scale9Config
    ---@cast elem Scale9

    separator_scale9:refresh(elem_config)
    ---@type string
    local item_config_key

    if elem_config.enabled_control_point ~= nil then
        item_config_key = config_key .. ".enabled_control_point"
        local changed = set:checkbox(
            gui_util.tr("hud_element.entry.box_enable_scale9_control_point", item_config_key),
            item_config_key
        )

        imgui.begin_disabled(not elem_config.enabled_control_point)

        item_config_key = config_key .. ".control_point"
        if not config:get(item_config_key .. "_combo") then
            config:set(
                item_config_key .. "_combo",
                state.combo.control_point:get_index(nil, config:get(item_config_key))
            )
        end

        changed = set:combo(
            "##" .. item_config_key .. "_combo",
            item_config_key .. "_combo",
            state.combo.control_point.values
        ) or changed

        if changed then
            local value =
                state.combo.control_point:get_value(config:get(item_config_key .. "_combo"))
            elem:set_control_point(value)
            config:set(item_config_key, value)
            config.save_global()
        end

        imgui.end_disabled()
        separator_scale9:draw()
    end

    if elem_config.enabled_blend ~= nil then
        item_config_key = config_key .. ".enabled_blend"
        local changed = set:checkbox(
            gui_util.tr("hud_element.entry.box_enable_scale9_blend_type", item_config_key),
            item_config_key
        )

        imgui.begin_disabled(not elem_config.enabled_blend)

        item_config_key = config_key .. ".blend"
        if not config:get(item_config_key .. "_combo") then
            config:set(
                item_config_key .. "_combo",
                state.combo.blend:get_index(nil, config:get(item_config_key))
            )
        end

        changed = set:combo(
            "##" .. item_config_key .. "_combo",
            item_config_key .. "_combo",
            state.combo.blend.values
        ) or changed

        if changed then
            local value = state.combo.blend:get_value(config:get(item_config_key .. "_combo"))
            elem:set_blend(value)
            config:set(item_config_key, value)
            config.save_global()
        end

        imgui.end_disabled()
        separator_scale9:draw()
    end

    if elem_config.enabled_alpha_channel ~= nil then
        item_config_key = config_key .. ".enabled_alpha_channel"
        local changed = set:checkbox(
            gui_util.tr("hud_element.entry.box_enable_scale9_alpha_channel", item_config_key),
            item_config_key
        )

        imgui.begin_disabled(not elem_config.enabled_alpha_channel)

        item_config_key = config_key .. ".alpha_channel"
        if not config:get(item_config_key .. "_combo") then
            config:set(
                item_config_key .. "_combo",
                state.combo.alpha_channel:get_index(nil, config:get(item_config_key))
            )
        end

        changed = set:combo(
            "##" .. item_config_key .. "_combo",
            item_config_key .. "_combo",
            state.combo.alpha_channel.values
        ) or changed

        if changed then
            local value =
                state.combo.alpha_channel:get_value(config:get(item_config_key .. "_combo"))
            elem:set_alpha_channel(value)
            config:set(item_config_key, value)
            config.save_global()
        end

        imgui.end_disabled()
        separator_scale9:draw()
    end

    if elem_config.enabled_ignore_alpha ~= nil then
        item_config_key = config_key .. ".enabled_ignore_alpha"
        local changed = set:checkbox(
            gui_util.tr("hud_element.entry.box_enable_scale9_ignore_alpha", item_config_key),
            item_config_key
        )

        imgui.begin_disabled(not elem_config.enabled_ignore_alpha)

        item_config_key = config_key .. ".ignore_alpha"
        changed = set:checkbox(
            gui_util.tr("hud_element.entry.box_scale9_ignore_alpha", item_config_key),
            item_config_key
        ) or changed

        if changed then
            elem:set_ignore_alpha(
                elem_config.enabled_ignore_alpha and elem_config.ignore_alpha or nil
            )
        end

        imgui.end_disabled()
        separator_scale9:draw()
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_text(elem, elem_config, config_key)
    draw_control_child(elem, elem_config, config_key)

    ---@cast elem_config TextConfig
    ---@cast elem Text

    ---@type string
    local item_config_key
    local changed = false

    if separator_control_child:had_separators() then
        imgui.separator()
    end

    separator_text:refresh(elem_config)

    if elem_config.enabled_font_size ~= nil then
        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_font_size",
            label = gui_util.tr("hud_element.entry.box_enable_font_size", item_config_key),
        }, {
            {
                config_key = config_key .. ".font_size",
                label = "",
            },
        }, 0, 1000, 0.1, "%.1f") or changed

        if changed then
            elem:set_font_size(elem_config.enabled_font_size and elem_config.font_size or nil)
            config.save_global()
        end

        imgui.end_disabled()
        separator_text:draw()
    end

    if elem_config.enabled_page_alignment ~= nil then
        item_config_key = config_key .. ".enabled_page_alignment"
        changed = set:checkbox(
            gui_util.tr("hud_element.entry.box_enable_page_alignment", item_config_key),
            item_config_key
        )

        imgui.begin_disabled(not elem_config.enabled_page_alignment)

        item_config_key = config_key .. ".page_alignment"
        if not config:get(item_config_key .. "_combo") then
            config:set(
                item_config_key .. "_combo",
                state.combo.page_alignment:get_index(nil, config:get(item_config_key))
            )
        end

        changed = set:combo(
            "##" .. item_config_key .. "_combo",
            item_config_key .. "_combo",
            state.combo.page_alignment.values
        ) or changed

        if changed then
            local value =
                state.combo.page_alignment:get_value(config:get(item_config_key .. "_combo"))
            elem:set_page_alignment(value)
            config:set(item_config_key, value)
            config.save_global()
        end

        imgui.end_disabled()
        separator_scale9:draw()
    end

    if elem_config.hide_glow ~= nil then
        if
            set:checkbox(
                gui_util.tr("hud_element.entry.box_hide_glow", config_key .. ".hide_glow"),
                config_key .. ".hide_glow"
            )
        then
            elem:set_hide_glow(elem_config.hide_glow)
        end

        separator_text:draw()
    end

    imgui.begin_disabled(elem_config.hide_glow ~= nil and elem_config.hide_glow)

    if elem_config.enabled_glow_color ~= nil then
        item_config_key = config_key .. ".enabled_glow_color"
        changed = set:checkbox(
            gui_util.tr("hud_element.entry.box_enable_glow_color", item_config_key),
            item_config_key
        )

        imgui.begin_disabled(not elem_config.enabled_glow_color)

        item_config_key = config_key .. ".glow_color"
        changed = set:color_edit("##" .. item_config_key, item_config_key) or changed

        if changed then
            elem:set_glow_color(elem_config.enabled_glow_color and elem_config.glow_color or nil)
            config.save_global()
        end

        imgui.end_disabled()
        separator_text:draw()
    end

    imgui.end_disabled()
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_damage_numbers(elem, elem_config, config_key)
    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_numbers_behavior"))

    ---@cast elem DamageNumbersDamageState
    ---@cast elem_config DamageNumbersDamageStateConfig

    local item_config_key = config_key .. ".enabled_box"
    local changed = false

    item_config_key = config_key .. ".enabled_box"
    if
        set:checkbox(
            gui_util.tr("hud_element.entry.box_enable_box", item_config_key),
            item_config_key
        )
    then
        elem:set_box(elem_config.enabled_box and {
            x = elem_config.box.x,
            y = elem_config.box.y,
            w = elem_config.box.w,
            h = elem_config.box.h,
        } or nil)
        config.save_global()
    end
    util_imgui.tooltip(config.lang:tr("hud_element.entry.tooltip_numbers_box"), true)

    imgui.begin_disabled(not elem_config.enabled_box)
    imgui.same_line()

    item_config_key = config_key .. ".preview_box"
    if config:get(item_config_key) == nil then
        config:set(item_config_key, false)
    end

    if imgui.button(gui_util.tr("hud_element.entry.box_preview_box", item_config_key)) then
        config:set(item_config_key, not config:get(item_config_key))
    end

    if elem_config.enabled_box and config:get(item_config_key) then
        local ss = util_game.get_screen_size()
        ss.x = ss.x / 1920
        ss.y = ss.y / 1080

        draw.outline_quad(
            elem_config.box.x * ss.x,
            elem_config.box.y * ss.y,
            elem_config.box.x * ss.x,
            (elem_config.box.y + elem_config.box.h) * ss.y,
            (elem_config.box.x + elem_config.box.w) * ss.x,
            (elem_config.box.y + elem_config.box.h) * ss.y,
            (elem_config.box.x + elem_config.box.w) * ss.x,
            elem_config.box.y * ss.y,
            4294967295
        )
    end

    changed = generic.draw_slider_settings(nil, {
        {
            config_key = config_key .. ".box.x",
            label = gui_util.tr("hud_element.entry.pos_x"),
        },
        {
            config_key = config_key .. ".box.y",
            label = gui_util.tr("hud_element.entry.pos_y"),
        },
    }, -1920, 1920, 1, "%.0f")
    changed = generic.draw_slider_settings(nil, {
        {
            config_key = config_key .. ".box.w",
            label = gui_util.tr("hud_element.entry.size_x"),
        },
        {
            config_key = config_key .. ".box.h",
            label = gui_util.tr("hud_element.entry.size_y"),
        },
    }, -1920, 1920, 1, "%.0f") or changed

    if changed then
        elem:set_box({
            x = elem_config.box.x,
            y = elem_config.box.y,
            w = elem_config.box.w,
            h = elem_config.box.h,
        })
        config.save_global()
    end

    imgui.end_disabled()
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_progress_part(elem, elem_config, config_key)
    ---@cast elem ProgressPartBase
    ---@cast elem_config ProgressPartBaseConfig

    if generic.separator:had_separators() then
        imgui.separator()
    end

    separator_progress_part:refresh(elem_config)
    local changed = false

    imgui.begin_disabled(elem_config.enabled_offset == true)

    if elem_config.enabled_offset_x ~= nil then
        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_offset_x",
            label = gui_util.tr("hud_element.entry.box_enable_offset_x"),
        }, {
            {
                config_key = config_key .. ".offset_x",
                label = gui_util.tr("hud_element.entry.slider_x"),
            },
        }, -4000, 4000, 1, "%.0f")

        if changed then
            elem:set_offset_x(elem_config.enabled_offset_x and elem_config.offset_x or nil)
            config.save_global()
        end

        separator_progress_part:draw()
    end

    if elem_config.enabled_clock_offset_x ~= nil then
        imgui.begin_disabled(elem_config.enabled_offset_x == false)

        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_clock_offset_x",
            label = gui_util.tr("hud_element.entry.box_enable_clock_offset_x"),
        }, {
            {
                config_key = config_key .. ".clock_offset_x",
                label = gui_util.tr("hud_element.entry.slider_x"),
            },
        }, -4000, 4000, 1, "%.0f")

        if changed then
            elem:set_clock_offset_x(
                elem_config.enabled_clock_offset_x and elem_config.clock_offset_x or nil
            )
            config.save_global()
        end

        imgui.end_disabled()
        separator_progress_part:draw()
    end

    if elem_config.enabled_num_offset_x ~= nil then
        imgui.begin_disabled(elem_config.enabled_offset_x == false)

        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_num_offset_x",
            label = gui_util.tr("hud_element.entry.box_enable_num_offset_x"),
        }, {
            {
                config_key = config_key .. ".num_offset_x",
                label = gui_util.tr("hud_element.entry.slider_x"),
            },
        }, -4000, 4000, 1, "%.0f")

        if changed then
            elem:set_num_offset_x(
                elem_config.enabled_num_offset_x and elem_config.num_offset_x or nil
            )
            config.save_global()
        end

        imgui.end_disabled()
        separator_progress_part:draw()
    end

    imgui.end_disabled()
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_progress_text(elem, elem_config, config_key)
    draw_text(elem, elem_config, config_key)
    draw_progress_part(elem, elem_config, config_key)

    ---@cast elem ProgressPartText
    ---@cast elem_config ProgressPartTextConfig

    if
        separator_text:had_separators()
        or generic.separator:had_separators()
        or separator_progress_part:had_separators()
    then
        imgui.separator()
    end

    separator_progress_text:refresh(elem_config)

    if elem_config.align_left ~= nil then
        if
            set:checkbox(
                gui_util.tr("hud_element.entry.box_align_left"),
                config_key .. ".align_left"
            )
        then
            elem:set_align_left(elem_config.align_left)
            config.save_global()
        end

        separator_progress_text:draw()
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
this.funcs[mod.enum.hud_sub_type.TEXT] = draw_text
this.funcs[mod.enum.hud_sub_type.DAMAGE_NUMBERS] = draw_damage_numbers
this.funcs[mod.enum.hud_sub_type.CTRL_CHILD] = draw_control_child
this.funcs[mod.enum.hud_sub_type.PROGRESS_TEXT] = draw_progress_text
this.funcs[mod.enum.hud_sub_type.PROGRESS_PART] = draw_progress_part

return this
