local util_game = require("HudController.util.game")
local util_table = require("HudController.util.misc.table")

local this = {}

local control_type = sdk.typeof("via.gui.Control") --[[@as System.Type]]

---@param ctrl via.gui.Control
---@param chain string[] | string
---@return via.gui.Control?
function this.get(ctrl, chain)
    if type(chain) == "string" then
        chain = { chain }
    end

    ---@type via.gui.Control?
    local child = ctrl
    for i = 1, #chain do
        if not child then
            return
        end

        child = child:call("getObject(System.String, System.Type)", chain[i], control_type) --[[@as via.gui.Control?]]
    end

    return child
end

---@param ctrl via.gui.Control
---@param chain string[] | string
---@param target string
---@param lowercase boolean?
---@return via.gui.Control[]?
function this.all(ctrl, chain, target, lowercase)
    local child = this.get(ctrl, chain)
    if not child then
        return
    end

    if lowercase then
        target = target:lower() --[[@as string]]
    end

    ---@type via.gui.Control[]
    local ret = {}
    util_game.do_something(child:getChildren(control_type), function(system_array, index, candidate)
        ---@cast candidate via.gui.Control
        local candidate_name = candidate:get_Name() --[[@as string]]

        if lowercase then
            candidate_name = candidate_name:lower()
        end

        if candidate_name == target or candidate_name:find(target) then
            table.insert(ret, candidate)
        end
    end)

    if not util_table.empty(ret) then
        return ret
    end
end

---@param ctrl via.gui.Control
---@return via.gui.Control
function this.top(ctrl)
    local ret = ctrl
    local parent = ret

    while 1 do
        parent = parent:get_Parent() --[[@as via.gui.Control]]
        if not parent then
            break
        end
        ret = parent --[[@as via.gui.Control]]
    end

    return ret
end

---@overload fun(ctrl: PlayObject, parent_name: string, strict: true): via.gui.Control?
---@overload fun(ctrl: PlayObject, parent_name: string, strict: false | nil): via.gui.Control
---@param ctrl PlayObject
---@param parent_name string
---@param strict boolean
---@return via.gui.Control?
function this.get_parent(ctrl, parent_name, strict)
    local ret = ctrl
    local parent = ret

    while 1 do
        parent = parent:get_Parent() --[[@as via.gui.Control]]
        if not parent then
            break
        end

        ret = parent --[[@as via.gui.Control]]

        if ret:get_Name() == parent_name then
            break
        end
    end

    if strict and ret:get_Name() ~= parent_name then
        return
    end

    ---@cast ret via.gui.Control
    return ret
end

---@param f fun(): via.gui.Control | via.gui.Control[]?
function this.from_func(f)
    return f()
end

return this
