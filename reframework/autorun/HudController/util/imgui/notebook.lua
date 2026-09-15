---@class NotebookTab
---@field label string
---@field key any
---@field border_color integer?
---@field text_color integer?

---@class NotebookActionButton
---@field label string
---@field tooltip string?
---@field size_strings string[]? Strings used to calculate a shared minimum button width
---@field get_enabled (fun(tab: any): boolean)?
---@field action fun(tab: any): any
---@field background_color integer?
---@field hover_color integer?
---@field border_color integer?

---@class NotebookState
---@field hover {[string]: boolean}
---@field scroll_x number
---@field last_tab any

---@class NotebookColors
---@field active integer?
---@field active_border integer?
---@field inactive integer?
---@field hover integer?
---@field inactive_border integer?
---@field action integer?
---@field action_border integer?
---@field text integer?
---@field separator integer?

local config = require("HudController.config.init")
local disabled = require("HudController.util.imgui.disabled")
local util_imgui = require("HudController.util.imgui.init")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

local this = {
    ---@type {[string]: NotebookState}
    _state = {},
}

local PAD, GAP, ACTION_GAP = 12, 2, 8
local SCROLLBAR_W = 18
local INSET, MAX_W, DISABLED = 3, 160, 0.6

local DEFAULT_COLORS = {
    active = 0xff1c1b1a,
    active_border = 0xff9a6136,

    inactive = 0xff1c1b1a,
    hover = 0xff4f4e4d,
    inactive_border = 0xff9a6136,

    action = 0xff363433,
    action_border = 0xff4f4e4d,

    text = 0xffffffff,
    separator = 0xff9a6136,
}

---@param id string
---@return NotebookState
local function get_state(id)
    local s = this._state[id]

    if not s then
        s = {
            hover = {},
            scroll_x = 0,
            last_tab = nil,
        }

        this._state[id] = s
    end

    return s
end

---@param text string
---@return string, number
local function label(text)
    local fitted = util_imgui.fit_text(text, MAX_W)
    return fitted, imgui.calc_text_size(fitted).x
end

---@param btn NotebookActionButton
---@param tab any
---@return boolean
local function enabled(btn, tab)
    if btn.get_enabled then
        return btn.get_enabled(tab)
    end

    return true
end

---@param list any
---@param x number
---@param y number
---@param w number
---@param h number
---@param bg integer
---@param color integer
---@param vertical boolean
local function border(list, x, y, w, h, bg, color, vertical)
    if vertical then
        list:add_rect_filled({ x + INSET, y }, { x + w - 1, y + h }, bg, 0, 0)
        list:add_line({ x + INSET, y }, { x + w - 1, y }, color, 1)
        list:add_line({ x + INSET, y + h }, { x + w - 1, y + h }, color, 1)
        list:add_line({ x + INSET, y }, { x + INSET, y + h }, color, 1)
        return
    end

    list:add_rect_filled({ x, y + INSET }, { x + w, y + h - 1 }, bg, 0, 0)
    list:add_line({ x, y + INSET }, { x, y + h - 1 }, color, 1)
    list:add_line({ x + w, y + INSET }, { x + w, y + h - 1 }, color, 1)
    list:add_line({ x, y + INSET }, { x + w, y + INSET }, color, 1)
end

