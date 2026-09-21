local config = require("HudController.config.init")
local d = require("HudController.util.imgui.disabled")
local filter = require("HudController.util.imgui.filter")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@module "HudController.util.imgui.init"
local util_imgui = util_misc.lazy_require("HudController.util.imgui.init")

local this = {}

---@param options string[]
---@param filter_value string
---@return {index: integer, value: string}[]
local function filter_options(options, filter_value)
    filter_value = filter_value:lower()
    ---@type {index: integer, value: string}[]
    local filtered = {}
    for i, value in ipairs(options) do
        if value:lower():find(filter_value, 1, true) then
            table.insert(filtered, { index = i, value = value })
        end
    end
    return filtered
end

---@param default_preview string
---@param width number
---@param frame_height number
---@return string, string, boolean
local function get_preview2(default_preview, width, frame_height)
    local max_preview_width = width - frame_height - 8
    local full_preview = default_preview
    local preview = full_preview
    local text_oversize = false

    if imgui.calc_text_size(preview).x > max_preview_width then
        text_oversize = true

        local ellipsis = "..."

        while #preview > 0 and imgui.calc_text_size(preview .. ellipsis).x > max_preview_width do
            preview = preview:sub(1, -2) --[[@as string]]
        end

        preview = preview .. ellipsis

        while #preview > 0 and imgui.calc_text_size(preview).x > max_preview_width do
            preview = preview:sub(1, -2) --[[@as string]]
        end
    end

    return preview, full_preview, text_oversize
end

---@param selected boolean[]
---@param default_preview string
---@param options string[]
---@param width number
---@param frame_height number
---@param static_preview boolean?
---@return string, string, boolean
local function get_preview(selected, default_preview, options, width, frame_height, static_preview)
    local max_preview_width = width - frame_height - 8

    ---@type string[]
    local chosen = {}
    ---@type string
    local full_preview
    if static_preview then
        full_preview = default_preview
    else
        for i, name in ipairs(options) do
            if selected[i] then
                table.insert(chosen, name)
            end
        end

        full_preview = #chosen == 0 and default_preview or table.concat(chosen, ", ")
    end

    local preview = full_preview
    local text_oversize = false

    if imgui.calc_text_size(preview).x > max_preview_width then
        text_oversize = true

        if not static_preview and #chosen > 0 then
            local found = false

            for visible_count = #chosen - 1, 1, -1 do
                local hidden_count = #chosen - visible_count
                ---@type string[]
                local visible = {}
                for i = 1, visible_count do
                    table.insert(visible, chosen[i])
                end

                local candidate = table.concat(visible, ", ") .. " +" .. hidden_count
                if imgui.calc_text_size(candidate).x <= max_preview_width then
                    preview = candidate
                    found = true
                    break
                end
            end

            if not found then
                local hidden_count = #chosen - 1
                local count_suffix = hidden_count > 0 and (" +" .. hidden_count) or ""
                local ellipsis = "..."
                local first = chosen[1]

                while
                    #first > 0
                    and imgui.calc_text_size(first .. ellipsis .. count_suffix).x
                        > max_preview_width
                do
                    first = first:sub(1, -2) --[[@as string]]
                end

                preview = first .. ellipsis .. count_suffix
                if imgui.calc_text_size(preview).x > max_preview_width then
                    preview = ellipsis .. count_suffix

                    while #preview > 0 and imgui.calc_text_size(preview).x > max_preview_width do
                        preview = preview:sub(1, -2) --[[@as string]]
                    end
                end
            end
        else
            local suffix = "..."
            while #preview > 0 and imgui.calc_text_size(preview .. suffix).x > max_preview_width do
                preview = preview:sub(1, -2) --[[@as string]]
            end

            preview = preview .. suffix
        end
    end

    return preview, full_preview, text_oversize
end

