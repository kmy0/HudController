local config = require("HudController.config.init")
local d = require("HudController.util.imgui.disabled")
local util_misc = require("HudController.util.misc.init")
---@module "HudController.util.imgui.init"
local util_imgui = util_misc.lazy_require("HudController.util.imgui.init")
local util_table = require("HudController.util.misc.table")

local this = {}

---@param label string
---@param selected boolean[]
---@param default_preview string
---@param options string[]
---@param width integer?
---@return boolean, boolean[]
function this.combo_multi(label, selected, default_preview, options, width)
    width = width or imgui.calc_item_width()

    local popup_id = "##" .. label .. "_popup"
    ---@type string[]
    local chosen = {}
    for i, name in ipairs(options) do
        if selected[i] then
            chosen[#chosen + 1] = name
        end
    end

    local disabled = d.is_disabled()
    local frame_height = config.lang.font_size + 6.0
    local arrow_region_width = frame_height
    local text_padding = 4.0
    local max_preview_width = width - arrow_region_width - text_padding * 2
    ---@type string
    local full_preview

    if #chosen == 0 then
        full_preview = default_preview
    else
        full_preview = table.concat(chosen, ", ")
    end

    ---@type string
    local preview = full_preview
    local text_oversize = false
    if imgui.calc_text_size(preview).x > max_preview_width then
        text_oversize = true

        if #chosen > 0 then
            local found = false
            for visible_count = #chosen - 1, 1, -1 do
                local hidden_count = #chosen - visible_count
                ---@type string[]
                local visible = {}

                for i = 1, visible_count do
                    visible[#visible + 1] = chosen[i]
                end

                local candidate = table.concat(visible, ", ") .. " +" .. hidden_count

                if imgui.calc_text_size(candidate).x <= max_preview_width then
                    preview = candidate
                    found = true
                    break
                end
            end

            if not found then
                local hidden_count = #chosen - 1
                local count_suffix = hidden_count > 0 and (" +" .. hidden_count) or ""

                local ellipsis = "..."
                local first = chosen[1]

                while
                    #first > 0
                    and imgui.calc_text_size(first .. ellipsis .. count_suffix).x
                        > max_preview_width
                do
                    first = first:sub(1, -2) --[[@as string]]
                end

                preview = first .. ellipsis .. count_suffix
                if imgui.calc_text_size(preview).x > max_preview_width then
                    preview = ellipsis .. count_suffix

                    while #preview > 0 and imgui.calc_text_size(preview).x > max_preview_width do
                        preview = preview:sub(1, -2) --[[@as string]]
                    end
                end
            end
        else
            local suffix = "..."

            preview = full_preview

            while #preview > 0 and imgui.calc_text_size(preview .. suffix).x > max_preview_width do
                preview = preview:sub(1, -2) --[[@as string]]
            end

            preview = preview .. suffix
        end
    end

    local pos = imgui.get_cursor_screen_pos()
    local draw_list = imgui.get_window_draw_list()

    d.begin_disabled(disabled)

    local clicked = false
    if imgui.invisible_button("##" .. label .. "_btn", { width, frame_height }) then
        clicked = true
    end

    d.end_disabled()

    local hovered = imgui.is_item_hovered()
    if text_oversize then
        util_imgui.tooltip(full_preview)
    end

    local bg_col = 0
    local text_col = 0xFFFFFFFF

    if hovered then
        bg_col = 0xff4f4e4d
    else
        bg_col = 0xff403636
    end

    bg_col = disabled and util_misc.mul_alpha(bg_col, 0.6) or bg_col
    text_col = disabled and util_misc.mul_alpha(text_col, 0.6) or text_col
    draw_list:add_rect_filled(
        { pos.x, pos.y },
        { pos.x + width, pos.y + frame_height },
        bg_col,
        0,
        0
    )

    local text_y = pos.y + (frame_height - config.lang.font_size) * 0.5
    draw_list:add_text({ pos.x + text_padding, text_y }, text_col, preview)

    local r = config.lang.font_size * 0.40
    local cx = pos.x + width - arrow_region_width * 0.5
    local cy = pos.y + frame_height * 0.5

    if imgui.is_popup_open(popup_id) then
        draw_list:add_rect_filled({
            pos.x + width - arrow_region_width,
            pos.y,
        }, {
            pos.x + width,
            pos.y + frame_height,
        }, 0xff4f4e4d, 0, 0)
    end

    draw_list:add_triangle_filled(
        { cx, cy + 0.750 * r },
        { cx - 0.866 * r, cy - 0.750 * r },
        { cx + 0.866 * r, cy - 0.750 * r },
        text_col
    )

    if label then
        util_imgui.set_label(label, -1)
    end

    if clicked then
        imgui.open_popup(popup_id)
    end

    local checkmark_width = config.lang.font_size
    local inner_spacing = 4.0
    local item_padding = 8.0
    local min_popup_width = width

    for _, name in ipairs(options) do
        local text_w = imgui.calc_text_size(name).x
        local needed = checkmark_width + inner_spacing + text_w + item_padding

        if needed > min_popup_width then
            min_popup_width = needed
        end
    end

    local popup_pos = {
        pos.x,
        pos.y + frame_height,
    }

    imgui.set_next_window_pos(popup_pos, 1)
    imgui.set_next_window_size({ min_popup_width, 0 }, 1)

    local changed = false
    local popup_flags = 4 | 64 -- NoMove | AlwaysAutoResize
    if imgui.begin_popup(popup_id, popup_flags) then
        for i, name in ipairs(options) do
            if util_imgui.menu_item(name .. "##" .. i, selected[i], nil, nil) then
                selected[i] = not selected[i]
                changed = true
            end
        end

        imgui.end_popup()
    end

    return changed, selected
end

---@generic T
---@param label string
---@param bits integer
---@param default_preview string
---@param values T[]
---@param get_key fun(value: T): integer
---@param get_label fun(value: T): string
---@param width integer?
---@return boolean, integer
function this.combo_multi_bits(label, bits, default_preview, values, get_key, get_label, width)
    local selected_keys = util_misc.unpack_bits(bits)
    ---@type string[]
    local options = {}
    ---@type boolean[]
    local selected = {}

    ---@diagnostic disable-next-line: no-unknown
    for i, value in ipairs(values) do
        options[i] = get_label(value)
        selected[i] = util_table.contains_any(selected_keys, get_key(value))
    end

    local changed, choice = this.combo_multi(label, selected, default_preview, options, width)
    if not changed then
        return false, bits
    end

    local new_bits = 0
    for i, enabled in ipairs(choice) do
        if enabled then
            new_bits = new_bits | (1 << (get_key(values[i]) - 1))
        end
    end

    return true, new_bits
end

return this
