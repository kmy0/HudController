local common = require(".HudController.util.imgui.combo.common")
local config = require("HudController.config.init")
local filter = require("HudController.util.imgui.filter")
local util_misc = require("HudController.util.misc.init")
local util_table = require("HudController.util.misc.table")

---@module "HudController.util.imgui.init"
local util_imgui = util_misc.lazy_require("HudController.util.imgui.init")

local this = {}

---@param selected boolean[]
---@param default_preview string
---@param options string[]
---@param width number
---@param frame_height number
---@param static_preview boolean?
---@return string, string, boolean
local function get_preview(selected, default_preview, options, width, frame_height, static_preview)
    local max_preview_width = width - frame_height - 2 * common.PREVIEW_PADDING

    ---@type string[]
    local chosen = {}
    ---@type string
    local full_preview
    if static_preview then
        full_preview = default_preview
    else
        for i, name in ipairs(options) do
            if selected[i] then
                table.insert(chosen, name)
            end
        end

        full_preview = #chosen == 0 and default_preview or table.concat(chosen, ", ")
    end

    local preview = full_preview
    local text_oversize = false

    if imgui.calc_text_size(preview).x > max_preview_width then
        text_oversize = true

        if not static_preview and #chosen > 0 then
            local found = false

            for visible_count = #chosen - 1, 1, -1 do
                local hidden_count = #chosen - visible_count
                ---@type string[]
                local visible = {}
                for i = 1, visible_count do
                    table.insert(visible, chosen[i])
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
                preview =
                    common.truncate_text(chosen[1], max_preview_width, "..." .. count_suffix, true)
            end
        else
            preview = common.truncate_text(preview, max_preview_width, "...", false)
        end
    end

    return preview, full_preview, text_oversize
end

---@param label string
---@param selected boolean[]
---@param default_preview string
---@param options string[]
---@return boolean, boolean[]
function this.combo_multi(label, selected, default_preview, options)
    local width = imgui.calc_item_width()
    local popup_id = "##" .. label .. "_popup"
    local frame_height = config.lang.font_size + common.FRAME_HEIGHT_PADDING
    local preview, full_preview, text_oversize =
        get_preview(selected, default_preview, options, width, frame_height)
    local clicked, pos = common.draw_combo(
        label,
        "##" .. label .. "_btn",
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
    imgui.set_next_window_size(
        { common.get_popup_width(options, width), common.get_combo_popup_height(options) },
        1
    )

    local changed = false
    if imgui.begin_popup(popup_id, common.POPUP_FLAGS) then
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

---@param label string
---@param selected boolean[]
---@param default_preview string
---@param options string[]
---@param static_preview boolean?
---@return boolean, boolean[]
function this.combo_multi_filter(label, selected, default_preview, options, static_preview)
    local width = imgui.calc_item_width()
    local combo_id = label
    local popup_id = "##" .. label .. "_filter_popup"
    local frame_height = config.lang.font_size + common.FRAME_HEIGHT_PADDING
    local preview, full_preview, text_oversize =
        get_preview(selected, default_preview, options, width, frame_height, static_preview)
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
    imgui.set_next_window_size(
        { common.get_popup_width(options, width), common.get_combo_popup_height(options) },
        1
    )

    local changed = false
    local popup_open = false
    if imgui.begin_popup(popup_id, common.POPUP_FLAGS) then
        popup_open = true
        local query = draw_input and filter.get_input():lower() or nil
        for i, name in ipairs(options) do
            if query == nil or name:lower():find(query, 1, true) then
                if util_imgui.menu_item(name .. "##" .. i, selected[i], nil, nil) then
                    selected[i] = not selected[i]
                    changed = true
                end
            end
        end
        imgui.end_popup()
    end

    common.reset_combo_filter(combo_id, popup_open)
    return changed, selected
end

---@generic T
---@param label string
---@param bits integer
---@param default_preview string
---@param values T[]
---@param get_key fun(value: T, index: integer): integer
---@param get_label fun(value: T, index: integer): string
---@param draw_fn fun(label: string, selected: boolean[], default_preview: string, options: string[]): boolean, boolean[]
---@return boolean, integer
local function combo_bits(label, bits, default_preview, values, get_key, get_label, draw_fn)
    local selected_keys = util_misc.unpack_bits(bits)
    ---@type string[]
    local options = {}
    ---@type boolean[]
    local selected = {}
    ---@diagnostic disable-next-line: no-unknown
    for i, value in ipairs(values) do
        options[i] = get_label(value, i)
        selected[i] = util_table.contains_any(selected_keys, get_key(value, i))
    end

    local changed, choice = draw_fn(label, selected, default_preview, options)
    if not changed then
        return false, bits
    end

    local new_bits = 0
    for i, enabled in ipairs(choice) do
        if enabled then
            new_bits = new_bits | (1 << (get_key(values[i], i) - 1))
        end
    end
    return true, new_bits
end

---@generic T
---@param label string
---@param bits integer
---@param default_preview string
---@param values T[]
---@param get_key fun(value: T, index: integer): integer
---@param get_label fun(value: T, index: integer): string
---@return boolean, integer
function this.combo_multi_bits(label, bits, default_preview, values, get_key, get_label)
    return combo_bits(label, bits, default_preview, values, get_key, get_label, this.combo_multi)
end

---@generic T
---@param label string
---@param bits integer
---@param default_preview string
---@param values T[]
---@param get_key fun(value: T, index: integer): integer
---@param get_label fun(value: T, index: integer): string
---@return boolean, integer
function this.combo_multi_bits_filter(label, bits, default_preview, values, get_key, get_label)
    return combo_bits(
        label,
        bits or 0,
        default_preview,
        values,
        get_key,
        get_label,
        this.combo_multi_filter
    )
end

return this
