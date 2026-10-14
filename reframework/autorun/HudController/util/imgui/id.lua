local this = {}
local id = 0

---@return string
function this.get()
    id = id + 1
    return tostring(id)
end

re.on_draw_ui(function()
    id = 0
end)

return this
