local s = require("HudController.util.ref.singletons")
local util_misc = require("HudController.util.misc")
local util_ref = require("HudController.util.ref")

local this = {}

---@return System.Single
function this.get_time_delta()
    return s.get_native("via.Application"):get_DeltaTime() / 60
end

---@return via.Scene
function this.get_scene()
    return s.get_native("via.SceneManager"):get_CurrentScene()
end

---@return via.SceneView
function this.get_main_view()
    return s.get_native("via.SceneManager"):get_MainView()
end

---@return {x: number, y:number}
function this.get_screen_size()
    local size = this.get_main_view():get_WindowSize()
    return { x = size.w, y = size.h }
end

---@param guid System.Guid
---@return string
function this.format_guid(guid)
    return string.format(
        "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
        guid.mData1,
        guid.mData2,
        guid.mData3,
        guid.mData4_0,
        guid.mData4_1,
        guid.mData4_2,
        guid.mData4_3,
        guid.mData4_4,
        guid.mData4_5,
        guid.mData4_6,
        guid.mData4_7
    )
end

---@generic T
---@param type `T`?
---@return System.Array<T>
function this.get_all_components(type)
    if not type then
        type = "via.Transform"
    end
    return this.get_scene():call("findComponents(System.Type)", sdk.typeof(type))
end

---@param game_object via.GameObject
---@param type_name string
---@return REManagedObject?
function this.get_component(game_object, type_name)
    local t = sdk.typeof(type_name)

    if not t then
        return
    end

    return game_object:call("getComponent(System.Type)", t)
end

---@param game_object via.GameObject
---@param type_name string
---@return System.Array<REManagedObject>?
function this.get_components(game_object, type_name)
    local t = sdk.typeof(type_name)

    if not t then
        return
    end

    return game_object:call("findComponents(System.Type)", t)
end

---@generic T
---@param system_array System.Array<T>
---@return T[]
function this.system_array_to_lua(system_array)
    local ret = {}
    local enum = this.get_array_enum(system_array)

    while enum:MoveNext() do
        table.insert(ret, enum:get_Current())
    end
    return ret
end

---@generic T
---@param array System.Array<T>
---@return System.ArrayEnumerator<T>
function this.get_array_enum(array)
    ---@type System.ArrayEnumerator
    local enum
    local arr = array

    util_misc.try(function()
        arr = array:ToArray()
    end)

    if not util_misc.try(function()
        enum = arr:GetEnumerator()
    end) then
        enum = util_ref.ctor("System.ArrayEnumerator", true)
        enum:call(".ctor", arr)
    end
    return enum
end

---@param obj REManagedObject
---@return boolean
function this.is_only_my_ref(obj)
    if obj:read_qword(0x8) <= 0 then
        return true
    end

    local gameobject_addr = obj:read_qword(0x10)
    if gameobject_addr == 0 or not sdk.is_managed_object(gameobject_addr) then
        return true
    end

    return false
end

---@generic T
---@param system_array T[]
---@param something fun(system_array: System.Array<T>, index: integer, value: T): boolean?
---@param reverse boolean?
function this.do_something(system_array, something, reverse)
    ---@diagnostic disable-next-line: undefined-field, no-unknown
    local size = system_array:get_Count() - 1
    if reverse then
        for i = size, 0, -1 do
            ---@diagnostic disable-next-line: undefined-field
            if something(system_array, i, system_array:get_Item(i)) == false then
                break
            end
        end
    else
        for i = 0, size do
            ---@diagnostic disable-next-line: undefined-field
            if something(system_array, i, system_array:get_Item(i)) == false then
                break
            end
        end
    end
end

return this
