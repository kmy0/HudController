---@class (exact) MaterialVariable
---@field type string
---@field value any
---@field name string
---@field func_name string

local e = require("HudController.util.game.enum")
local util_ref = require("HudController.util.ref.init")

local this = {
    map = {
        type_to_func = {
            Float = "get_VariableFloat%s",
            Float4 = "get_VariableVec%s",
            Color = "get_VariableColor%s",
            Texture = "get_VariableTexture%s",
        },
    },
}
local material_map = {
    name = {
        struct_size = 0x20,
        length_offset = 0x18,
    },
    type = {
        struct_size = 1,
    },
    var0_name_offset = 0xD8,
    var0_type_offset = 0x1D8,
}

---@param obj via.gui.Material
---@return MaterialVariable[]
function this.get_variables(obj)
    ---@type MaterialVariable[]
    local ret = {}
    local param_count = obj:get_MaterialParamsCount()
    local address = obj:get_address()
    local offset_name = material_map.var0_name_offset
    local offset_type = material_map.var0_type_offset

    local s = util_ref.ctor("System.String") --[[@as System.String]]
    for i = 1, param_count do
        ---@class MaterialVariable
        local struct = {}
        local string_start = offset_name + (i - 1) * material_map.name.struct_size
        local type_offset = offset_type + (i - 1) * material_map.type.struct_size
        local type = e.get("via.gui.Material.ParamType")[obj:read_byte(type_offset)]

        s._stringLength = obj:read_byte(string_start + material_map.name.length_offset)
        s._firstChar = sdk.to_valuetype(address + string_start, "System.Char") --[[@as System.Char]]

        struct.name = s:ToString()
        struct.func_name = this.map.type_to_func[type]:format(i - 1)
        struct.type = type

        if type == "Float" then
            struct.value = obj:call(struct.func_name)
        elseif type == "Float4" then
            local res = obj:call(struct.func_name) --[[@as via.Float4]]
            struct.value = { x = res.x, y = res.y, z = res.z, w = res.w }
        elseif type == "Color" then
            local res = obj:call(struct.func_name) --[[@as via.Color]]
            struct.value = res.rgba
        end

        table.insert(ret, struct)
    end

    return ret
end

return this
