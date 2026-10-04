local color = require("HudController.util.imgui.color")
local config = require("HudController.config.init")
local d = require("HudController.util.imgui.disabled")
local filter = require("HudController.util.imgui.filter")
local util_misc = require("HudController.util.misc.init")

---@module "HudController.util.imgui.init"
local util_imgui = util_misc.lazy_require("HudController.util.imgui.init")

local FRAME_HEIGHT_PADDING = 6.0
local PREVIEW_PADDING = 4.0
local POPUP_INNER_SPACING = 4.0
local POPUP_ITEM_PADDING = 8.0
local MAX_POPUP_ITEMS = 8
local POPUP_FLAGS = 4 | 64
local ARROW_RADIUS_SCALE = 0.40
local ARROW_HALF_WIDTH_SCALE = 0.866
local ARROW_HALF_HEIGHT_SCALE = 0.750
local BACKGROUND_COLOR = 0xff403636
local HOVER_BACKGROUND_COLOR = 0xff4f4e4d
local TEXT_COLOR = 0xFFFFFFFF

---@param combo_id string
---@param popup_id string
---@param clicked boolean
---@param pos Vector2f
---@param width number
---@return boolean
local function update_combo_filter(combo_id, popup_id, clicked, pos, width)
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
    return draw_input
end

---@param combo_id string
---@param popup_open boolean
local function reset_combo_filter(combo_id, popup_open)
    if not popup_open and filter.is_active(combo_id) then
        filter.reset(combo_id)
    end
end

---@param text string
---@param max_width number
---@param suffix string
---@param trim_suffix boolean
---@return string
local function truncate_text(text, max_width, suffix, trim_suffix)
    while #text > 0 and imgui.calc_text_size(text .. suffix).x > max_width do
        text = text:sub(1, -2) --[[@as string]]
    end

    local preview = text .. suffix
    if trim_suffix then
        while #preview > 0 and imgui.calc_text_size(preview).x > max_width do
            preview = preview:sub(1, -2) --[[@as string]]
        end
    end
    return preview
end

---@param default_preview string
---@param width number
---@param frame_height number
---@return string, string, boolean
local function get_text_preview(default_preview, width, frame_height)
    local max_preview_width = width - frame_height - 2 * PREVIEW_PADDING
    local full_preview = default_preview
    local preview = full_preview
    local text_oversize = false

    if imgui.calc_text_size(preview).x > max_preview_width then
        text_oversize = true

        preview = truncate_text(preview, max_preview_width, "...", true)
    end

    return preview, full_preview, text_oversize
end

---@param button_id string
---@param width number
---@return boolean, Vector2f, number, ImDrawList, boolean
local function begin_combo_button(button_id, width)
    local disabled = d.is_disabled()
    local frame_height = config.lang.font_size + FRAME_HEIGHT_PADDING
    local pos = imgui.get_cursor_screen_pos()
    local draw_list = imgui.get_window_draw_list()

    d.begin_disabled(disabled)
    local clicked = imgui.invisible_button(button_id, { width, frame_height })
    d.end_disabled()

    return clicked, pos, frame_height, draw_list, imgui.is_item_hovered()
end

---@param draw_list ImDrawList
---@param pos Vector2f
---@param width number
---@param frame_height number
---@param hovered boolean
---@return integer, number, boolean
local function draw_combo_background(draw_list, pos, width, frame_height, hovered)
    local bg_col = color.with_alpha(hovered and HOVER_BACKGROUND_COLOR or BACKGROUND_COLOR)
    local text_col = color.with_alpha(TEXT_COLOR)
    draw_list:add_rect_filled(
        { pos.x, pos.y },
        { pos.x + width, pos.y + frame_height },
        bg_col,
        0,
        0
    )

    local r = config.lang.font_size * ARROW_RADIUS_SCALE
    local arrow_width = 2 * ARROW_HALF_WIDTH_SCALE * r
    local arrow_fits = width >= arrow_width + 2 * PREVIEW_PADDING
    local preview_width = width - 2 * PREVIEW_PADDING - (arrow_fits and frame_height or 0)
    return text_col, preview_width, arrow_fits
