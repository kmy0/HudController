---@alias HandleId "##c"|"##r"|"##b"
---@alias BeginFn fun(): boolean
---@alias EndFn fun()

---@class ResizableState
---@field w number
---@field h number
---@field open boolean
---@field drag? DragState

---@class DragState
---@field id HandleId
---@field mx number
---@field my number
---@field w number
---@field h number
---@field dx boolean
---@field dy boolean

---@class Handle
---@field id HandleId
---@field x number
---@field y number
---@field w number
---@field h number
---@field dx boolean
---@field dy boolean

---@class Border
---@field dir [integer, integer]
---@field n1 [integer, integer]
---@field n2 [integer, integer]
---@field angle number

local color = require("HudController.util.imgui.color")
local config = require("HudController.config.init")

local this = {}

local MIN_W, MIN_H = 200, 120
local HIT_R, HIT_B = 7, 7
local GRIP_HIT_MIN = 10
local LINE = 1
local CONTENT_PADDING = { 0, 0 }

local ROUNDING = 0
local BORDER_SIZE = 1

local COL_EDGE_HOVER = 0xC7BF661A
local COL_EDGE_ACTIVE = 0xFFBF661A
local COL_GRIP_HOVER = 0xff4f4e4d
local COL_GRIP_ACTIVE = 0xff8d8c8c

local COND_ALWAYS = 1
local STYLE_VAR_WINDOW_PADDING = 2
local MOUSE_LEFT = 0

local HANDLE_CORNER = "##c"
local HANDLE_RIGHT = "##r"
local HANDLE_BOTTOM = "##b"

local PI = math.pi

local BORDERS = {
    ---@type Border
    right = { dir = { -1, 0 }, n1 = { 1, 0 }, n2 = { 1, 1 }, angle = 0 },
    ---@type Border
    down = { dir = { 0, -1 }, n1 = { 1, 1 }, n2 = { 0, 1 }, angle = PI * 0.5 },
}

local EDGE_STYLES = {
    [HANDLE_RIGHT] = { border = BORDERS.right, hover = COL_EDGE_HOVER, active = COL_EDGE_ACTIVE },
    [HANDLE_BOTTOM] = { border = BORDERS.down, hover = COL_EDGE_HOVER, active = COL_EDGE_ACTIVE },
}

---@type table<string, ResizableState>
local states = {}
---@type string[]
local stack = {}

---@param id string
local function stack_remove(id)
    for i = #stack, 1, -1 do
        if stack[i] == id then
            for j = #stack, i, -1 do
                local st = states[stack[j]]
                if st then
                    st.open = false
                    st.drag = nil
                end
                stack[j] = nil
            end
            return
        end
    end
end

