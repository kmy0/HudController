---@class OtomoUtil
local this = {}

---@param info app.cOtomoManageInfo
---@return Vector3f
function this.get_pos(info)
    local char = info:get_Character()
    if not char then
        return Vector3f.new(0, 0, 0)
    end

    return char:get_Pos()
end

return this
