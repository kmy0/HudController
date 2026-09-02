local config = require("HudController.config.init")
local util_game = require("HudController.util.game.init")
local util_misc = require("HudController.util.misc.init")
local uuid = require("HudController.util.misc.uuid")

local this = {}
---@type table<string, number>
local child_window_sizes = {}

---@param x number
---@param y number?
function this.adjust_pos(x, y)
    if not y then
        y = 0
    end
    local pos = imgui.get_cursor_pos()
    pos.x = pos.x + x
    pos.y = pos.y + y
    imgui.set_cursor_pos(pos)
end

---@param text string
---@param seperate boolean?
---@param seperate_text string? by_default (?)
---@param color integer?
function this.tooltip(text, seperate, seperate_text, color)
    color = color or 0xff918f8f

    if seperate then
        seperate_text = seperate_text or "(?)"
        imgui.same_line()
        imgui.text_colored(seperate_text, color)
    end
    if imgui.is_item_hovered() then
        imgui.set_tooltip(text)
    end
end

function this.tooltip_exclamation(text)
    this.tooltip(text, true, "(!)")
end

function this.tooltip_text(text)
    imgui.begin_disabled(true)
    imgui.text(string.format("( %s )", text))
    imgui.end_disabled()
end

---@param label string
---@param padding number?
---@param thickness number?
---@param color integer?
function this.separator_text(label, padding, thickness, color)
    padding = padding or 50
    thickness = thickness or 3
    color = color or 2106363020

    local label_size = imgui.calc_text_size(label)
    local pos = imgui.get_cursor_screen_pos()
    local pos_y = pos.y + label_size.y / 2
    local pos_x_start = pos.x
    local pos_x_end = pos.x + padding

    imgui.draw_list_path_line_to({ pos_x_start, pos_y })
    imgui.draw_list_path_line_to({ pos_x_end, pos_y })
    imgui.draw_list_path_stroke(color, false, thickness)

    imgui.invisible_button(uuid.generate(), { pos_x_end - pos.x, 1 })
    imgui.same_line()
    imgui.text(label)

    pos_x_start = pos_x_end + label_size.x + 15
    pos_x_end = imgui.get_window_pos().x + imgui.get_window_size().x
    imgui.draw_list_path_line_to({ pos_x_start, pos_y })
    imgui.draw_list_path_line_to({ pos_x_end, pos_y })
    imgui.draw_list_path_stroke(color, false, thickness)
end

---@param color integer
---@param offset_x integer?
---@param offset_y integer?
function this.highlight(color, offset_x, offset_y)
    if not offset_x then
        offset_x = 0
    end
    if not offset_y then
        offset_y = 0
    end
    this.adjust_pos(offset_x, offset_y)
    imgui.push_style_color(5, color)
    imgui.begin_rect()
    imgui.end_rect(0, 0)
    imgui.pop_style_color(1)
end

---@param x integer?
---@param y integer?
function this.spacer(x, y)
    x = x or 0
    y = y or 0
    imgui.push_style_var(14, Vector2f.new(x, y))
    imgui.invisible_button(uuid.generate())
    imgui.pop_style_var(1)
end

---@param label string
---@param size_object Vector2f|Vector3f|Vector4f|number[]?
function this.dummy_button(label, size_object)
    imgui.push_style_color(21, 4282400832)
    imgui.push_style_color(22, 4282400832)
    imgui.push_style_color(23, 4282400832)
    local ret = imgui.button(label, size_object)
    imgui.pop_style_color(3)
    return ret
end

---@param label string
---@param size_object Vector2f|Vector3f|Vector4f|number[]?
---@return boolean
function this.dummy_button2(label, size_object)
    imgui.push_style_color(21, 0x00000000)
    imgui.push_style_color(23, 0xff4f4e4d)
    imgui.push_style_var(11, Vector2f.new(0, 0))
    local ret = imgui.button(label, size_object)
    imgui.pop_style_color(2)
    imgui.pop_style_var(1)
    return ret
end