---@param label string
---@param button_id string
---@param popup_id string
---@param preview string
---@param full_preview string
---@param text_oversize boolean
---@param width number
---@param hide_tooltip boolean?
---@return boolean, Vector2f, number
local function draw_combo(
    label,
    button_id,
    popup_id,
    preview,
    full_preview,
    text_oversize,
    width,
    hide_tooltip
)
    local disabled = d.is_disabled()
    local frame_height = config.lang.font_size + 6.0
    local arrow_region_width = frame_height
    local text_padding = 4.0
    local pos = imgui.get_cursor_screen_pos()
    local draw_list = imgui.get_window_draw_list()

    d.begin_disabled(disabled)
    local clicked = imgui.invisible_button(button_id, { width, frame_height })
    d.end_disabled()

    local hovered = imgui.is_item_hovered()
    if text_oversize and not hide_tooltip then
        util_imgui.tooltip(full_preview)
    end

    local bg_col = hovered and 0xff4f4e4d or 0xff403636
    local text_col = 0xFFFFFFFF
    bg_col = disabled and util_misc.mul_alpha(bg_col, 0.6) or bg_col
    text_col = disabled and util_misc.mul_alpha(text_col, 0.6) or text_col
    draw_list:add_rect_filled(
        { pos.x, pos.y },
        { pos.x + width, pos.y + frame_height },
        bg_col,
        0,
        0
    )

    local r = config.lang.font_size * 0.40
    local arrow_width = 2 * 0.866 * r
    local arrow_fits = width >= arrow_width + 2 * text_padding

    local text_width = imgui.calc_text_size(preview).x
    local available_text_width = width - 2 * text_padding - (arrow_fits and arrow_region_width or 0)
    local text_fits = available_text_width > 0 and text_width <= available_text_width
    if text_fits then
        local text_y = pos.y + (frame_height - config.lang.font_size) * 0.5
        draw_list:add_text({ pos.x + text_padding, text_y }, text_col, preview)
    end

    if arrow_fits then
        local cx = pos.x + width - arrow_region_width * 0.5
        local cy = pos.y + frame_height * 0.5
        if imgui.is_popup_open(popup_id) then
            draw_list:add_rect_filled({
                pos.x + width - arrow_region_width,
                pos.y,
            }, {
                pos.x + width,
                pos.y + frame_height,
            }, 0xff4f4e4d, 0, 0)
        end

        draw_list:add_triangle_filled(
            { cx, cy + 0.750 * r },
            { cx - 0.866 * r, cy - 0.750 * r },
            { cx + 0.866 * r, cy - 0.750 * r },
            text_col
        )
    end

    if label then
        util_imgui.set_label(label, -1)
    end
    return clicked, pos, frame_height
end

---@param options string[]
---@param width number
---@return number
local function get_popup_width(options, width)
    local checkmark_width = config.lang.font_size
    local inner_spacing = 4.0
    local item_padding = 8.0
    local min_popup_width = width
    for _, name in ipairs(options) do
        local needed = checkmark_width + inner_spacing + imgui.calc_text_size(name).x + item_padding
        if needed > min_popup_width then
            min_popup_width = needed
        end
    end
    return min_popup_width
end

---@return number
local function get_max_popup_height()
    return (config.lang.font_size + 6.0) * 8
end

---@param options string[]
---@return number
local function get_combo_popup_height(options)
    local item_height = config.lang.font_size + 6.0
    if #options > item_height or #options == 0 then
        return item_height * 8
    end
    return 0
end

---@param label string
---@param selected boolean[]
---@param default_preview string
---@param options string[]
---@return boolean, boolean[]
function this.combo_multi(label, selected, default_preview, options)
    local width = imgui.calc_item_width()
    local popup_id = "##" .. label .. "_popup"
    local frame_height = config.lang.font_size + 6.0
    local preview, full_preview, text_oversize =
        get_preview(selected, default_preview, options, width, frame_height)
    local clicked, pos = draw_combo(
        label,
        "##" .. label .. "_btn",
        popup_id,
        preview,
        full_preview,
        text_oversize,
        width
    )

    if clicked then
        imgui.open_popup(popup_id)
    end

    imgui.set_next_window_pos({ pos.x, pos.y + frame_height }, 1)
    imgui.set_next_window_size(
        { get_popup_width(options, width), get_combo_popup_height(options) },
        1
    )

    local changed = false
    local popup_flags = 4 | 64
    if imgui.begin_popup(popup_id, popup_flags) then
        for i, name in ipairs(options) do
            if util_imgui.menu_item(name .. "##" .. i, selected[i], nil, nil) then
                selected[i] = not selected[i]
                changed = true
            end
        end
        imgui.end_popup()
    end
    return changed, selected
