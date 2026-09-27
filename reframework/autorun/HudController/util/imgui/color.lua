local alpha = require("HudController.util.imgui.alpha")
local disabled = require("HudController.util.imgui.disabled")

local this = {}

---@param color integer
---@param multiplier? number
---@return integer
function this.with_alpha(color, multiplier)
    local a = (color >> 24) & 0xFF

    local final_alpha = alpha.get()

    if disabled.is_disabled() then
        final_alpha = final_alpha * disabled.alpha
    end

    if multiplier then
        final_alpha = final_alpha * multiplier
    end

    a = math.floor(a * final_alpha + 0.5)
    a = math.max(0, math.min(255, a))

    return (color & 0x00FFFFFF) | (a << 24)
end

return this
