---@class GuiState
---@field input {buf: string, type: string, key: any?}?
---@field listener NewBindListener?

---@class (exact) HudBindOpt
---@field hud integer
---@field profile integer

---@class (exact) NewBindListener
---@field opt HudBindOpt | string
---@field opt_name string
---@field listener BindListener
---@field collision string?

local util_gui = require("HudController.gui.util")

---@class GuiState
local this = {}

---@return boolean, string
function this.get_input()
    local changed = false
    changed, this.input.buf = imgui.input_text(util_gui.tr("hud.input"), this.input.buf, 1 << 6)
    return changed, this.input.buf
end

return this