end

---@param label string
---@param selected boolean[]
---@param default_preview string
---@param options string[]
---@param static_preview boolean?
---@return boolean, boolean[]
function this.combo_multi_filter(label, selected, default_preview, options, static_preview)
    local width = imgui.calc_item_width()
    local combo_id = label
    local popup_id = "##" .. label .. "_filter_popup"
    local frame_height = config.lang.font_size + 6.0
    local preview, full_preview, text_oversize =
        get_preview(selected, default_preview, options, width, frame_height, static_preview)
    local clicked, pos = draw_combo(
        label,
        "##" .. label .. "_filter_btn",
        popup_id,
        preview,
        full_preview,
        text_oversize,
        width,
        filter.is_input_active(combo_id)
    )

    if clicked then
        imgui.open_popup(popup_id)
        filter.activate(combo_id)
    end

    local draw_input = false
    if filter.is_active(combo_id) and imgui.is_popup_open(popup_id) then
        draw_input = filter.update(combo_id)
    end
    if draw_input then
        filter.draw(pos, width)
    end

    imgui.set_next_window_pos({ pos.x, pos.y + frame_height }, 1)
    imgui.set_next_window_size(
        { get_popup_width(options, width), get_combo_popup_height(options) },
        1
    )

    local changed = false
    local popup_open = false
    if imgui.begin_popup(popup_id, 4 | 64) then
        popup_open = true
        if draw_input then
            local filtered = filter_options(options, filter.get_input())
            for _, entry in ipairs(filtered) do
                local i = entry.index
                if util_imgui.menu_item(entry.value .. "##" .. i, selected[i], nil, nil) then
                    selected[i] = not selected[i]
                    changed = true
                end
            end
        else
            for i, name in ipairs(options) do
                if util_imgui.menu_item(name .. "##" .. i, selected[i], nil, nil) then
                    selected[i] = not selected[i]
                    changed = true
                end
            end
        end
        imgui.end_popup()
    end

    if not popup_open and filter.is_active(combo_id) then
        filter.reset(combo_id)
    end
    return changed, selected
end

---@generic T
---@param label string
---@param bits integer
---@param default_preview string
---@param values T[]
---@param get_key fun(value: T): integer
---@param get_label fun(value: T): string
---@return boolean, integer
function this.combo_multi_bits(label, bits, default_preview, values, get_key, get_label)
    local selected_keys = util_misc.unpack_bits(bits)
    ---@type string[]
    local options = {}
    ---@type boolean[]
    local selected = {}
    ---@diagnostic disable-next-line: no-unknown
    for i, value in ipairs(values) do
        options[i] = get_label(value)
        selected[i] = util_table.contains_any(selected_keys, get_key(value))
    end

    local changed, choice = this.combo_multi(label, selected, default_preview, options)
    if not changed then
        return false, bits
    end

    local new_bits = 0
    for i, enabled in ipairs(choice) do
        if enabled then
            new_bits = new_bits | (1 << (get_key(values[i]) - 1))
        end
    end
    return true, new_bits
end

---@generic T
---@param label string
---@param bits integer
---@param default_preview string
---@param values T[]
---@param get_key fun(value: T): integer
---@param get_label fun(value: T): string
---@return boolean, integer
function this.combo_multi_bits_filter(label, bits, default_preview, values, get_key, get_label)
    bits = bits or 0
    local selected_keys = util_misc.unpack_bits(bits)
    ---@type string[]
    local options = {}
    ---@type boolean[]
    local selected = {}
    ---@diagnostic disable-next-line: no-unknown
    for i, value in ipairs(values) do
        options[i] = get_label(value)
        selected[i] = util_table.contains_any(selected_keys, get_key(value))
    end

    local changed, choice = this.combo_multi_filter(label, selected, default_preview, options)
    if not changed then
        return false, bits
    end

    local new_bits = 0
    for i, enabled in ipairs(choice) do
        if enabled then
            new_bits = new_bits | (1 << (get_key(values[i]) - 1))
        end
    end
    return true, new_bits
