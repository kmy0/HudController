local config = require("HudController.config.init")
local input = require("HudController.util.imgui.input")
local util_table = require("HudController.util.misc.table")

local this = {}

local FILTER_BG = 0xff403636
local LABEL_BG = 0xff363433
local TEXT_COLOR = 0xFFFFFFFF

---@type string?
local active_combo
local draw_input = false
local filtered_index = 1
local ignore_release = false

local function reset_state()
    active_combo = nil
    draw_input = false
    filtered_index = 1
    ignore_release = false
    input.clear()
end

---@param name string
---@param selection integer
---@param combo Combo
---@return boolean, integer
function this.combo_filter(name, selection, combo)
    local combo_id = name
    local left_released = imgui.is_mouse_released(0)
    local released = imgui.is_mouse_released(1)

    if left_released and combo_id == active_combo and ignore_release and not draw_input then
        ignore_release = false
        left_released = false
    end

    if not released and combo_id == active_combo and not draw_input and input.get_input() ~= "" then
        draw_input = true
    end

    if
        imgui.is_key_pressed(imgui.ImGuiKey.Key_Escape)
        or imgui.is_key_pressed(imgui.ImGuiKey.Key_Enter)
    then
        draw_input = false
        input.clear()
    end

    local changed = false
    if draw_input and active_combo == combo_id then
        local width = imgui.calc_item_width()
        local pos = imgui.get_cursor_screen_pos()
        local search_label = string.format("%s: ", config.lang:tr("misc.text_search"))
        local buf, cursor = input.get_input()

        local filtered = combo:filter_by_value(buf)
        local values = util_table.values_ordered(filtered, function(entry)
            return entry.value
        end)

        ---@diagnostic disable-next-line: cast-local-type
        changed, filtered_index = imgui.combo(name, filtered_index, values)

        if changed then
            selection = combo:get_index(filtered[filtered_index].key) --[[@as integer]]
            released = true
        elseif left_released and active_combo == combo_id then
            if ignore_release then
                ignore_release = false
            else
                released = true
            end
        end

        local draw_list = imgui.get_window_draw_list()
        local font_height = imgui.calc_text_size("A").y
        local height = font_height + 8
        local padding = 4
        local caret_margin = 2
        local box_right = pos.x + width
        local box_bottom = pos.y + height
        local label_size = imgui.calc_text_size(search_label)
        local text_y = pos.y + (height - font_height) / 2 - 2
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
        draw_list:add_line({ caret_x, pos.y + 4 }, { caret_x, box_bottom - 6 }, TEXT_COLOR, 1)
        draw_list:pop_clip_rect()
    else
        ---@diagnostic disable-next-line: cast-local-type
        changed, selection = imgui.combo(name, selection, combo.values)
    end

    if released then
        reset_state()
    elseif not active_combo and imgui.is_item_active() then
        active_combo = combo_id
        ignore_release = true
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return changed, selection
end

return this
