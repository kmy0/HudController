local this = {}

---@type table<integer, boolean>
local disabled_stack = {}
local disabled_depth = 0
this.alpha = 0.6

---@param disabled boolean
function this.begin_disabled(disabled)
    disabled = disabled ~= false

    disabled_stack[#disabled_stack + 1] = disabled

    if disabled then
        disabled_depth = disabled_depth + 1
    end

    imgui.begin_disabled(disabled)
end

function this.end_disabled()
    imgui.end_disabled()

    local disabled = table.remove(disabled_stack)

    if disabled then
        disabled_depth = disabled_depth - 1
    end
end

---@return boolean
function this.is_disabled()
    return disabled_depth > 0
end

return this