end

---@param label string
---@param value string
---@param values string[]
---@param draw_fn fun(value: string): string?
---@param display_format (fun(value: string): string)?
---@param width_offset number?
---@return boolean, string
function this.combo_popup(label, value, values, draw_fn, display_format, width_offset)
    local width = imgui.calc_item_width()
    local popup_id = "##" .. label .. "_popup"
    local frame_height = config.lang.font_size + 6.0
    local preview, full_preview, text_oversize =
        get_preview2(display_format and display_format(value) or value, width, frame_height)

    local clicked, pos = draw_combo(
        label,
        "##" .. label .. "_filter_btn",
        popup_id,
        preview,
        full_preview,
        text_oversize,
        width
    )

    if clicked then
        imgui.open_popup(popup_id)
    end

    imgui.set_next_window_pos({ pos.x, pos.y + frame_height }, 1)
    imgui.set_next_window_size(
        { get_popup_width(values, width) + (width_offset or 0), get_combo_popup_height(values) },
        1
    )

    local changed = false
    if imgui.begin_popup(popup_id, 4 | 64) then
        local selected = draw_fn(value)

        if selected ~= nil then
            changed = selected ~= value
            value = selected
            imgui.close_current_popup()
        end

        imgui.end_popup()
    end

    return changed, value
end

---@param label string
---@param value string
---@param values string[]
---@param draw_fn fun(query: string, value: string): string?
---@param display_format (fun(value: string): string)?
---@param width_offset number?
---@return boolean, string
function this.combo_popup_filter(label, value, values, draw_fn, display_format, width_offset)
    local width = imgui.calc_item_width()
    local combo_id = label
    local popup_id = "##" .. label .. "_filter_popup"
    local frame_height = config.lang.font_size + 6.0
    local preview, full_preview, text_oversize =
        get_preview2(display_format and display_format(value) or value, width, frame_height)

    local clicked, pos = draw_combo(
        label,
        "##" .. label .. "_filter_btn",
        popup_id,
        preview,
        full_preview,
        text_oversize,
        width,
        filter.is_input_active(combo_id)
    )

    if clicked then
        imgui.open_popup(popup_id)
        filter.activate(combo_id)
    end

    local draw_input = false
    if filter.is_active(combo_id) and imgui.is_popup_open(popup_id) then
        draw_input = filter.update(combo_id)
    end

    if draw_input then
        filter.draw(pos, width)
    end

    imgui.set_next_window_pos({ pos.x, pos.y + frame_height }, 1)
    imgui.set_next_window_size(
        { get_popup_width(values, width) + (width_offset or 0), get_combo_popup_height(values) },
        1
    )

    local changed = false
    local popup_open = false

    if imgui.begin_popup(popup_id, 4 | 64) then
        popup_open = true

        local selected = draw_fn(draw_input and filter.get_input() or "", value)

        if selected ~= nil then
            changed = selected ~= value
            value = selected
            imgui.close_current_popup()
        end

        imgui.end_popup()
    end

    if not popup_open and filter.is_active(combo_id) then
        filter.reset(combo_id)
    end

    return changed, value
end

