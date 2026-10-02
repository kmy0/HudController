local color = require("HudController.util.imgui.color")
local combo_custom = require("HudController.util.imgui.combo.combo_custom")
local config = require("HudController.config.init")
local data = require("HudController.data.init")
local def_mod = require("HudController.data.option.mod")
local hud = require("HudController.hud.init")
local op = require("HudController.hud.manager.op.init")
local option = require("HudController.data.option.init")
local util_imgui = require("HudController.util.imgui.init")
local util_table = require("HudController.util.misc.table")

local mod_enum = data.mod.enum

local this = {}

---@param draw_list ImDrawList
---@param center Vector2f|number[]
---@param radius number
---@param filled boolean
---@param color integer
local function draw_star(draw_list, center, radius, filled, color)
    local inner_radius = radius * 0.45

    draw_list:path_clear()

    for i = 0, 9 do
        local r = i % 2 == 0 and radius or inner_radius
        local angle = -math.pi * 0.5 + i * math.pi / 5

        draw_list:path_line_to({
            center[1] + math.cos(angle) * r,
            center[2] + math.sin(angle) * r,
        })
    end

    if filled then
        draw_list:path_fill_concave(color)
    else
        draw_list:path_stroke(color, 1, 1)
    end
end

---@param draw_list ImDrawList
---@param cx number
---@param cy number
---@param radius number
---@param color integer
local function draw_active_profile_indicator(draw_list, cx, cy, radius, color)
    draw_list:add_quad_filled(
        { cx, cy - radius },
        { cx + radius, cy },
        { cx, cy + radius },
        { cx - radius, cy },
        color
    )
end

local function draw_profile_preview(root, min, max, value, style)
    local star_radius = style.star_radius
    local active_radius = style.active_radius
    local spacing = style.spacing
    local star_color = style.star_color
    local text_color = style.text_color

    local width = max.x - min.x
    local height = max.y - min.y

    if width <= 0 or height <= 0 then
        return
    end

    local draw_list = imgui.get_window_draw_list()
    local is_active = root.current_profile == value
    local is_default = root.default_profile == value
    local name = op.hud_elem_profile.get_profile_name(value)

    draw_list:push_clip_rect(min, max, true)

    local cy = (min.y + max.y) * 0.5
    local text_y = min.y + (height - config.lang.font_size) * 0.5

    local left = min.x + 1
    local right = max.x - 1

    local star_col = color.with_alpha(star_color)

    -- active profile indicator
    if is_active then
        local cx = left + active_radius

        draw_active_profile_indicator(draw_list, cx, cy, active_radius, star_col)

        left = left + active_radius * 2 + spacing
    end

    local text_width = imgui.calc_text_size(name).x
    local min_name_width = math.min(text_width, config.lang.font_size * 2)
    local star_diameter = star_radius * 2
    local show_star = is_default and right - left >= min_name_width + spacing + star_diameter

    local star_center_x = nil
    local text_right = right

    if show_star then
        local natural_star_x = left + text_width + spacing + star_radius
        local max_star_x = right - star_radius
        star_center_x = math.min(natural_star_x, max_star_x)
        text_right = star_center_x - star_radius - spacing
    end

    local text_col = color.with_alpha(text_color)
    if text_right > left then
        draw_list:push_clip_rect({ left, min.y }, { text_right, max.y }, true)
        draw_list:add_text({ left, text_y }, text_col, name)
        draw_list:pop_clip_rect()
    end

    -- default profile indicator
    if show_star then
        draw_star(draw_list, { star_center_x, cy }, star_radius, true, star_col)
    end

    draw_list:pop_clip_rect()
end