---@param list ImDrawList
---@param x number
---@param y number
---@param w number
---@param h number
---@param text string
---@param active boolean
---@param action boolean
---@param ok boolean
---@param hovered boolean
---@param border_color integer?
---@param text_color integer?
---@param background_color integer?
---@param hover_color integer?
---@param colors NotebookColors
---@param is_disabled boolean
---@param vertical boolean
local function tab(
    list,
    x,
    y,
    w,
    h,
    text,
    active,
    action,
    ok,
    hovered,
    border_color,
    text_color,
    background_color,
    hover_color,
    colors,
    is_disabled,
    vertical
)
    ---@type integer, integer
    local bg, color
    local fade = is_disabled and DISABLED or 1

    ---@param value integer
    local function faded(value)
        return fade == 1 and value or util_misc.mul_alpha(value, fade)
    end

    if action then
        local action_bg = background_color or colors.action --[[@as integer]]
        local action_hover = hover_color or colors.hover --[[@as integer]]
        local action_border = border_color or colors.action_border --[[@as integer]]

        bg = ok and (hovered and action_hover or action_bg)
            or util_misc.mul_alpha(action_bg, DISABLED)
        color = ok and action_border or util_misc.mul_alpha(action_border, DISABLED)

        border(list, x, y, w, h, faded(bg), faded(color), vertical)
    elseif active then
        color = border_color or colors.active_border --[[@as integer]]

        list:add_rect_filled({ x, y }, { x + w, y + h }, faded(colors.active), 0, 0)
        list:add_rect({ x, y }, { x + w, y + h }, faded(color), 0, 0, 1)

        if vertical then
            list:add_line({ x + w - 1, y + 1 }, { x + w - 1, y + h - 1 }, faded(colors.active), 1)
        else
            list:add_line({ x + 1, y + h - 1 }, { x + w - 1, y + h - 1 }, faded(colors.active), 1)
        end
    else
        color = border_color and util_misc.mul_alpha(border_color, DISABLED)
            or colors.inactive_border --[[@as integer]]

        border(
            list,
            x,
            y,
            w,
            h,
            faded(hovered and colors.hover or colors.inactive --[[@as integer]]),
            faded(color),
            vertical
        )

        if vertical then
            list:add_line(
                { x + w - 1, y + 1 },
                { x + w - 1, y + h - 1 },
                faded(colors.separator),
                1
            )
        else
            list:add_line(
                { x + 1, y + h - 1 },
                { x + w - 1, y + h - 1 },
                faded(colors.separator),
                1
            )
        end
    end

    if action then
        color = ok and colors.text or util_misc.mul_alpha(colors.text, DISABLED)
    elseif text_color then
        color = active and text_color or util_misc.mul_alpha(text_color, DISABLED)
    else
        color = active and colors.text or util_misc.mul_alpha(colors.text, DISABLED)
    end

    color = faded(color)

    local size = imgui.calc_text_size(text)
    list:add_text({
        x + (w - size.x) / 2,
        y + (h - size.y) / 2,
    }, color, text)
end

---@param id string
---@param x number
---@param y number
---@param w number
---@param h number
---@return boolean, boolean
local function hit(id, x, y, w, h)
    imgui.set_cursor_screen_pos({ x, y })

    local clicked = imgui.invisible_button(id, { w, h })
    return clicked, imgui.is_item_hovered()
end

---@param list ImDrawList
---@param x number
---@param y number
---@param w number
---@param h number
---@param direction "left"|"right"
---@param ok boolean
---@param hovered boolean
---@param colors NotebookColors
---@param is_disabled boolean
local function nav_arrow(list, x, y, w, h, direction, ok, hovered, colors, is_disabled)
    tab(
        list,
        x,
        y,
        w,
        h,
        "",
        false,
        true,
        ok,
        hovered,
        nil,
        nil,
        nil,
        nil,
        colors,
        is_disabled,
        false
    )

    local color = ok and colors.text or util_misc.mul_alpha(colors.text, DISABLED)
    if is_disabled then
        color = util_misc.mul_alpha(color, DISABLED)
    end

    local cx = x + w / 2
    local cy = y + (INSET + h - 1) / 2
    local r = config.lang.font_size * 0.40

    if direction == "left" then
        list:add_triangle_filled(
            { cx - 0.750 * r, cy },
            { cx + 0.750 * r, cy - 0.866 * r },
            { cx + 0.750 * r, cy + 0.866 * r },
            color
        )
    else
        list:add_triangle_filled(
            { cx + 0.750 * r, cy },
            { cx - 0.750 * r, cy + 0.866 * r },
            { cx - 0.750 * r, cy - 0.866 * r },
            color
        )
    end
end

---@param value number
---@param minimum number
---@param maximum number
---@return number
local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(value, maximum))
end