---@param label string
---@param popup_id string
---@param draw_preview fun(min: Vector2f, max: Vector2f)
---@return boolean, Vector2f, number, number
local function draw_custom_combo(label, popup_id, draw_preview)
    local width = imgui.calc_item_width()
    local frame_height = config.lang.font_size + 6.0
    local arrow_region_width = frame_height
    local padding = 4.0
    local pos = imgui.get_cursor_screen_pos()
    local draw_list = imgui.get_window_draw_list()
    local disabled = d.is_disabled()

    d.begin_disabled(disabled)
    local clicked = imgui.invisible_button("##" .. label .. "_custom_btn", { width, frame_height })
    d.end_disabled()

    local hovered = imgui.is_item_hovered()
    local bg_col = hovered and 0xff4f4e4d or 0xff403636
    local fg_col = 0xffffffff
    bg_col = disabled and util_misc.mul_alpha(bg_col, 0.6) or bg_col
    fg_col = disabled and util_misc.mul_alpha(fg_col, 0.6) or fg_col

    draw_list:add_rect_filled(
        { pos.x, pos.y },
        { pos.x + width, pos.y + frame_height },
        bg_col,
        0,
        0
    )

    local r = config.lang.font_size * 0.40
    local arrow_width = 2 * 0.866 * r
    local arrow_fits = width >= arrow_width + 2 * padding
    local preview_max_x = pos.x + width - padding

    if arrow_fits then
        preview_max_x = preview_max_x - arrow_region_width

        if imgui.is_popup_open(popup_id) then
            draw_list:add_rect_filled(
                { pos.x + width - arrow_region_width, pos.y },
                { pos.x + width, pos.y + frame_height },
                0xff4f4e4d,
                0,
                0
            )
        end

        local cx = pos.x + width - arrow_region_width * 0.5
        local cy = pos.y + frame_height * 0.5

        draw_list:add_triangle_filled(
            { cx, cy + 0.750 * r },
            { cx - 0.866 * r, cy - 0.750 * r },
            { cx + 0.866 * r, cy - 0.750 * r },
            fg_col
        )
    end

    local preview_min = Vector2f.new(pos.x + padding, pos.y)
    local preview_max = Vector2f.new(preview_max_x, pos.y + frame_height)

    if preview_max.x > preview_min.x then
        draw_preview(preview_min, preview_max)
    end

    if label then
        util_imgui.set_label(label, -1)
    end

    return clicked, pos, width, frame_height
end

---@generic T
---@param label string
---@param value T
---@param draw_preview fun(min: Vector2f, max: Vector2f, value: T)
---@param draw_popup fun(value: T): boolean, T
---@return boolean, T
function this.combo_custom(label, value, draw_preview, draw_popup)
    local popup_id = "##" .. label .. "_custom_popup"
    local clicked, pos, width, frame_height = draw_custom_combo(label, popup_id, function(min, max)
        draw_preview(min, max, value)
    end)

    if clicked then
        imgui.open_popup(popup_id)
    end

    imgui.set_next_window_pos({ pos.x, pos.y + frame_height }, 1)
    imgui.set_next_window_size({ width, get_max_popup_height() }, 1)

    local changed = false
    if imgui.begin_popup(popup_id, 4 | 64) then
        ---@diagnostic disable-next-line: no-unknown
        changed, value = draw_popup(value)
        imgui.end_popup()
    end

    return changed, value
end

---@generic T
---@param label string
---@param value T
---@param draw_preview fun(min: Vector2f, max: Vector2f, value: T)
---@param draw_popup fun(query: string, value: T): boolean, T
---@return boolean, T
function this.combo_custom_filter(label, value, draw_preview, draw_popup)
    local combo_id = label
    local popup_id = "##" .. label .. "_custom_filter_popup"
    local clicked, pos, width, frame_height = draw_custom_combo(label, popup_id, function(min, max)
        draw_preview(min, max, value)
    end)

    if clicked then
        imgui.open_popup(popup_id)
        filter.activate(combo_id)
    end

    local draw_input = false
    if filter.is_active(combo_id) and imgui.is_popup_open(popup_id) then
        draw_input = filter.update(combo_id)
    end

    if draw_input then
        filter.draw(pos, width)
    end

    imgui.set_next_window_pos({ pos.x, pos.y + frame_height }, 1)
    imgui.set_next_window_size({ width, get_max_popup_height() }, 1)

    local changed = false
    local popup_open = false
    if imgui.begin_popup(popup_id, 4 | 64) then
        popup_open = true
        ---@diagnostic disable-next-line: no-unknown
        changed, value = draw_popup(draw_input and filter.get_input() or "", value)
        imgui.end_popup()
    end

    if not popup_open and filter.is_active(combo_id) then
        filter.reset(combo_id)
    end

    return changed, value
end

return this