---@param str_id string
---@param draw_func fun()
function this.center_h(str_id, draw_func)
    if imgui.begin_table(str_id .. "_center_h_table", 3, 3 << 13) then
        imgui.table_setup_column(
            string.format("##%s_%s_%s", str_id, "center_h_table_header", 1),
            nil,
            0.01
        )
        imgui.table_setup_column(
            string.format("##%s_%s_%s", str_id, "center_h_table_header", 2),
            1 << 4
        )
        imgui.table_setup_column(
            string.format("##%s_%s_%s", str_id, "center_h_table_header", 3),
            nil,
            0.01
        )

        imgui.table_next_row()
        imgui.table_set_column_index(0)
        imgui.table_set_column_index(1)
        draw_func()
        imgui.table_set_column_index(2)
        imgui.end_table()
    end
end

---@param str_id string
---@param text string
---@param button_yes string
---@param button_no string
---@return boolean
function this.popup_yesno(str_id, text, button_yes, button_no)
    local ret = false
    if imgui.begin_popup(str_id, 1 << 27) then
        this.spacer(0, 2)
        this.center_h(str_id .. "_popupyesno1", function()
            imgui.text(text)
        end)
        this.spacer(0, 1)
        this.center_h(str_id .. "_popupyesno2", function()
            if imgui.button(string.format("%s##%s_yes", button_yes, str_id)) then
                ret = true
                imgui.close_current_popup()
            end

            imgui.same_line()

            if imgui.button(string.format("%s##%s_no", button_no, str_id)) then
                imgui.close_current_popup()
            end
        end)
        this.spacer(0, 2)
        imgui.end_popup()
    end

    return ret
end

---@param x number
---@param y number
---@param size integer
---@param color integer? by default, 0xFFFFFFFF
function this.draw_checkmark(x, y, size, color)
    local thickness = math.max(size / 5.0, 1.0)
    local third = size / 3.0
    color = color or 0xFFFFFFFF
    local bx = x - size
    local by = y + size - third * 0.5

    imgui.draw_list_path_line_to({ bx - third, by - third })
    imgui.draw_list_path_line_to({ bx, by })
    imgui.draw_list_path_line_to({ bx + third * 2, by - third * 2 })
    imgui.draw_list_path_stroke(color, false, thickness)
end

---@param label string
---@param selected_obj boolean?
---@param enabled_obj boolean?
---@param close_on_click boolean?
---@param offset_y number?
---@return boolean, boolean?
function this.menu_item(label, selected_obj, enabled_obj, close_on_click, offset_y)
    local pos_screen = imgui.get_cursor_screen_pos()
    local pos = imgui.get_cursor_pos()
    local win_size = imgui.get_window_size()
    local win_pos = imgui.get_window_pos()
    local checkmark_padding = string.rep(" ", 10)
    local padding = pos_screen.x - win_pos.x
    local disabled = enabled_obj ~= nil and enabled_obj or false
    local id = label
    local ret = selected_obj

    imgui.begin_disabled(disabled)

    label, id = table.unpack(util_misc.split_string(label, "##"))
    label = label .. checkmark_padding
    if not id then
        id = label
    end

    local text_size = imgui.calc_text_size(label)
    pos.x = pos.x - 1
    imgui.set_cursor_pos(pos)
    local button_size = { win_size.x - padding * 2, text_size.y + padding * 2 }
    local changed = this.dummy_button2("##" .. id, button_size)

    if imgui.is_item_hovered() then
        -- no idea why the position just changes sometimes? wtf is this
        offset_y = offset_y or 0
        -- there is 2px padding from somewhere, which is visible when highlight from hover is active
        -- i gave up on trying to find where its coming from
        local dl = imgui.get_window_draw_list()
        local screen_pos = imgui.get_cursor_screen_pos()
        local end_pos = {
            screen_pos.x + button_size[1] - 1,
            screen_pos.y - button_size[2] - 2 + offset_y,
        }
        dl:add_line(end_pos, { end_pos[1], end_pos[2] + button_size[2] }, 0xff4f4e4d, 3)
    end

    pos.y = pos.y + padding
    pos.x = pos.x + padding

    imgui.set_cursor_pos(pos)
    imgui.text(label)

    if selected_obj then
        this.draw_checkmark(
            pos_screen.x + win_size.x - padding,
            pos_screen.y + padding,
            text_size.y - padding,
            disabled and 0xff9d9d9d or nil
        )
    end

    if changed and type(ret) == "boolean" then
        ret = not ret
    end

    if changed and close_on_click then
        imgui.close_current_popup()
    end

    imgui.end_disabled()
    return changed, ret
