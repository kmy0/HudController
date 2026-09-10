local config = require("HudController.config.init")
local input = require("HudController.util.imgui.input")

local this = {}

local FILTER_BG = 0xff403636
local LABEL_BG = 0xff363433
local TEXT_COLOR = 0xFFFFFFFF

---@type string?
local active
local draw_input = false
local buf = ""
local cursor = 0

---@param id string
function this.activate(id)
    if active ~= id then
        active = id
        draw_input = false
        buf = ""
        cursor = 0
        input.clear()
    end
end

---@param id string
---@return boolean
function this.is_active(id)
    return active == id
end

---@param id string
---@return boolean
function this.is_input_active(id)
    return active == id and draw_input
end

---@param id string
---@return boolean
function this.update(id)
    if active ~= id then
        return false
    end

    buf, cursor = input.get_input()

    if not draw_input and buf ~= "" then
        draw_input = true
    end

    if
        draw_input
        and (
            imgui.is_key_pressed(imgui.ImGuiKey.Key_Escape)
            or imgui.is_key_pressed(imgui.ImGuiKey.Key_Enter)
        )
    then
        draw_input = false
        buf = ""
        cursor = 0
        input.clear()
    end

    return draw_input
end

---@param id string?
function this.reset(id)
    if id and active ~= id then
        return
    end

    active = nil
    draw_input = false
    buf = ""
    cursor = 0
    input.clear()
end

---@return string
function this.get_input()
    return buf
end

---@param pos Vector2f
---@param width number
function this.draw(pos, width)
    local search_label = string.format("%s: ", config.lang:tr("misc.text_search"))
    local draw_list = imgui.get_window_draw_list()
    local font_height = imgui.calc_text_size("A").y
    local height = config.lang.font_size + 6.0
    local padding = 4
    local caret_margin = 2
    local box_right = pos.x + width
    local box_bottom = pos.y + height
    local label_size = imgui.calc_text_size(search_label)
    local text_y = pos.y + (height - font_height) / 2
    local label_pos = Vector2f.new(pos.x + padding, text_y)
    local input_start_x = label_pos.x + label_size.x
    local input_right_x = box_right - padding - caret_margin
    local input_width = math.max(input_right_x - input_start_x, 0)
    local cursor_offset = imgui.calc_text_size(buf:sub(1, cursor)).x
    local scroll_x = math.max(cursor_offset - input_width, 0)
    local caret_x = input_start_x + cursor_offset - scroll_x

    draw_list:add_rect_filled(pos, { box_right, box_bottom }, FILTER_BG, 0, 0)
    draw_list:add_rect_filled({ pos.x, pos.y }, { input_start_x, box_bottom }, LABEL_BG, 0, 0)
    draw_list:add_text(label_pos, TEXT_COLOR, search_label)
    draw_list:push_clip_rect(
        { input_start_x, pos.y },
        { input_right_x + caret_margin, box_bottom },
        true
    )
    draw_list:add_text({ input_start_x - scroll_x, text_y }, TEXT_COLOR, buf)
    draw_list:add_line({ caret_x, pos.y + 4 }, { caret_x, box_bottom - 4 }, TEXT_COLOR, 1)
    draw_list:pop_clip_rect()
end

return this
