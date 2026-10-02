local common = require(".HudController.util.imgui.combo.common")
local config = require("HudController.config.init")
local filter = require("HudController.util.imgui.filter")

local this = {}

---@param label string
---@param value string
---@param values string[]
---@param draw_fn fun(value: string): string?
---@param display_format (fun(value: string): string)?
---@param width_offset number?
---@return boolean, string
function this.combo_popup(label, value, values, draw_fn, display_format, width_offset)
    local width = imgui.calc_item_width()
    local popup_id = "##" .. label .. "_popup"
    local frame_height = config.lang.font_size + common.FRAME_HEIGHT_PADDING
    local preview, full_preview, text_oversize = common.get_text_preview(
        display_format and display_format(value) or value,
        width,
        frame_height
    )

    local clicked, pos = common.draw_combo(
        label,
        "##" .. label .. "_filter_btn",
        popup_id,
        preview,
        full_preview,
        text_oversize,
        width
    )

    if clicked then
        imgui.open_popup(popup_id)
    end

    imgui.set_next_window_pos({ pos.x, pos.y + frame_height }, 1)
    imgui.set_next_window_size({
        common.get_popup_width(values, width) + (width_offset or 0),
        common.get_combo_popup_height(values),
    }, 1)

    local changed = false
    if imgui.begin_popup(popup_id, common.POPUP_FLAGS) then
        local selected = draw_fn(value)

        if selected ~= nil then
            changed = selected ~= value
            value = selected
            imgui.close_current_popup()
        end

        imgui.end_popup()
    end

    return changed, value
end

---@param label string
---@param value string
---@param values string[]
---@param draw_fn fun(query: string, value: string): string?
---@param display_format (fun(value: string): string)?
---@param width_offset number?
---@return boolean, string
function this.combo_popup_filter(label, value, values, draw_fn, display_format, width_offset)
    local width = imgui.calc_item_width()
    local combo_id = label
    local popup_id = "##" .. label .. "_filter_popup"
    local frame_height = config.lang.font_size + common.FRAME_HEIGHT_PADDING
    local preview, full_preview, text_oversize = common.get_text_preview(
        display_format and display_format(value) or value,
        width,
        frame_height
    )

    local clicked, pos = common.draw_combo(
        label,
        "##" .. label .. "_filter_btn",
        popup_id,
        preview,
        full_preview,
        text_oversize,
        width,
        filter.is_input_active(combo_id)
    )

    local draw_input = common.update_combo_filter(combo_id, popup_id, clicked, pos, width)

    imgui.set_next_window_pos({ pos.x, pos.y + frame_height }, 1)
    imgui.set_next_window_size({
        common.get_popup_width(values, width) + (width_offset or 0),
        common.get_combo_popup_height(values),
    }, 1)

    local changed = false
    local popup_open = false

    if imgui.begin_popup(popup_id, common.POPUP_FLAGS) then
        popup_open = true

        local selected = draw_fn(draw_input and filter.get_input() or "", value)

        if selected ~= nil then
            changed = selected ~= value
            value = selected
            imgui.close_current_popup()
        end

        imgui.end_popup()
    end

    common.reset_combo_filter(combo_id, popup_open)

    return changed, value
end

return this
