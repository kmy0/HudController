local control = require("HudController.hud.play_object.control")

local this = {}

---@generic T
---@param ctrl via.gui.Control
---@param chain string[] | string
---@param child_name string
---@param child_type `T`
---@return T?
function this.get(ctrl, chain, child_name, child_type)
    local o = control.get(ctrl, chain)
    if not o then
        return
    end

    return o:call("getObject(System.String, System.Type)", child_name, sdk.typeof(child_type)) --[[@as REManagedObject?]]
end

return this
