local control = require("HudController.hud.play_object.control")
local util_table = require("HudController.util.misc.table")

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

---@generic T
---@param ctrl via.gui.Control
---@param regex string?
---@param child_type `T`
---@return T[]
function this.all_type(ctrl, regex, child_type)
    local ret = {}

    local child = ctrl:get_Child()
    while child do
        local type = child:get_type_definition() --[[@as RETypeDefinition]]

        if type:is_a(child_type) and (not regex or regex and string.match(child:get_Name(), regex)) then
            table.insert(ret, child)
        elseif type:is_a("via.gui.Control") then
            ---@cast child via.gui.Control
            util_table.array_merge_t(ret, this.all_type(child, regex, child_type))
        end

        child = child:get_Next()
    end

    return ret
end

return this
