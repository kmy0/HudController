local this = {}

---@type number[]
local alpha_stack = {}
local current_alpha = 1.0

---@param alpha number
function this.push(alpha)
    alpha_stack[#alpha_stack + 1] = current_alpha
    current_alpha = alpha
    imgui.push_style_var(imgui.ImGuiStyleVar.Alpha, alpha)
end

function this.pop()
    imgui.pop_style_var(1)
    current_alpha = table.remove(alpha_stack) or 1.0
end

function this.get()
    return current_alpha
end

return this
