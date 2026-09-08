local config = require("HudController.config.init")
local data = require("HudController.data.init")
local generic = require("HudController.gui.elements.profile.panel.generic")
local operations = require("HudController.hud.manager.operations")
local state = require("HudController.gui.state")
local util_game = require("HudController.util.game.init")
local util_gui = require("HudController.gui.util")
local util_imgui = require("HudController.util.imgui.init")

local mod = data.mod
local set = state.set

local this = {
    ---@type table<HudSubType, fun(elem: HudBase, elem_config: HudBaseConfig, config_key: string)>
    funcs = {},
}

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_control_child(elem, elem_config, config_key)
    ---@cast elem CtrlChild
    ---@cast elem_config CtrlChildConfig

    local changed = false
    local is_current_profile = operations.is_current_profile(elem)
    if elem_config.enabled_size_x ~= nil then
        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_size_x",
        }, {
            {
                config_key = config_key .. ".size_x",
            },
        }, 1, -1920, 1920, 1, "%.1f", config.lang:tr("hud_element.entry.box_enable_size_x"))

        if changed and is_current_profile then
            elem:set_size_x(elem_config.enabled_size_x and elem_config.size_x or nil)
        end
    end

    if elem_config.enabled_size_y ~= nil then
        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_size_y",
        }, {
            {
                config_key = config_key .. ".size_y",
            },
        }, 1, -1920, 1920, 1, "%.1f", config.lang:tr("hud_element.entry.box_enable_size_y"))

        if changed and is_current_profile then
            elem:set_size_y(elem_config.enabled_size_y and elem_config.size_y or nil)
        end
    end

    if elem_config.enabled_color ~= nil then
        local item_config_key = config_key .. ".enabled_color"
        changed = set:checkbox("##checkbox." .. item_config_key, item_config_key)

        imgui.begin_disabled(not elem_config.enabled_color)
        imgui.same_line()
        item_config_key = config_key .. ".color"
        changed = set:color_edit(
            util_gui.tr("hud_element.entry.color_color", item_config_key),
            item_config_key
        ) or changed

        if changed and is_current_profile then
            elem:set_color(elem_config.enabled_color and elem_config.color or nil)
        end

        imgui.end_disabled()
    end
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_material(elem, elem_config, config_key)
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

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_scale9(elem, elem_config, config_key)
    draw_control_child(elem, elem_config, config_key)

    util_imgui.separator_text(config.lang:tr("hud_element.entry.category_texture"))

    ---@cast elem_config Scale9Config
    ---@cast elem Scale9

    ---@type string
    local item_config_key
    local is_current_profile = operations.is_current_profile(elem)
    if elem_config.enabled_control_point ~= nil then
        item_config_key = config_key .. ".blend"
        local changed_value = generic.draw_combo(
            {
                config_key = config_key .. ".enabled_control_point",
                label = util_gui.tr(
                    "hud_element.entry.box_enable_scale9_control_point",
                    item_config_key
                ),
            },
            item_config_key,
            "##" .. item_config_key,
            state.combo.control_point,
            state.combo.control_point:get_index(nil, config:get(item_config_key))
        )

        if changed_value then
            if is_current_profile then
                elem:set_control_point(
                    elem_config.enabled_control_point and changed_value.value or nil
                )
            end

            config:set(item_config_key, changed_value.value)
        end
    end

    if elem_config.enabled_blend ~= nil then
        item_config_key = config_key .. ".blend"
        local changed_value = generic.draw_combo(
            {
                config_key = config_key .. ".enabled_blend",
                label = util_gui.tr(
                    "hud_element.entry.box_enable_scale9_blend_type",
                    item_config_key
                ),
            },
            item_config_key,
            "##" .. item_config_key,
            state.combo.blend,
            state.combo.blend:get_index(nil, config:get(item_config_key))
        )

        if changed_value then
            if is_current_profile then
                elem:set_blend(elem_config.enabled_blend and changed_value.value or nil)
            end
            config:set(item_config_key, changed_value.value)
        end
    end

    if elem_config.enabled_alpha_channel ~= nil then
        item_config_key = config_key .. ".alpha_channel"
        local changed_value = generic.draw_combo(
            {
                config_key = config_key .. ".enabled_alpha_channel",
                label = util_gui.tr(
                    "hud_element.entry.box_enable_scale9_alpha_channel",
                    item_config_key
                ),
            },
            item_config_key,
            "##" .. item_config_key,
            state.combo.alpha_channel,
            state.combo.alpha_channel:get_index(nil, config:get(item_config_key))
        )

        if changed_value then
            if is_current_profile then
                elem:set_alpha_channel(
                    elem_config.enabled_alpha_channel and changed_value.value or nil
                )
            end
            config:set(item_config_key, changed_value.value)
        end
    end

    if elem_config.enabled_ignore_alpha ~= nil then
        item_config_key = config_key .. ".enabled_ignore_alpha"
        local changed = set:checkbox(
            util_gui.tr("hud_element.entry.box_enable_scale9_ignore_alpha", item_config_key),
            item_config_key
        )

        imgui.begin_disabled(not elem_config.enabled_ignore_alpha)

        item_config_key = config_key .. ".ignore_alpha"
        changed = set:checkbox(
            util_gui.tr("hud_element.entry.box_scale9_ignore_alpha", item_config_key),
            item_config_key
        ) or changed

        if changed and is_current_profile then
            elem:set_ignore_alpha(
                elem_config.enabled_ignore_alpha and elem_config.ignore_alpha or nil
            )
        end

        imgui.end_disabled()
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
    local is_current_profile = operations.is_current_profile(elem)

    if elem_config.enabled_font_size ~= nil then
        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_font_size",
        }, {
            {
                config_key = config_key .. ".font_size",
            },
        }, 0.1, 0, 1000, 0.1, "%.1f", config.lang:tr(
            "hud_element.entry.box_enable_font_size"
        )) or changed

        if changed and is_current_profile then
            elem:set_font_size(elem_config.enabled_font_size and elem_config.font_size or nil)
        end

        imgui.end_disabled()
    end

    if elem_config.enabled_page_alignment ~= nil then
        item_config_key = config_key .. ".page_alignment"
        local changed_value = generic.draw_combo(
            {
                config_key = config_key .. ".enabled_page_alignment",
            },
            item_config_key,
            util_gui.tr("hud_element.entry.box_enable_page_alignment", item_config_key),
            state.combo.page_alignment,
            state.combo.page_alignment:get_index(nil, config:get(item_config_key))
        )

        if changed_value then
            if is_current_profile then
                elem:set_page_alignment(changed_value.value)
            end
            config:set(item_config_key, changed_value.value)
        end
    end

    if elem_config.hide_glow ~= nil then
        if
            set:checkbox(
                util_gui.tr("hud_element.entry.box_hide_glow", config_key .. ".hide_glow"),
                config_key .. ".hide_glow"
            ) and is_current_profile
        then
            elem:set_hide_glow(elem_config.hide_glow)
        end
    end

    imgui.begin_disabled(elem_config.hide_glow ~= nil and elem_config.hide_glow)

    if elem_config.enabled_glow_color ~= nil then
        item_config_key = config_key .. ".enabled_glow_color"
        changed = set:checkbox("##checkbox." .. item_config_key, item_config_key)

        imgui.begin_disabled(not elem_config.enabled_glow_color)
        imgui.same_line()
        item_config_key = config_key .. ".glow_color"
        changed = set:color_edit(util_gui.tr("hud_element.entry.color_glow"), item_config_key)
            or changed

        if changed and is_current_profile then
            elem:set_glow_color(elem_config.enabled_glow_color and elem_config.glow_color or nil)
        end

        imgui.end_disabled()
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
    local is_current_profile = operations.is_current_profile(elem)

    item_config_key = config_key .. ".enabled_box"
    if
        set:checkbox(
            util_gui.tr("hud_element.entry.box_enable_box", item_config_key),
            item_config_key
        ) and is_current_profile
    then
        elem:set_box(elem_config.enabled_box and {
            x = elem_config.box.x,
            y = elem_config.box.y,
            w = elem_config.box.w,
            h = elem_config.box.h,
        } or nil)
    end
    util_imgui.tooltip(config.lang:tr("hud_element.entry.tooltip_numbers_box"), true)

    imgui.begin_disabled(not elem_config.enabled_box)
    imgui.same_line()

    item_config_key = config_key .. ".preview_box"
    if config:get(item_config_key) == nil then
        config:set(item_config_key, false)
    end

    if imgui.button(util_gui.tr("hud_element.entry.box_preview_box", item_config_key)) then
        config:set(item_config_key, not config:get(item_config_key))
    end

    if elem_config.enabled_box and config:get(item_config_key) and is_current_profile then
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
        },
        {
            config_key = config_key .. ".box.y",
        },
    }, 1, -1920, 1920, 1, "%.0f", config.lang:tr("hud_element.entry.pos"))
    changed = generic.draw_slider_settings(nil, {
        {
            config_key = config_key .. ".box.w",
        },
        {
            config_key = config_key .. ".box.h",
        },
    }, 1, -1920, 1920, 1, "%.0f", config.lang:tr("hud_element.entry.size")) or changed

    if changed and is_current_profile then
        elem:set_box({
            x = elem_config.box.x,
            y = elem_config.box.y,
            w = elem_config.box.w,
            h = elem_config.box.h,
        })
    end

    imgui.end_disabled()