---@param id string
---@param current_tab any
---@param tabs NotebookTab[]
---@param actions NotebookActionButton[]?
---@param colors NotebookColors?
---@param stretch_tabs boolean? Stretch tabs to fill the available width
---@param vertical boolean?
---@return boolean changed
---@return any current_tab
function this.draw(id, current_tab, tabs, actions, colors, stretch_tabs, vertical)
    vertical = vertical or false

    local s = get_state(id)
    local is_disabled = disabled.is_disabled()
    colors = util_table.merge(DEFAULT_COLORS, colors or {})

    local changed = false
    local frame_tab = current_tab
    local h = config.lang.font_size + 10
    local list = imgui.get_window_draw_list()
    local pos = imgui.get_cursor_screen_pos()
    local wp = imgui.get_window_pos()
    local ws = imgui.get_window_size()
    local action_list = actions or {}
    local initial_cursor_pos = imgui.get_cursor_pos()
    local cursor_start = imgui.get_cursor_start_pos()
    local vertical_scrollbar_w = imgui.get_scroll_max_y() > 0 and SCROLLBAR_W or 0
    local horizontal_available_w = ws.x
        - initial_cursor_pos.x
        - cursor_start.x
        - vertical_scrollbar_w

    ---@type table<integer, number>
    local action_widths = {}
    local actions_w = 0
    local column_w = 0

    ---@type table<integer, string>
    local action_displays = {}

    for i, btn in ipairs(action_list) do
        local display, tw = label(btn.label)
        local w = tw + PAD * 2

        if btn.size_strings then
            for _, size_text in ipairs(btn.size_strings) do
                local _, size_tw = label(size_text)
                w = math.max(w, size_tw + PAD * 2)
            end
        end

        action_displays[i] = display
        action_widths[i] = w
        actions_w = actions_w + w
        column_w = math.max(column_w, w) --[[@as number]]
    end

    if #action_list > 1 then
        actions_w = actions_w + GAP * (#action_list - 1) --[[@as number]]
    end

    ---@type table<integer, number>
    local tab_widths = {}
    ---@type table<integer, string>
    local tab_displays = {}
    local tabs_w = 0

    for i, item in ipairs(tabs) do
        local display, tw = label(item.label)
        local w = tw + PAD * 2
        tab_displays[i] = display
        tab_widths[i] = w
        tabs_w = tabs_w + w
        column_w = math.max(column_w, w) --[[@as number]]
    end

    if vertical then
        if stretch_tabs then
            local cursor_pos = imgui.get_cursor_pos()
            local cursor_start = imgui.get_cursor_start_pos()
            local available_w = ws.x - cursor_pos.x - cursor_start.x
            column_w = math.max(column_w, available_w)
        end

        list:add_line(
            { pos.x + column_w - 1, wp.y },
            { pos.x + column_w - 1, wp.y + ws.y },
            is_disabled and util_misc.mul_alpha(colors.separator, DISABLED) or colors.separator,
            1
        )
    else
        local action_gap_w = #action_list > 0 and ACTION_GAP or 0
        local tabs_view_w = math.max(0, horizontal_available_w - actions_w - action_gap_w)
        local gaps_w = GAP * math.max(#tabs - 1, 0)

        if stretch_tabs and #tabs > 0 then
            local stretch_w = tabs_view_w - gaps_w

            if stretch_w > tabs_w then
                local extra = (stretch_w - tabs_w) / #tabs --[[@as number]]
                for i = 1, #tab_widths do
                    tab_widths[i] = tab_widths[i] + extra
                end
            end
        end

        list:add_line(
            { wp.x, pos.y + h - 1 },
            { wp.x + ws.x, pos.y + h - 1 },
            is_disabled and util_misc.mul_alpha(colors.separator, DISABLED) or colors.separator,
            1
        )
    end

    local x = pos.x
    local y = pos.y
    local tabs_clip_min_x = pos.x
    local tabs_clip_max_x = pos.x
    local tabs_content_w = tabs_w + GAP * math.max(#tabs - 1, 0) --[[@as number]]
    local tabs_overflow = false
    local draw_nav = false
    local nav_w = h

    if not vertical then
        local action_gap_w = #action_list > 0 and ACTION_GAP or 0
        local tabs_view_w = math.max(0, horizontal_available_w - actions_w - action_gap_w)

        tabs_overflow = tabs_content_w > tabs_view_w
        draw_nav = tabs_overflow and tabs_view_w >= nav_w * 2 + GAP
        tabs_clip_min_x = pos.x + (draw_nav and nav_w + GAP or 0)
        tabs_clip_max_x = pos.x + tabs_view_w - (draw_nav and nav_w + GAP or 0)

        local content_view_w = math.max(0, tabs_clip_max_x - tabs_clip_min_x)
        local max_scroll = math.max(0, tabs_content_w - content_view_w)
        s.scroll_x = clamp(s.scroll_x or 0, 0, max_scroll)

        if s.last_tab ~= current_tab then
            local tab_left = 0
            for i, item in ipairs(tabs) do
                local tab_right = tab_left + tab_widths[i]
                if item.key == current_tab then
                    if tab_left < s.scroll_x then
                        s.scroll_x = tab_left
                    elseif tab_right > s.scroll_x + content_view_w then
                        s.scroll_x = tab_right - content_view_w
                    end
                    break
                end
                tab_left = tab_right + GAP --[[@as number]]
            end
            s.scroll_x = clamp(s.scroll_x, 0, max_scroll)
        end
        s.last_tab = current_tab

        if draw_nav then
            local left_clicked, left_hovered = hit("nb_scroll_left_" .. id, pos.x, y, nav_w, h)
            nav_arrow(
                list,
                pos.x,
                y,
                nav_w,
                h,
                "left",
                s.scroll_x > 0,
                left_hovered,
                colors,
                is_disabled
            )
            if not is_disabled and left_clicked then
                s.scroll_x = clamp(s.scroll_x - content_view_w * 0.75, 0, max_scroll)
            end

            local right_x = pos.x + tabs_view_w - nav_w
            local right_clicked, right_hovered = hit("nb_scroll_right_" .. id, right_x, y, nav_w, h)
            nav_arrow(
                list,
                right_x,
                y,
                nav_w,
                h,
                "right",
                s.scroll_x < max_scroll,
                right_hovered,
                colors,
                is_disabled
            )
            if not is_disabled and right_clicked then
                s.scroll_x = clamp(s.scroll_x + content_view_w * 0.75, 0, max_scroll)
            end
        end

        x = tabs_clip_min_x - s.scroll_x
        list:push_clip_rect(
            { tabs_clip_min_x, y },
            { math.max(tabs_clip_min_x, tabs_clip_max_x), y + h },
            true
        )
    end

    for i, item in ipairs(tabs) do
        local key = item.key
        local display = tab_displays[i]
        local active = current_tab == key
        local hover_key = (vertical and id .. "_vertical_" or id .. "_") .. key --[[@as string]]
        local hovered = s.hover[hover_key] or false
        local w = vertical and column_w or tab_widths[i]

        tab(
            list,
            x,
            y,
            w,
            h,
            display,
            active,
            false,
            true,
            hovered,
            item.border_color,
            item.text_color,
            nil,
            nil,
            colors,
            is_disabled,
            vertical
        )

        local hit_id = vertical and ("nb_vertical_tab_%s_%s"):format(id, key)
            or ("nb_tab_%s_%s"):format(id, key)
        ---@type boolean, boolean
        local clicked, is_hovered

        if vertical then
            clicked, is_hovered = hit(hit_id, x, y, w, h)
        else
            local hit_x = math.max(x, tabs_clip_min_x)
            local hit_right = math.min(x + w, tabs_clip_max_x)
            if hit_right > hit_x then
                clicked, is_hovered = hit(hit_id, hit_x, y, hit_right - hit_x, h)
            else
                clicked, is_hovered = false, false
            end
        end

        if not is_disabled and clicked and not active then
            current_tab = key
            changed = true
        end

        s.hover[hover_key] = is_hovered

        if vertical then
            y = y + h + GAP
        else
            x = x + w + GAP
        end
    end

    if not vertical then
        list:pop_clip_rect()
    end

    if #action_list > 0 then
        if vertical then
            y = y + ACTION_GAP
        else
            x = pos.x + horizontal_available_w - actions_w
        end
    end

    for i, btn in ipairs(action_list) do
        local ok = not is_disabled and enabled(btn, frame_tab)
        local display = action_displays[i]
        local w = vertical and column_w or action_widths[i]
        local hit_id = vertical and ("nb_vertical_action_%s_%s"):format(id, i)
            or ("nb_action_%s_%s"):format(id, i)
        local clicked, is_hovered = hit(hit_id, x, y, w, h)

        tab(
            list,
            x,
            y,
            w,
            h,
            display,
            false,
            true,
            ok,
            is_hovered,
            btn.border_color,
            nil,
            btn.background_color,
            btn.hover_color,
            colors,
            false,
            vertical
        )

        if not is_disabled and is_hovered and btn.tooltip then
            imgui.set_tooltip(btn.tooltip)
        end

        if ok and clicked then
            local next_tab = btn.action(frame_tab)

            if next_tab ~= frame_tab then
                current_tab = next_tab
                changed = true
            end
        end

        if vertical then
            y = y + h + GAP
        else
            x = x + w + GAP
        end
    end

    imgui.set_cursor_screen_pos({
        vertical and pos.x + column_w or pos.x,
        vertical and pos.y or pos.y + h,
    })

    imgui.spacing()

    return changed, current_tab
end

return this
