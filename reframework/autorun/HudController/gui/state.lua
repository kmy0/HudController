---@class GuiState
---@field input {buf: string, type: string, key: any?}?
---@field listener NewBindListener?

---@class (exact) NewBindListener
---@field listener BindListener
---@field collision string?

local util_gui = require("HudController.gui.util")

---@class GuiState
local this = {}

---@param draw_cancel boolean?
---@return boolean, string
function this.get_input(draw_cancel)
    draw_cancel = draw_cancel == nil or draw_cancel
    local changed = false
    changed, this.input.buf = imgui.input_text("##input", this.input.buf, 1 << 6)

    if draw_cancel then
        imgui.same_line()

        if imgui.button(util_gui.tr("hud.button_cancel", "input")) then
            this.input = nil
        end
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return changed, this.input and this.input.buf
end

return this