end

---@param key string
---@param offset_x number?
---@param offset_y number?
function this.open_popup(key, offset_x, offset_y)
    offset_x = offset_x or 0
    offset_y = offset_y or 0

    local screen_center = util_game.get_screen_center()
    imgui.set_next_window_pos(Vector2f.new(screen_center.x - offset_x, screen_center.y - offset_y))
    imgui.open_popup(key)
end

---@param name string
---@param draw_fn fun()
---@param size_y number?
---@param spacing number?
function this.draw_child_window(name, draw_fn, size_y, spacing)
    size_y = size_y or 0
    spacing = spacing or 0

    if not child_window_sizes[name] then
        child_window_sizes[name] = size_y
    end

    imgui.begin_child_window(name, { 0, child_window_sizes[name] }, false, 1 << 3)
    local pos = imgui.get_cursor_pos()
    draw_fn()
    local size = imgui.get_cursor_pos().y - pos.y - spacing
    child_window_sizes[name] = size > 0 and size or child_window_sizes[name]
    imgui.end_child_window()
end

---@param win_state {pos_x: number, pos_y: number, size_x: number, size_y: number}
---@param min_y_size number?
function this.set_win_state(win_state, min_y_size)
    min_y_size = min_y_size or 22 --collapsed win size
    local size = imgui.get_window_size()

    if size.y <= min_y_size then
        return
    end

    local pos = imgui.get_window_pos()

    win_state.pos_x, win_state.pos_y = pos.x, pos.y
    win_state.size_x, win_state.size_y = size.x, size.y
end

---@param text string
---@param x number
---@param y number
---@param color integer
---@param outline_color integer
function this.draw_text_outlined(text, x, y, color, outline_color)
    outline_color = outline_color or 0xFF000000
    draw.text(text, x - 1, y, outline_color)
    draw.text(text, x + 1, y, outline_color)
    draw.text(text, x, y - 1, outline_color)
    draw.text(text, x, y + 1, outline_color)
    draw.text(text, x, y, color)
end

---@param button_label string
---@param ... number
---@return number
function this.get_something_with_button_width(button_label, ...)
    local other_widths = { ... }
    local FRAME_PADDING_X = 4.0
    local ITEM_SPACING_X = 8.0

    local total_width = imgui.calc_item_width()
    local button_width = imgui.calc_text_size(util_misc.split_string(button_label, "##")[1]).x
        + FRAME_PADDING_X * 2

    local ret = total_width - button_width - ITEM_SPACING_X

    for _, w in pairs(other_widths) do
        ret = ret - w - ITEM_SPACING_X
    end
    return ret <= 0 and 0 or ret
end

---@param width number
---@return number
function this.get_something_with_any_width(width)
    local FRAME_PADDING_X = 4.0
    local total_width = imgui.calc_item_width()
    local button_width = width + FRAME_PADDING_X * 2
    local ret = total_width - button_width
    return ret <= 0 and 0 or ret
end

---@param label string
---@param offset number?
function this.set_label(label, offset)
    offset = offset or 0
    imgui.same_line()
    local pos = imgui.get_cursor_pos()
    pos.x = pos.x - 3 + offset
    imgui.set_cursor_pos(pos)
    label = util_misc.split_string(label, "##")[1]
    if label ~= "" then
        imgui.text(label)
    end
end

---@return number
function this.get_drag_with()
    return config.lang.font_size * (50 / 16)
end

---@param text string
---@param width number?
---@param disabled boolean?
function this.header(text, width, disabled)
    disabled = disabled == nil and false or disabled
    local draw_list = imgui.get_window_draw_list()
    local pos = imgui.get_cursor_screen_pos()

    local height = config.lang.font_size + 6
    local padding_x = 8

    if not width then
        local window_size = imgui.get_window_size()
        local cursor = imgui.get_cursor_pos()
        width = window_size.x - cursor.x
    end

    local p1 = { pos.x, pos.y }
    local p2 = { pos.x + width, pos.y + height }

    local bg_color = 0xFF3A3A3A
    local text_color = 0xFFFFFFFF

    if disabled then
        bg_color = util_misc.mul_alpha(bg_color, 0.6)
        text_color = util_misc.mul_alpha(text_color, 0.6)
    end

    imgui.invisible_button("##header_" .. text, { width, height })
    draw_list:add_rect_filled(p1, p2, bg_color, 0, 0)

    local text_size = imgui.calc_text_size(text)
    local text_y = pos.y + (height - text_size.y) * 0.5

    draw_list:add_text({ pos.x + padding_x, text_y }, text_color, text)
