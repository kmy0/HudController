local ace_misc = require("HudController.util.ace.misc")
local cache = require("HudController.util.misc.cache")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local util_game = require("HudController.util.game.init")
local util_table = require("HudController.util.misc.table")

local ace_map = data.ace.map

local this = {}

local control_type = sdk.typeof("via.gui.Control") --[[@as System.Type]]
local all_cache = cache:new()

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
    ---@type string[]?, string
    local cached, key = all_cache:get_hashed(false, ctrl, chain, target, lowercase)

    if cached then
        for _, name in pairs(cached) do
            local candidate = this.get(child, name)
            if candidate then
                table.insert(ret, candidate)
            end
        end
    else
        ---@type string[]
        local names = {}
        util_game.do_something(child:getChildren(control_type), function(_, _, candidate)
            ---@cast candidate via.gui.Control
            local o_candidate_name = candidate:get_Name() --[[@as string]]
            local candidate_name = o_candidate_name
            ---@type string
            if lowercase then
                candidate_name = candidate_name:lower()
            end

            if candidate_name == target or candidate_name:find(target) then
                table.insert(ret, candidate)
                table.insert(names, o_candidate_name)
            end
        end)

        all_cache:set(key, names)
    end

    if not util_table.empty(ret) then
        return ret
    end
end

---@param ctrls via.gui.Control[]
---@param chain string[] | string
---@return via.gui.Control[]?
function this.get_from_all(ctrls, chain)
    ---@type via.gui.Control[]
    local ret = {}

    for _, ctrl in pairs(ctrls) do
        local res = this.get(ctrl, chain)
        if res then
            table.insert(ret, res)
        end
    end

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

---@overload fun(ctrl: PlayObject, parent_name: string?, strict: true): via.gui.Control?
---@overload fun(ctrl: PlayObject, parent_name: string?, strict: false | nil): via.gui.Control
---@param ctrl PlayObject
---@param parent_name string?
---@param strict boolean?
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
        if not parent_name then
            return ret
        end

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

---@param hud_id app.GUIHudDef.TYPE
---@return via.gui.Control[]
function this.get_hud_control(hud_id)
    ---@type via.gui.Control[]
    local ret = {}
    local hudman = ace_misc.get_hud_manager()
    for _, gui_id in pairs(ace_map.hudid_to_guiid[hud_id]) do
        local disp_ctrl = hudman:findDisplayControl(gui_id)
        if not disp_ctrl then
            goto continue
        end

        table.insert(ret, disp_ctrl._TargetControl)
        ::continue::
    end

    return ret
end

---@return table<app.GUIHudDef.TYPE, via.gui.Control[]>
function this.get_all_hud_control()
    ---@type table<app.GUIHudDef.TYPE, via.gui.Control[]>
    local ret = {}
    for _, hud_id in e.iter("app.GUIHudDef.TYPE") do
        local elements = this.get_hud_control(hud_id)
        if not util_table.empty(elements) then
            ret[hud_id] = elements
        end
    end

    return ret
end

return this
