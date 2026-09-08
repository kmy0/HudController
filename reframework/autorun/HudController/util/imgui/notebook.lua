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
local util_misc = require("HudController.util.misc.init")

local this = {
    ---@type {[string]: NotebookState}
    _state = {},
}

local PAD, GAP, ACTION_GAP = 12, 2, 8
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
        }

        this._state[id] = s
    end

    return s
end

---@param text string
---@return number
local function width(text)
    return imgui.calc_text_size(text).x
end

---@param text string
---@return string, number
local function label(text)
    local w = width(text)

    if w <= MAX_W then
        return text, w
    end

    local suffix = "..."
    local sw = width(suffix)

    if sw >= MAX_W then
        return suffix, sw
    end

    local out = ""

    for _, cp in utf8.codes(text) do
        local next = out .. utf8.char(cp)

        if width(next .. suffix) > MAX_W then
            break
        end

        out = next --[[@as string]]
    end

    out = out .. suffix

    return out, width(out)
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
local function border(list, x, y, w, h, bg, color)
    list:add_rect_filled({ x, y + INSET }, { x + w, y + h - 1 }, bg, 0, 0)
    list:add_line({ x, y + INSET }, { x, y + h - 1 }, color, 1)
    list:add_line({ x + w, y + INSET }, { x + w, y + h - 1 }, color, 1)
    list:add_line({ x, y + INSET }, { x + w, y + INSET }, color, 1)
end

---@param list any
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
---@param disabled boolean
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
    disabled
)
    ---@type integer, integer
    local bg, color
    local fade = disabled and DISABLED or 1

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

        border(list, x, y, w, h, faded(bg), faded(color))
    elseif active then
        color = border_color or colors.active_border --[[@as integer]]

        list:add_rect_filled({ x, y }, { x + w, y + h }, faded(colors.active), 0, 0)
        list:add_rect({ x, y }, { x + w, y + h }, faded(color), 0, 0, 1)
        list:add_line({ x + 1, y + h - 1 }, { x + w - 1, y + h - 1 }, faded(colors.active), 1)
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
            faded(color)
        )

        list:add_line({ x + 1, y + h - 1 }, { x + w - 1, y + h - 1 }, faded(colors.separator), 1)
    end

    if action then
        color = ok and colors.text or util_misc.mul_alpha(colors.text, DISABLED)
    elseif text_color then
        color = active and text_color or util_misc.mul_alpha(text_color, DISABLED)
    else
        color = active and colors.text or util_misc.mul_alpha(colors.text, DISABLED)
    end

    color = faded(color)

    local s = imgui.calc_text_size(text)

    list:add_text({
        x + (w - s.x) / 2,
        y + (h - s.y) / 2,
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

---@param id string
---@param current_tab any
---@param tabs NotebookTab[]
---@param actions NotebookActionButton[]?
---@param colors NotebookColors?
---@param disabled boolean?
---@return boolean changed
---@return any current_tab
function this.draw(id, current_tab, tabs, actions, colors, disabled)
    local s = get_state(id)
    disabled = disabled or false

    ---@type table<string, integer>
    local resolved_colors = {}
    for name, value in pairs(DEFAULT_COLORS) do
        resolved_colors[name] = colors and colors[name] or value
    end
    colors = resolved_colors

    local changed = false
    local frame_tab = current_tab
    local h = config.lang.font_size + 10

    local list = imgui.get_window_draw_list()
    local pos = imgui.get_cursor_screen_pos()

    local x0 = pos.x
    local x = 0
    local y = pos.y

    local wp = imgui.get_window_pos()
    local ws = imgui.get_window_size()

    list:add_line(
        { wp.x, y + h - 1 },
        { wp.x + ws.x, y + h - 1 },
        disabled and util_misc.mul_alpha(colors.separator, DISABLED) or colors.separator,
        1
    )

    for _, item in ipairs(tabs) do
        local key = item.key
        local text = item.label
        local border_color = item.border_color
        local text_color = item.text_color

        local display, tw = label(text)

        local active = current_tab == key
        local hover_key = id .. "_" .. key --[[@as string]]

        local w = tw + PAD * 2
        local tx = x0 + x

        local hovered = s.hover[hover_key] or false

        tab(
            list,
            tx,
            y,
            w,
            h,
            display,
            active,
            false,
            true,
            hovered,
            border_color,
            text_color,
            nil,
            nil,
            colors,
            disabled
        )

        local clicked, is_hovered = hit(("nb_tab_%s_%s"):format(id, key), tx, y, w, h)

        if not disabled and clicked and not active then
            current_tab = key
            changed = true
        end

        s.hover[hover_key] = is_hovered

        x = x + w + GAP
    end

    x = x + ACTION_GAP

    for i, btn in ipairs(actions or {}) do
        local ok = not disabled and enabled(btn, frame_tab)
        local display, tw = label(btn.label)
        local w = tw + PAD * 2

        if btn.size_strings then
            for _, size_text in ipairs(btn.size_strings) do
                local _, size_tw = label(size_text)
                w = math.max(w, size_tw + PAD * 2)
            end
        end

        local tx = x0 + x
        local hk = id .. "_action_" .. i
        local clicked, is_hovered = hit(("nb_action_%s_%s"):format(id, i), tx, y, w, h)

        tab(
            list,
            tx,
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
            false
        )
        if not disabled and is_hovered and btn.tooltip then
            imgui.set_tooltip(btn.tooltip)
        end

        if ok and clicked then
            local next_tab = btn.action(frame_tab)

            if next_tab ~= frame_tab then
                current_tab = next_tab
                changed = true
            end
        end

        s.hover[hk] = is_hovered

        x = x + w + GAP
    end

    imgui.set_cursor_screen_pos({
        x0,
        y + h,
    })

    imgui.spacing()

    return changed, current_tab
end

return this