end

---@param elem HudBase
---@param elem_config HudBaseConfig
---@param config_key string
local function draw_progress_part(elem, elem_config, config_key)
    ---@cast elem ProgressPartBase
    ---@cast elem_config ProgressPartBaseConfig

    local changed = false
    local is_current_profile = operations.is_current_profile(elem)

    imgui.begin_disabled(elem_config.enabled_offset == true)

    if elem_config.enabled_offset_x ~= nil then
        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_offset_x",
        }, {
            {
                config_key = config_key .. ".offset_x",
            },
        }, 1, -1920, 1920, 1, "%.0f", config.lang:tr(
            "hud_element.entry.box_enable_offset_x"
        ))

        if changed and is_current_profile then
            elem:set_offset_x(elem_config.enabled_offset_x and elem_config.offset_x or nil)
        end
    end

    if elem_config.enabled_clock_offset_x ~= nil then
        imgui.begin_disabled(elem_config.enabled_offset_x == false)

        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_clock_offset_x",
        }, {
            {
                config_key = config_key .. ".clock_offset_x",
            },
        }, 1, -1920, 1920, 1, "%.0f", config.lang:tr(
            "hud_element.entry.box_enable_clock_offset_x"
        ))

        if changed and is_current_profile then
            elem:set_clock_offset_x(
                elem_config.enabled_clock_offset_x and elem_config.clock_offset_x or nil
            )
        end

        imgui.end_disabled()
    end

    if elem_config.enabled_num_offset_x ~= nil then
        imgui.begin_disabled(elem_config.enabled_offset_x == false)

        changed = generic.draw_slider_settings({
            config_key = config_key .. ".enabled_num_offset_x",
        }, {
            {
                config_key = config_key .. ".num_offset_x",
            },
        }, 1, -1929, 1920, 1, "%.0f", config.lang:tr(
            "hud_element.entry.box_enable_num_offset_x"
        ))

        if changed and is_current_profile then
            elem:set_num_offset_x(
                elem_config.enabled_num_offset_x and elem_config.num_offset_x or nil
            )
        end

        imgui.end_disabled()
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

    if elem_config.align_left ~= nil then
        if
            set:checkbox(
                util_gui.tr("hud_element.entry.box_align_left"),
                config_key .. ".align_left"
            ) and operations.is_current_profile(elem)
        then
            elem:set_align_left(elem_config.align_left)
        end
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
