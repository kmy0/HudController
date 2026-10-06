local color = require("HudController.util.imgui.color")
local style = require("HudController.util.imgui.style")
local util_disabled = require("HudController.util.imgui.disabled")
local util_misc = require("HudController.util.misc.init")

local this = {}
---@type table<string, string>
local drag_state = {}
---@type table<string, string>
local input_state = {}

local GRAB_MIN_SIZE = 12.0
local GRAB_PADDING = 2.0

---@param str string
---@param v_min number
---@param v_max number
---@return number?, number?
local function parse_range(str, v_min, v_max)
    local a, b = str:match("^%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*$")
    a, b = tonumber(a), tonumber(b)
    if not a or not b then
        return nil, nil
    end
    a = math.max(v_min, math.min(a, v_max))
    b = math.max(v_min, math.min(b, v_max))
    a = math.min(a, b)
    b = math.max(a, b)
    return a, b
end

---@param label string
---@param v_lo number
---@param v_hi number
---@param v_min number
---@param v_max number
---@param display_format string?
---@param display_text string?
---@param step number?
---@return boolean, number, number
local function range_slider(label, v_lo, v_hi, v_min, v_max, display_format, display_text, step)
    display_format = display_format or "%.1f"
    v_min = v_min or 0.0
    v_max = v_max or 1.0

    local changed = false
    local id
    label, id = table.unpack(util_misc.split_string(label, "##"))
    id = id or label
    local disabled = util_disabled.is_disabled()

    if disabled then
        drag_state[id] = nil
        input_state[id] = nil
    end

    local text_size = imgui.calc_text_size("!")
    local font_size = text_size.y
    local frame_h = font_size + style.size.frame_padding_y * 2.0
    local avail_w = imgui.calc_item_width()

    local base_inset = GRAB_MIN_SIZE * 0.5 + GRAB_PADDING
    local rail_len_base = avail_w - base_inset * 2

    local grab_r = GRAB_MIN_SIZE * 0.5
    if step and v_max > v_min then
        local step_w = (step / (v_max - v_min)) * rail_len_base
        grab_r = math.max(grab_r, step_w * 0.5)
    end

    local cp = imgui.get_cursor_screen_pos()
    local frame_x0 = cp.x
    local frame_y0 = cp.y
    local frame_x1 = cp.x + avail_w
    local frame_y1 = cp.y + frame_h
    local rail_x0 = frame_x0 + grab_r + GRAB_PADDING
    local rail_len = avail_w - (grab_r + GRAB_PADDING) * 2

    ---@param v number
    ---@return number
    local function snap(v)
        if not step then
            return v
        end
        return math.floor(v / step + 0.5) * step
    end

    local function val_to_x(v)
        return rail_x0 + (v - v_min) / (v_max - v_min) * rail_len
    end
    local function x_to_val(x)
        local t = math.max(0.0, math.min(1.0, (x - rail_x0) / rail_len))
        return v_min + t * (v_max - v_min)
    end

    local is_hovered = false
    local is_active = false

    if not input_state[id] then
        imgui.invisible_button(id, Vector2f.new(avail_w, frame_h))
        is_hovered = imgui.is_item_hovered()
        is_active = imgui.is_item_active()
    end

    if
        not input_state[id]
        and not disabled
        and is_hovered
        and imgui.is_mouse_clicked(0)
        and (
            imgui.is_key_down(imgui.ImGuiKey.Key_LeftCtrl)
            or imgui.is_key_down(imgui.ImGuiKey.Key_RightCtrl)
        )
    then
        input_state[id] = string.format(
            "%s, %s",
            string.format(display_format, v_lo),
            string.format(display_format, v_hi)
        )
    end

    if input_state[id] then
        if imgui.is_key_down(imgui.ImGuiKey.Key_Escape) then
            input_state[id] = nil
            imgui.invisible_button(id, Vector2f.new(avail_w, frame_h))
        else
            imgui.set_cursor_screen_pos(cp)
            local confirm, new_text = imgui.input_text(
                string.format("%s##%s_input", label, id),
                input_state[id],
                64 | 4096
            )
            input_state[id] = new_text

            if confirm then
                local n_lo, n_hi = parse_range(input_state[id], v_min, v_max)
                if n_lo and n_hi then
                    n_lo, n_hi = snap(n_lo), snap(n_hi)
                    changed = v_lo ~= n_lo or v_hi ~= n_hi
                    v_lo, v_hi = n_lo, n_hi
                end
                input_state[id] = nil
            end

            return changed, v_lo, v_hi
        end
    end

    local mx = imgui.get_mouse().x

    if not is_active then
        drag_state[id] = nil
    end

    if not disabled and is_hovered and imgui.is_mouse_clicked(0) then
        local dist_lo = math.abs(mx - val_to_x(v_lo))
        local dist_hi = math.abs(mx - val_to_x(v_hi))
        if v_lo == v_hi then
            if v_lo <= v_min then
                drag_state[id] = "hi"
            elseif v_hi >= v_max then
                drag_state[id] = "lo"
            else
                drag_state[id] = mx <= val_to_x(v_lo) and "lo" or "hi"
            end
        else
            drag_state[id] = dist_lo <= dist_hi and "lo" or "hi"
        end
    end

    if not disabled and drag_state[id] then
        local new_val = snap(x_to_val(mx))
        if drag_state[id] == "lo" then
            local c = math.max(v_min, math.min(new_val, v_hi))
            if c ~= v_lo then
                v_lo = c
                changed = true
            end
        else
            local c = math.min(v_max, math.max(new_val, v_lo))
            if c ~= v_hi then
                v_hi = c
                changed = true
            end
        end
    end

    local lo_x = val_to_x(v_lo)
    local hi_x = val_to_x(v_hi)
    local dl = imgui.get_window_draw_list()

    dl:add_rect_filled(
        Vector2f.new(frame_x0, frame_y0),
        Vector2f.new(frame_x1, frame_y1),
        disabled and color.with_alpha(style.color.background_frame)
            or (
                is_active and style.color.background_frame_active
                or is_hovered and style.color.background_hover
                or style.color.background_frame
            ),
        style.size.rounding,
        0
    )

    dl:add_rect_filled(
        Vector2f.new(lo_x - grab_r, frame_y0 + GRAB_PADDING),
        Vector2f.new(lo_x + grab_r, frame_y1 - GRAB_PADDING),
        disabled and color.with_alpha(style.color.accent)
            or (drag_state[id] == "lo" and style.color.accent_active or style.color.accent),
        0,
        0
    )
    dl:add_rect_filled(
        Vector2f.new(hi_x - grab_r, frame_y0 + GRAB_PADDING),
        Vector2f.new(hi_x + grab_r, frame_y1 - GRAB_PADDING),
        disabled and color.with_alpha(style.color.accent)
            or (drag_state[id] == "hi" and style.color.accent_active or style.color.accent),
        0,
        0
    )

    local overlay = display_text
        or string.format(
            "%s  |  %s",
            string.format(display_format, v_lo),
            string.format(display_format, v_hi)
        )

    local overlay_size = imgui.calc_text_size(overlay)
    while overlay_size.x > avail_w and #overlay > 0 do
        overlay = overlay:sub(1, -2)
        overlay_size = imgui.calc_text_size(overlay)
    end

    if #overlay > 0 then
        local centered = overlay_size.x < imgui.calc_text_size(display_text or "").x
        local text_x = centered and frame_x0 or frame_x0 + (avail_w - overlay_size.x) * 0.5
        local text_y = frame_y0 + (frame_h - overlay_size.y) * 0.5
        local col = color.with_alpha(style.color.text)
        dl:add_text(Vector2f.new(text_x, text_y), col, overlay)
    end

    if label then
        dl:add_text(
            Vector2f.new(frame_x1 + font_size * 0.5, frame_y0 + (frame_h - overlay_size.y) * 0.5),
            color.with_alpha(style.color.text),
            label
        )
    end

    return changed, v_lo, v_hi
end

---@param label string
---@param v_lo integer
---@param v_hi integer
---@param v_min integer
---@param v_max integer
---@param display_format string?
---@param display_text string?
---@return boolean, integer, integer
function this.range_slider_int(label, v_lo, v_hi, v_min, v_max, display_format, display_text)
    return range_slider(label, v_lo, v_hi, v_min, v_max, display_format or "%d", display_text, 1)
end

---@param label string
---@param v_lo number
---@param v_hi number
---@param v_min number
---@param v_max number
---@param display_format string?
---@param display_text string?
---@return boolean, number, number
function this.range_slider_float(label, v_lo, v_hi, v_min, v_max, display_format, display_text)
    return range_slider(label, v_lo, v_hi, v_min, v_max, display_format or "%.2f", display_text)
end

return this
