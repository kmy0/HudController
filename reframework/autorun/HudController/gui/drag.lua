local gui_util = require("HudController.gui.util")
local state = require("HudController.gui.state")
local util_imgui = require("HudController.util.imgui")

---@class (exact) Drag
---@field protected _drag any?
---@field item_pos table<any, number>
---@field protected _start_pos number

---@class Drag
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@return Drag
function this:new()
    return setmetatable({ item_pos = {}, _start_pos = 0 }, self)
end

---@param unique_key string
---@param value any
function this:draw_drag_button(unique_key, value)
    self._start_pos = imgui.get_cursor_screen_pos().y

    util_imgui.dummy_button(gui_util.tr("misc.text_drag", unique_key))
    local hover = imgui.is_item_hovered()
    local mouse_down = imgui.is_mouse_down(0)

    if not self._drag and hover and mouse_down then
        self._drag = value
    elseif hover and not mouse_down then
        local end_pos = imgui.get_cursor_screen_pos().y
        util_imgui.highlight(state.colors.info, 0, -(end_pos - self._start_pos))
    end
end

---@param value any
function this:check_drag_pos(value)
    local end_pos = imgui.get_cursor_screen_pos().y

    if self._drag == value then
        util_imgui.highlight(state.colors.info, 0, -(end_pos - self._start_pos))
    end

    if self._drag == value then
        self.item_pos[value] = imgui.get_mouse().y
    else
        self.item_pos[value] = self._start_pos
    end
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