local function draw_profile_row(root, profile_for_show, value, config_mod, style)
    local star_radius = style.star_radius
    local active_radius = style.active_radius
    local row_height = style.row_height
    local icon_size = style.icon_size
    local circle_radius = style.circle_radius
    local accent_color = style.accent_color
    local star_color = style.star_color
    local text_color = style.text_color

    local changed = false
    local draw_list = imgui.get_window_draw_list()

    local key = profile_for_show.key
    local profile = op.hud_elem_profile.get_elem_profile_no_create(root, key)

    local is_enabled = profile and profile.enabled
    if config_mod.hide_disabled_element_profiles and not is_enabled then
        return false
    end

    local is_default = root.default_profile == key
    local is_active = root.current_profile == key
    local is_selected = value == key

    local row_pos = imgui.get_cursor_screen_pos()
    local window_pos = imgui.get_window_pos()
    local window_size = imgui.get_window_size()
    local window_padding_x = row_pos.x - window_pos.x
    local row_right = window_pos.x + window_size.x - window_padding_x

    -- enabled indicator
    util_imgui.begin_disabled(profile_for_show.key == mod_enum.elem_profile.DEFAULT)
    if imgui.invisible_button("##enabled_" .. key, { icon_size, icon_size }) then
        profile = op.hud_elem_profile.get_elem_profile(root, key)
        profile.enabled = not is_enabled
        is_enabled = profile.enabled
        changed = true

        if key == root.default_profile then
            root.default_profile = mod_enum.elem_profile.DEFAULT
        end

        if is_selected then
            is_selected = false

            root.current_profile_gui = root.default_profile
        end

        op.hud_elem_profile.apply_elem_profile(root)
        hud.request_update()
    end

    local enabled_center = {
        row_pos.x + icon_size * 0.5,
        row_pos.y + row_height * 0.5,
    }
    local enabled_col = color.with_alpha(imgui.is_item_hovered() and 0xffe38a45 or accent_color)

    if is_enabled then
        draw_list:add_circle_filled(enabled_center, circle_radius, enabled_col, 12)
    else
        draw_list:add_circle(enabled_center, circle_radius, enabled_col, 12, 1)
    end
    util_imgui.end_disabled()

    imgui.same_line()

    -- default indicator
    util_imgui.begin_disabled(not is_enabled)
    if imgui.invisible_button("##default_" .. key, { icon_size, icon_size }) then
        root.default_profile = key
        is_default = true
        changed = true

        hud.request_update()
    end

    local default_center = {
        row_pos.x + icon_size + icon_size * 0.5,
        row_pos.y + row_height * 0.5,
    }
    local default_col = color.with_alpha(imgui.is_item_hovered() and 0xff45f7fa or star_color)

    draw_star(draw_list, default_center, star_radius, is_default, default_col)
    util_imgui.end_disabled()

    imgui.same_line()

    -- selector
    local name_pos = imgui.get_cursor_screen_pos()
    local name_width = row_right - name_pos.x
    util_imgui.begin_disabled(not is_enabled)
    if imgui.invisible_button("##profile_" .. key, { name_width, row_height }) then
        root.current_profile_gui = key
        is_selected = true
        changed = true

        op.hud_elem_profile.apply_elem_profile(root)
    end

    local name_max = Vector2f.new(row_right, name_pos.y + row_height)
    if imgui.is_item_hovered() then
        draw_list:add_rect_filled(
            name_pos,
            name_max,
            is_selected and 0xff684328 or 0xff4f4e4d,
            0,
            0
        )
    elseif is_selected then
        draw_list:add_rect_filled(name_pos, name_max, 0xff49301f, 0, 0)
    end

    if is_selected then
        draw_list:add_rect_filled({
            name_pos.x,
            name_pos.y + 2,
        }, {
            name_pos.x + 2,
            name_pos.y + row_height - 2,
        }, accent_color, 1, 0)
    end

    -- active profile indicator
    local text_x = name_pos.x + 7
    if is_active then
        local cx = text_x + active_radius
        local cy = name_pos.y + row_height * 0.5

        draw_active_profile_indicator(draw_list, cx, cy, active_radius, star_color)

        text_x = text_x + active_radius * 2 + 6
    end

    local text_col = color.with_alpha(text_color)
    local text_y = name_pos.y + (row_height - config.lang.font_size) * 0.5
    draw_list:add_text(
        { text_x, text_y },
        text_col,
        profile_for_show.name == "__placeholder_default"
                and config.lang:tr("hud_profile.text_default_profile")
            or profile_for_show.name
    )
    util_imgui.end_disabled()

    return changed
end

---@param elem_config HudBaseConfig
---@param config_key string
function this.draw(elem_config, config_key)
    local root = elem_config

    local style = {
        star_radius = config.lang.font_size * 0.35,
        active_radius = config.lang.font_size * 0.20,
        spacing = 6,
        row_height = config.lang.font_size + 6,
        icon_size = config.lang.font_size + 6,
        circle_radius = config.lang.font_size * 0.25,
        accent_color = 0xffd47b35,
        star_color = mod_enum.colors.info,
        text_color = 0xffffffff,
    }

    imgui.set_next_item_width(
        util_imgui.get_something_with_button_width(config.lang:tr("misc.text_ellipsis"))
    )
    if
        combo_custom.combo_custom_filter(
            "##elem_profile." .. config_key,
            elem_config.current_profile_gui,
            function(min, max, value)
                draw_profile_preview(root, min, max, value, style)
            end,
            function(query, value)
                imgui.indent(3)
                util_imgui.adjust_pos(0, 5)
                option.draw(def_mod.opt.hide_disabled_element_profiles)
                imgui.unindent(3)
                imgui.separator()

                imgui.push_style_var(11, Vector2f.new(0, 0))
                imgui.push_style_var(14, Vector2f.new(0, 0))

                local config_mod = config.current.mod
                local changed = false

                local filtered = util_table.filter_array(
                    config_mod.hud[config_mod.combo.hud].profile,
                    function(_, p)
                        local name = op.hud_elem_profile.get_profile_name(p.key)
                        return name:lower():find(query:lower(), 1, true) ~= nil
                    end
                )

                for _, profile_for_show in ipairs(filtered) do
                    if draw_profile_row(root, profile_for_show, value, config_mod, style) then
                        changed = true
                    end
                end

                imgui.pop_style_var(2)
                return changed, root.current_profile_gui
            end
        )
    then
        config:save()
    end

    imgui.same_line()
    util_imgui.option_button("##elem_profile_settings." .. config_key, {
        {
            name = config.lang:tr("hud_profile.button_import"),
            tooltip = config.lang:tr("hud_profile.tooltip_button_import"),
            callback = function()
                root = op.hud_elem_profile.import_elem_profile(root)
                local profile = op.hud_elem_profile.get_elem_profile(root, root.current_profile_gui)

                if profile.enabled then
                    op.hud_elem_profile.apply_elem_profile(root)
                end
            end,
        },
        {
            name = config.lang:tr("hud_profile.button_export"),
            tooltip = config.lang:tr("hud_profile.tooltip_button_export"),
            callback = function()
                local profile = op.hud_elem_profile.get_elem_profile(root, root.current_profile_gui)
                imgui.set_clipboard(json.dump_string(profile))
            end,
        },
    })
    util_imgui.set_label("Element Profile", -1)

    imgui.separator()

    if root.current_profile_gui ~= mod_enum.elem_profile.DEFAULT then
        config_key = string.format("%s.profile.%s", config_key, root.current_profile_gui)
        elem_config = op.hud_elem_profile.get_elem_profile(root, root.current_profile_gui)
    end

    return elem_config, config_key
end

return this
