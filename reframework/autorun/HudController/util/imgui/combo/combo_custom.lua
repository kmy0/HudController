local common = require(".HudController.util.imgui.combo.common")
local filter = require("HudController.util.imgui.filter")

local this = {}

---@param label string
---@param popup_id string
---@param draw_preview fun(min: Vector2f, max: Vector2f)
---@return boolean, Vector2f, number, number
local function draw_custom_combo(label, popup_id, draw_preview)
    local width = imgui.calc_item_width()
    local clicked, pos, frame_height, draw_list, hovered =
        common.begin_combo_button("##" .. label .. "_custom_btn", width)
    local text_col, _, arrow_fits =
        common.draw_combo_background(draw_list, pos, width, frame_height, hovered)
    common.draw_combo_arrow(draw_list, pos, width, frame_height, popup_id, text_col, arrow_fits)

    local preview_min = Vector2f.new(pos.x + common.PREVIEW_PADDING, pos.y)
    local preview_max = Vector2f.new(
        pos.x + width - common.PREVIEW_PADDING - (arrow_fits and frame_height or 0),
        pos.y + frame_height
    )
    if preview_max.x > preview_min.x then
        draw_preview(preview_min, preview_max)
    end

    common.draw_combo_label(label)
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
    imgui.set_next_window_size({ width, common.get_max_popup_height() }, 1)

    local changed = false
    if imgui.begin_popup(popup_id, common.POPUP_FLAGS) then
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
---@param static_height boolean?
---@return boolean, T
function this.combo_custom_filter(label, value, draw_preview, draw_popup, static_height)
    static_height = static_height == nil or static_height
    local combo_id = label
    local popup_id = "##" .. label .. "_custom_filter_popup"
    local clicked, pos, width, frame_height = draw_custom_combo(label, popup_id, function(min, max)
        draw_preview(min, max, value)
    end)

    local draw_input = common.update_combo_filter(combo_id, popup_id, clicked, pos, width)

    imgui.set_next_window_pos({ pos.x, pos.y + frame_height }, 1)
    imgui.set_next_window_size({ width, static_height and common.get_max_popup_height() or 0 }, 1)

    local changed = false
    local popup_open = false
    if imgui.begin_popup(popup_id, common.POPUP_FLAGS) then
        popup_open = true
        ---@diagnostic disable-next-line: no-unknown
        changed, value = draw_popup(draw_input and filter.get_input() or "", value)
        imgui.end_popup()
    end

    common.reset_combo_filter(combo_id, popup_open)

    return changed, value
end

return this