end

---@param draw_list ImDrawList
---@param pos Vector2f
---@param width number
---@param frame_height number
---@param popup_id string
---@param text_col integer
---@param arrow_fits boolean
local function draw_combo_arrow(draw_list, pos, width, frame_height, popup_id, text_col, arrow_fits)
    if not arrow_fits then
        return
    end

    if imgui.is_popup_open(popup_id) then
        draw_list:add_rect_filled(
            { pos.x + width - frame_height, pos.y },
            { pos.x + width, pos.y + frame_height },
            color.with_alpha(HOVER_BACKGROUND_COLOR),
            0,
            0
        )
    end

    local r = config.lang.font_size * ARROW_RADIUS_SCALE
    local cx = pos.x + width - frame_height * 0.5
    local cy = pos.y + frame_height * 0.5
    draw_list:add_triangle_filled(
        { cx, cy + ARROW_HALF_HEIGHT_SCALE * r },
        { cx - ARROW_HALF_WIDTH_SCALE * r, cy - ARROW_HALF_HEIGHT_SCALE * r },
        { cx + ARROW_HALF_WIDTH_SCALE * r, cy - ARROW_HALF_HEIGHT_SCALE * r },
        text_col
    )
end

---@param label string?
local function draw_combo_label(label)
    if label then
        util_imgui.set_label(label, -1)
    end
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
    local clicked, pos, frame_height, draw_list, hovered = begin_combo_button(button_id, width)
    if text_oversize and not hide_tooltip then
        util_imgui.tooltip(full_preview)
    end

    local text_col, available_text_width, arrow_fits =
        draw_combo_background(draw_list, pos, width, frame_height, hovered)
    local text_width = imgui.calc_text_size(preview).x
    local text_fits = available_text_width > 0 and text_width <= available_text_width
    if text_fits then
        local text_y = pos.y + (frame_height - config.lang.font_size) * 0.5
        draw_list:add_text({ pos.x + PREVIEW_PADDING, text_y }, text_col, preview)
    end

    draw_combo_arrow(draw_list, pos, width, frame_height, popup_id, text_col, arrow_fits)
    draw_combo_label(label)
    return clicked, pos, frame_height
end

---@param options string[]
---@param width number
---@return number
local function get_popup_width(options, width)
    local checkmark_width = config.lang.font_size
    local inner_spacing = POPUP_INNER_SPACING
    local item_padding = POPUP_ITEM_PADDING
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
    return (config.lang.font_size + FRAME_HEIGHT_PADDING) * MAX_POPUP_ITEMS
end

---@param options string[]
---@return number
local function get_combo_popup_height(options)
    if #options == 0 then
        return 1
    end

    if #options > MAX_POPUP_ITEMS then
        local item_height = config.lang.font_size + FRAME_HEIGHT_PADDING
        return item_height * MAX_POPUP_ITEMS
    end
    return 0
end

return {
    FRAME_HEIGHT_PADDING = FRAME_HEIGHT_PADDING,
    PREVIEW_PADDING = PREVIEW_PADDING,
    POPUP_FLAGS = POPUP_FLAGS,
    update_combo_filter = update_combo_filter,
    reset_combo_filter = reset_combo_filter,
    truncate_text = truncate_text,
    get_text_preview = get_text_preview,
    begin_combo_button = begin_combo_button,
    draw_combo_background = draw_combo_background,
    draw_combo_arrow = draw_combo_arrow,
    draw_combo_label = draw_combo_label,
    draw_combo = draw_combo,
    get_popup_width = get_popup_width,
    get_max_popup_height = get_max_popup_height,
    get_combo_popup_height = get_combo_popup_height,
}
