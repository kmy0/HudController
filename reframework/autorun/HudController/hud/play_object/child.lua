local cache = require("HudController.util.misc.cache")
local control = require("HudController.hud.play_object.control")
local util_table = require("HudController.util.misc.table")

local this = {}
local all_cache = cache:new()

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

    ---@type [via.gui.Control, string[], string, string][]?, string
    local cached, key = all_cache:get_hashed(false, ctrl, regex, child_type)

    if cached then
        for _, arg in pairs(cached) do
            local candidate = this.get(table.unpack(arg))
            if candidate then
                table.insert(ret, candidate)
            end
        end
    else
        local args = {}

        ---@param ctrl via.gui.Control
        ---@param arg [via.gui.Control, string[], string, string]
        local function iter(ctrl, arg)
            local child = ctrl:get_Child()
            while child do
                local type = child:get_type_definition() --[[@as RETypeDefinition]]

                if type:is_a(child_type) and (not regex or regex and string.match(child:get_Name(), regex)) then
                    table.insert(ret, child)
                    local _arg = util_table.deep_copy(arg)
                    _arg[3] = child:get_Name()
                    table.insert(args, _arg)
                elseif type:is_a("via.gui.Control") then
                    ---@cast child via.gui.Control
                    local _arg = util_table.deep_copy(arg)
                    table.insert(_arg[2], child:get_Name())
                    iter(child, _arg)
                end

                child = child:get_Next()
            end
        end

        iter(ctrl, { ctrl, {}, "placeholder", child_type })
        all_cache:set(key, args)
    end

    return ret
end

return this
