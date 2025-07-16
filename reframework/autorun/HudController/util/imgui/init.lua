local uuid = require("HudController.util.misc.uuid")

local this = {}

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
function this.tooltip(text, seperate)
    if seperate then
        imgui.same_line()
        imgui.text("(?)")
    end
    if imgui.is_item_hovered() then
        imgui.set_tooltip(text)
    end
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
    imgui.push_style_color(21, 0)
    imgui.push_style_color(22, 0)
    imgui.push_style_color(23, 0)
    imgui.button(label, size_object)
    imgui.pop_style_color(3)
end

return this