end

---@param label string
---@param default_preview string
---@param options string[]
---@param selected boolean[]
---@param disabled boolean?
---@param width integer?
---@return boolean, boolean[]
function this.multi_combo(label, default_preview, options, selected, disabled, width)
    width = width or imgui.calc_item_width()

    if disabled == nil then
        disabled = false
    end

    local popup_id = "##" .. label .. "_popup"
    ---@type string[]
    local chosen = {}
    for i, name in ipairs(options) do
        if selected[i] then
            chosen[#chosen + 1] = name
        end
    end

    local frame_height = config.lang.font_size + 6.0
    local arrow_region_width = frame_height
    local text_padding = 4.0
    local max_preview_width = width - arrow_region_width - text_padding * 2
    ---@type string
    local full_preview

    if #chosen == 0 then
        full_preview = default_preview
    else
        full_preview = table.concat(chosen, ", ")
    end

    ---@type string
    local preview = full_preview
    local text_oversize = false
    if imgui.calc_text_size(preview).x > max_preview_width then
        text_oversize = true

        if #chosen > 0 then
            local found = false
            for visible_count = #chosen - 1, 1, -1 do
                local hidden_count = #chosen - visible_count
                ---@type string[]
                local visible = {}

                for i = 1, visible_count do
                    visible[#visible + 1] = chosen[i]
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

            preview = full_preview

            while #preview > 0 and imgui.calc_text_size(preview .. suffix).x > max_preview_width do
                preview = preview:sub(1, -2) --[[@as string]]
            end

            preview = preview .. suffix
        end
    end

    local pos = imgui.get_cursor_screen_pos()
    local draw_list = imgui.get_window_draw_list()

    imgui.begin_disabled(disabled)

    local clicked = false
    if imgui.invisible_button("##" .. label .. "_btn", { width, frame_height }) then
        clicked = true
    end

    imgui.end_disabled()

    local hovered = imgui.is_item_hovered()
    if text_oversize then
        this.tooltip(full_preview)
    end

    local bg_col = 0
    local text_col = 0xFFFFFFFF

    if hovered then
        bg_col = 0xff4f4e4d
    else
        bg_col = 0xff403636
    end

    bg_col = disabled and util_misc.mul_alpha(bg_col, 0.6) or bg_col
    text_col = disabled and util_misc.mul_alpha(text_col, 0.6) or text_col
    draw_list:add_rect_filled(
        { pos.x, pos.y },
        { pos.x + width, pos.y + frame_height },
        bg_col,
        0,
        0
    )

    local text_y = pos.y + (frame_height - config.lang.font_size) * 0.5
    draw_list:add_text({ pos.x + text_padding, text_y }, text_col, preview)

    local r = config.lang.font_size * 0.40
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

    if label then
        this.set_label(label, -1)
    end

    if clicked then
        imgui.open_popup(popup_id)
    end

    local checkmark_width = config.lang.font_size
    local inner_spacing = 4.0
    local item_padding = 8.0
    local min_popup_width = width

    for _, name in ipairs(options) do
        local text_w = imgui.calc_text_size(name).x
        local needed = checkmark_width + inner_spacing + text_w + item_padding

        if needed > min_popup_width then
            min_popup_width = needed
        end
    end

    local popup_pos = {
        pos.x,
        pos.y + frame_height,
    }

    imgui.set_next_window_pos(popup_pos, 1)
    imgui.set_next_window_size({ min_popup_width, 0 }, 1)

    local changed = false
    local popup_flags = 4 | 64 -- NoMove | AlwaysAutoResize
    if imgui.begin_popup(popup_id, popup_flags) then
        for i, name in ipairs(options) do
            if this.menu_item(name .. "##" .. i, selected[i], nil, nil, -2) then
                selected[i] = not selected[i]
                changed = true
            end
        end

        imgui.end_popup()
    end

    return changed, selected
end

return this
