local this = {}
local buf = ""
local pos = 0

---@return string, integer
function this.get_input()
    local input = hudcontroller_util.get_input_chars()

    if #input > 0 then
        buf = buf:sub(1, pos) .. input .. buf:sub(pos + 1) --[[@as string]]
        pos = pos + #input
    end

    if imgui.is_key_pressed(imgui.ImGuiKey.Key_LeftArrow) then
        pos = math.max(pos - 1, 0)
    elseif imgui.is_key_pressed(imgui.ImGuiKey.Key_RightArrow) then
        pos = math.min(pos + 1, #buf)
    elseif imgui.is_key_pressed(imgui.ImGuiKey.Key_Backspace) then
        if pos > 0 then
            buf = buf:sub(1, pos - 1) .. buf:sub(pos + 1)
            pos = pos - 1
        end
    elseif imgui.is_key_pressed(imgui.ImGuiKey.Key_Delete) then
        if pos < #buf then
            buf = buf:sub(1, pos) .. buf:sub(pos + 2) --[[@as string]]
        end
    end

    return buf, pos
end

function this.clear()
    hudcontroller_util.reset_input()
    buf = ""
    pos = 0
end

re.on_script_reset(function()
    hudcontroller_util.reset_input()
end)

return this
