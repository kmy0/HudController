---@class (exact) Drag
---@field protected _drag any?
---@field item_pos table<any, number>
---@field protected _start_pos number
---@field protected _last_cursor_pos number
---@field protected _dir integer

local gui_util = require("HudController.gui.util")
local mod = require("HudController.data.mod")
local util_imgui = require("HudController.util.imgui.init")

---@class Drag
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@return Drag
function this:new()
    return setmetatable({ item_pos = {}, _start_pos = 0, _last_cursor_pos = 0, _dir = 1 }, self)
end

---@param unique_key string
---@param value any
---@param y_size number?
function this:draw_drag_button(unique_key, value, y_size)
    self._start_pos = imgui.get_cursor_screen_pos().y
    y_size = y_size or 0

    util_imgui.dummy_button(gui_util.tr("misc.text_drag", unique_key), { 0, y_size })
    local hover = imgui.is_item_hovered()
    local mouse_down = imgui.is_mouse_down(0)

    if not self._drag and hover and mouse_down then
        self._drag = value
    elseif hover and not mouse_down then
        local end_pos = imgui.get_cursor_screen_pos().y
        util_imgui.highlight(mod.enum.colors.info, 0, -(end_pos - self._start_pos))
    end
end

---@param value any
---@param offset_x integer?
---@param offset_y integer?
function this:check_drag_pos(value, offset_x, offset_y)
    local end_pos = imgui.get_cursor_screen_pos().y
    local cursor_pos = imgui.get_mouse().y
    offset_x = offset_x or 0
    offset_y = offset_y or 0

    if self._drag == value then
        util_imgui.highlight(
            mod.enum.colors.info,
            0 + offset_x,
            -(end_pos - self._start_pos) + offset_y
        )
    end

    if self._last_cursor_pos > cursor_pos then
        self._dir = -1
    elseif self._last_cursor_pos < cursor_pos then
        self._dir = 1
    end

    if self._drag == value then
        self.item_pos[value] = cursor_pos
    else
        if self._dir == 1 then
            self.item_pos[value] = self._start_pos
        else
            self.item_pos[value] = end_pos
        end
    end

    self._last_cursor_pos = cursor_pos
end

---@return boolean
function this:is_drag()
    return self._drag ~= nil
end

---@return boolean
function this:is_released()
    local ret = self:is_drag() and imgui.is_mouse_released(0)
    if ret then
        self._drag = nil
    end
    return ret
end

function this:clear()
    self.item_pos = {}
end

return this