---@param id string
---@param st ResizableState
local function stack_push(id, st)
    if not st.open then
        st.open = true
        stack[#stack + 1] = id
    end
end

---@param def table
---@param pos { x: number, y: number }
---@param size { x: number, y: number }
---@return number[] min
---@return number[] max
local function border_segment(def, pos, size)
    local min_x, min_y = pos.x, pos.y
    local max_x, max_y = pos.x + size.x - 1, pos.y + size.y - 1

    if def == BORDERS.right then
        return { max_x, min_y + ROUNDING }, { max_x, max_y - ROUNDING }
    end

    return { min_x + ROUNDING, max_y }, { max_x - ROUNDING, max_y }
end

---@param a number[]
---@param b number[]
---@param n number[]
---@return number x
---@return number y
local function lerp_point(a, b, n)
    return a[1] + (b[1] - a[1]) * n[1], a[2] + (b[2] - a[2]) * n[2]
end

---@param dl ImDrawList
---@param def Border
---@param x number
---@param y number
---@param angle_min number
---@param angle_max number
local function path_border_arc(dl, def, x, y, angle_min, angle_max)
    local center = {
        x + 0.5 + def.dir[1] * ROUNDING,
        y + 0.5 + def.dir[2] * ROUNDING,
    }
    dl:path_arc_to(center, ROUNDING, angle_min, angle_max, 0)
end

---@param dl ImDrawList
---@param def Border
---@param pos Vector2f
---@param size Vector2f
---@param col integer
---@param thickness integer
local function render_border(dl, def, pos, size, col, thickness)
    local seg_min, seg_max = border_segment(def, pos, size)
    local x1, y1 = lerp_point(seg_min, seg_max, def.n1)
    local x2, y2 = lerp_point(seg_min, seg_max, def.n2)

    dl:path_clear()
    path_border_arc(dl, def, x1, y1, def.angle - PI * 0.25, def.angle)
    path_border_arc(dl, def, x2, y2, def.angle, def.angle + PI * 0.25)
    dl:path_stroke(col, 0, thickness)
end

---@param dl ImDrawList
---@param right number
---@param bottom number
---@param size number
---@param col integer
local function render_grip(dl, right, bottom, size, col)
    local inset = math.floor(BORDER_SIZE * 0.5 + 0.5)

    dl:path_clear()
    dl:path_line_to({ right - size, bottom - inset })
    dl:path_line_to({ right - inset, bottom - size })
    dl:path_arc_to_fast({ right - (ROUNDING + inset), bottom - (ROUNDING + inset) }, ROUNDING, 0, 3)
    dl:path_fill_convex(col)
end

---@return number draw_size
---@return number hit_size
local function calc_grip_sizes()
    local fs = config.lang.font_size
    local draw = math.floor(math.max(fs * 1.0, ROUNDING + 1 + fs * 0.15))
    local hit = math.max(GRIP_HIT_MIN, draw)
    return draw, hit
end

---@param wp Vector2f
---@param ws Vector2f
---@param winner HandleId?
---@param is_active boolean?
---@param grip_draw_size number
local function draw_highlight(wp, ws, winner, is_active, grip_draw_size)
    if not winner then
        return
    end

    local right, bottom = wp.x + ws.x, wp.y + ws.y
    local dl = imgui.get_foreground_draw_list()
    dl:push_clip_rect(wp, { right, bottom }, false)

    if winner == HANDLE_CORNER then
        local col = is_active and COL_GRIP_ACTIVE or COL_GRIP_HOVER
        render_grip(dl, right, bottom, grip_draw_size, col)
    else
        local edge = EDGE_STYLES[winner]
        local col = is_active and edge.active or edge.hover
        render_border(dl, edge.border, wp, ws, col, LINE)
    end

    dl:pop_clip_rect()
end

---@param id string
---@param w number
---@param h number
local function save_popup_size(id, w, h)
    local sizes = config.gui.current.gui.popup_size

    if not sizes then
        sizes = {}
        config.gui.current.gui.popup_size = sizes
    end

    sizes[id] = {
        x = w,
        y = h,
    }

    config.gui:save()
end

---@param id string
---@param init_w? number
---@param init_h? number
---@return number w
---@return number h
local function get_initial_size(id, init_w, init_h)
    local sizes = config.gui.current.gui.popup_size
    local saved = sizes and sizes[id]

    if saved then
        return saved.x, saved.y
    end

    return init_w or 300, init_h or 220
end

---@param id string
---@param init_w? number
---@param init_h? number
---@return ResizableState
local function get_state(id, init_w, init_h)
    local st = states[id]
    if not st then
        local w, h = get_initial_size(id, init_w, init_h)
        st = { w = w, h = h, open = false }
        states[id] = st
    end
    return st
end

---@param st ResizableState
---@param id string
local function update_drag(st, id)
    local drag = st.drag
    if not drag then
        return
    end

    if not imgui.is_mouse_down(MOUSE_LEFT) then
        save_popup_size(id, st.w, st.h)
        st.drag = nil
        return
    end

    local m = imgui.get_mouse()
    if drag.dx then
        st.w = math.max(MIN_W, drag.w + (m.x - drag.mx))
    end
    if drag.dy then
        st.h = math.max(MIN_H, drag.h + (m.y - drag.my))
    end
end

---@param ws { x: number, y: number }
---@param grip_hit_size number
---@return Handle[]
local function build_handles(ws, grip_hit_size)
    return {
        {
            id = HANDLE_CORNER,
            x = ws.x - grip_hit_size,
            y = ws.y - grip_hit_size,
            w = grip_hit_size,
            h = grip_hit_size,
            dx = true,
            dy = true,
        },
        { id = HANDLE_RIGHT, x = ws.x - HIT_R, y = 0, w = HIT_R, h = ws.y, dx = true, dy = false },
        { id = HANDLE_BOTTOM, x = 0, y = ws.y - HIT_B, w = ws.x, h = HIT_B, dx = false, dy = true },
    }
end

---@param st ResizableState
---@param id string
---@param handles Handle[]
---@param wp { x: number, y: number }
---@return table<HandleId, boolean> hovered
---@return table<HandleId, boolean> active
local function submit_handles(st, id, handles, wp)
    ---@type table<string, boolean>, table<string, boolean>
    local hovered, active = {}, {}
    local m = imgui.get_mouse()

    local allowed = st.drag ~= nil or stack[#stack] == id
    for _, h in ipairs(handles) do
        local min_x = wp.x + h.x
        local min_y = wp.y + h.y
        local max_x = min_x + h.w
        local max_y = min_y + h.h
        local is_hovered = allowed and m.x >= min_x and m.x < max_x and m.y >= min_y and m.y < max_y

        hovered[h.id] = is_hovered
        active[h.id] = st.drag ~= nil and st.drag.id == h.id and imgui.is_mouse_down(MOUSE_LEFT)

        if is_hovered and imgui.is_mouse_clicked(MOUSE_LEFT) and not st.drag then
            st.drag = {
                id = h.id,
                mx = m.x,
                my = m.y,
                w = st.w,
                h = st.h,
                dx = h.dx,
                dy = h.dy,
            }
            active[h.id] = true
        end
    end

    return hovered, active
end

---@param st ResizableState
---@param handles Handle[]
---@param hovered table<HandleId, boolean>
---@return HandleId?
local function pick_winner(st, handles, hovered)
    if st.drag then
        return st.drag.id
    end

    for _, h in ipairs(handles) do
        if hovered[h.id] then
            return h.id
        end
    end
end

---@param id string
---@param begin_fn BeginFn
---@param end_fn EndFn
---@param draw_contents fun()
---@param init_w? number
---@param init_h? number
---@return boolean
function this.draw(id, begin_fn, end_fn, draw_contents, init_w, init_h)
    local st = get_state(id, init_w, init_h)
    update_drag(st, id)

    imgui.set_next_window_size({ st.w, st.h }, COND_ALWAYS)
    imgui.push_style_var(STYLE_VAR_WINDOW_PADDING, Vector2f.new(0, 0))
    local open = begin_fn()
    imgui.pop_style_var(1)

    if not open then
        st.drag = nil
        stack_remove(id)
        return false
    end

    stack_push(id, st)

    local wp, ws = imgui.get_window_pos(), imgui.get_window_size()
    local grip_draw_size, grip_hit_size = calc_grip_sizes()
    local handles = build_handles(ws, grip_hit_size)
    local hovered, active = submit_handles(st, id, handles, wp)
    local winner = pick_winner(st, handles, hovered)

    imgui.set_cursor_pos(CONTENT_PADDING)
    draw_contents()

    draw_highlight(wp, ws, winner, winner and active[winner], grip_draw_size)
    end_fn()
    return true
end

---@param id string
---@param draw_contents fun()
---@param pos Vector2f
---@param init_w? number
---@param init_h? number
---@return boolean
function this.draw_popup(id, draw_contents, pos, init_w, init_h)
    return this.draw(id, function()
        imgui.set_next_window_pos(pos, 1)
        return imgui.begin_popup(id)
    end, imgui.end_popup, draw_contents, init_w, init_h)
end

---@param id string
---@param draw_contents fun()
---@param label_color integer?
---@param init_w? number
---@param init_h? number
---@return boolean
function this.draw_menu(id, draw_contents, label_color, init_w, init_h)
    return this.draw(id, function()
        if label_color then
            imgui.push_style_color(0, color.with_alpha(label_color))
        end

        local open = imgui.begin_menu(id)

        if label_color then
            imgui.pop_style_color(1)
        end
        return open
    end, imgui.end_menu, draw_contents, init_w, init_h)
end

return this
