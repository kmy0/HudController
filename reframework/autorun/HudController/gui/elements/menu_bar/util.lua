local util_imgui = require("HudController.util.imgui.init")

local this = {}

---@param label string
---@param draw_func fun()
---@param enabled_obj boolean?
---@param text_color integer?
---@param offset_x number?
---@return boolean
function this.draw_menu(label, draw_func, enabled_obj, text_color, offset_x)
    enabled_obj = enabled_obj == nil and true or enabled_obj

    if text_color then
        imgui.push_style_color(0, text_color)
    end

    if offset_x then
        util_imgui.adjust_pos(offset_x)
    end

    local menu = imgui.begin_menu(label, enabled_obj)

    if text_color then
        imgui.pop_style_color(1)
    end

    if menu then
        draw_func()
        imgui.end_menu()
    end

    return menu
end

return this
