local filter = require("HudController.util.imgui.filter")
local util_table = require("HudController.util.misc.table")

local this = {}

local filtered_index = 1

---@param name string
local function reset_state(name)
    filtered_index = 1
    filter.reset(name)
end

---@param name string
---@return boolean
local function is_combo_open(name)
    imgui.push_id(name)
    local open = imgui.is_popup_open("##ComboPopup")
    imgui.pop_id()

    return open
end

---@param name string
---@param selection integer
---@param combo Combo
---@return boolean, integer
function this.combo_filter(name, selection, combo)
    local changed = false

    if filter.is_active(name) and not is_combo_open(name) then
        reset_state(name)
    end

    if filter.update(name) then
        local width = imgui.calc_item_width()
        local pos = imgui.get_cursor_screen_pos()

        local filtered = combo:filter_by_value(filter.get_input())
        local values = util_table.values_ordered(filtered, function(entry)
            return entry.value
        end)

        ---@diagnostic disable-next-line: cast-local-type
        changed, filtered_index = imgui.combo(name, filtered_index, values)

        if changed then
            selection = combo:get_index(filtered[filtered_index].key) --[[@as integer]]
            reset_state(name)
        end

        filter.draw(pos, width)
    else
        ---@diagnostic disable-next-line: cast-local-type
        changed, selection = imgui.combo(name, selection, combo.values)

        if is_combo_open(name) then
            filter.activate(name)
        end
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return changed, selection
end

return this
