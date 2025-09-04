---@class (exact) CtrlChild : HudChild
---@field scale {x: number, y: number}?
---@field color via.Color?
---@field size_x number?
---@field size_y number?
---@field last_known {
--- size: {x: number, y: number}?,
--- }
---@field last_change {
--- size: {x: number, y: number}?,
--- }
---@field children {}
---@field properties CtrlChildProperties
---@field default_overwrite CtrlChildDefaultOverwite
---@field ctrl_getter fun(self: CtrlChild, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): ControlChild | ControlChild[]?
---@field protected _ctrl_grouper fun(self: CtrlChild): ControlChild[]
---@field reset fun(self: CtrlChild, key: CtrlChildWriteKey)
---@field mark_write fun(self: CtrlChild, key: CtrlChildProperty)
---@field mark_idle fun(self: CtrlChild, key: CtrlChildProperty)

---@class (exact) CtrlChildConfig : HudChildConfig
---@field name_key string
---@field hud_sub_type HudSubType?
---@field scale {x:number, y:number}?
---@field offset {x:number, y:number}?
---@field rot number?
---@field color integer?
---@field size_x number?
---@field size_y number?
---@field opacity nil
---@field hide boolean?
---@field enabled_scale boolean?
---@field enabled_offset boolean?
---@field enabled_rot boolean?
---@field enabled_color boolean?
---@field enabled_size_x boolean?
---@field enabled_size_y boolean?
---@field enabled_opacity nil

---@class (exact) CtrlChildDefault : HudChildDefault
---@field scale {x:number, y:number}
---@field offset {x:number, y:number}
---@field rot number
---@field hide boolean
---@field color integer
---@field opacity nil
---@field play_state nil
---@field color_scale nil

---@class (exact) CtrlChildDefaultOverwite : HudChildDefaultOverwrite
---@field color integer?
---@field opacity nil
---@field play_state nil
---@field color_scale nil

---@class (exact) CtrlChildChangedProperties : HudChildChangedProperties
---@field scale Vector3f?
---@field offset Vector3f?
---@field rot Vector3f?
---@field hide boolean?
---@field color via.Color?
---@field size_x number?
---@field size_y number?

---@class (exact) CtrlChildProperties : {[CtrlChildProperty]: boolean}, HudChildProperties
---@field scale boolean
---@field offset boolean
---@field rot boolean
---@field hide boolean
---@field color boolean
---@field size_x boolean
---@field size_y boolean
---@field opacity nil
---@field color_scale nil
---@field play_state nil

---@alias CtrlChildProperty "scale" | "offset" | "rot" | "hide" | "color" | "size_x" | "size_y"
---@alias CtrlChildWriteKey CtrlChildProperty | "dummy"?

local hud_child = require("HudController.hud.def.hud_child")
local play_object_defualts = require("HudController.hud.defaults.play_object")
local util_ref = require("HudController.util.ref")
local util_table = require("HudController.util.misc.table")

---@class CtrlChild
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

---@param args CtrlChildConfig
---@param parent HudBase
---@param ctrl_getter fun(self: CtrlChild, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): ControlChild | ControlChild[]?
---@param ctrl_writer (fun(self: CtrlChild, ctrl: ControlChild): boolean)?
---@param default_overwrite CtrlChildDefaultOverwite?
---@param gui_ignore boolean?
---@param children_sort (fun(a_key: string, b_key: string): boolean)?
---@param no_cache boolean? by_default, false
---@return CtrlChild
function this:new(args, parent, ctrl_getter, ctrl_writer, default_overwrite, gui_ignore, children_sort, no_cache)
    local o = hud_child.new(
        self,
        args,
        parent,
        ctrl_getter,
        ctrl_writer,
        default_overwrite,
        gui_ignore,
        children_sort,
        no_cache
    )
    setmetatable(o, self)
    ---@cast o CtrlChild

    o.properties = {
        scale = true,
        rot = true,
        hide = true,
        offset = true,
        color = true,
        size_x = true,
        size_y = true,
    }
    o.last_known = {}
    o.last_change = {}

    if args.enabled_color then
        o:set_color(args.color)
    end

    if args.enabled_size_x then
        o:set_size_x(args.size_x)
    end

    if args.enabled_size_y then
        o:set_size_y(args.size_y)
    end

    return o
end

---@param scale {x:number, y:number}?
function this:set_scale(scale)
    if scale then
        self.scale = scale
        self:mark_write("scale")
    else
        self:reset("scale")
        self.scale = scale
        self:mark_idle("scale")
    end
end

---@param size_x number?
function this:set_size_x(size_x)
    if size_x then
        self.size_x = size_x
        self:mark_write("size_x")
    else
        self:reset("size_x")
        self.size_x = size_x
        self:mark_idle("size_x")
    end
end

---@param size_y number?
function this:set_size_y(size_y)
    if size_y then
        self.size_y = size_y
        self:mark_write("size_y")
    else
        self:reset("size_y")
        self.size_y = size_y
        self:mark_idle("size_y")
    end
end

---@param color integer?
function this:set_color(color)
    if color then
        self:mark_write("color")
        self.color = util_ref.value_type("via.Color")
        self.color.rgba = color
    else
        self:reset("color")
        self.color = color
        self:mark_idle("color")
    end
end

---@param obj ControlChild
---@param key CtrlChildWriteKey
function this:reset_ctrl(obj, key)
    local default = play_object_defualts.get_default(obj) --[[@as CtrlChildDefault]]
    if default then
        default = util_table.merge_t(default, self.default_overwrite or {})
    else
        ---@diagnostic disable-next-line: cast-local-type
        default = self.default_overwrite or {} --[[@as CtrlChildDefaultOverwite]]
    end

    if self.hide and (not key or key == "hide") and default.hide ~= nil then
        obj:set_ForceInvisible(default.hide)
    end

    if
        (
            (self.scale and (not key or key == "scale"))
            or (self.size_x and (not key or key == "size_x"))
            or (self.size_y and (not key or key == "size_y"))
        ) and default.scale
    then
        local size = self:_get_size(obj)
        size.w, size.h = default.scale.x, default.scale.y
        self:_set_size(obj, size)
    end

    if self.color and not key or key == "color" and default.color then
        local color = util_ref.value_type("via.Color")
        color.rgba = default.color
        obj:set_Color(color)
    end

    if self.offset and (not key or key == "offset") and default.offset then
        obj:set_Position(Vector3f.new(default.offset.x, default.offset.y, 0))
    end

    if self.rot and (not key or key == "rot") and default.rot then
        obj:set_Rotation(Vector3f.new(0, 0, default.rot))
    end

    if not key then
        self:reset_options()
    end
end

---@protected
---@param obj ControlChild
---@param size via.Size
---@param x number?
---@param y number?
function this:_set_size(obj, size, x, y)
    size.w = x or size.w
    size.h = y or size.h

    if obj:get_type_definition():is_a("via.gui.Text") then
        ---@cast obj via.gui.Text
        obj:set_FontSize(size)
        return
    end
    ---@cast obj via.gui.Material
    obj:set_Size(size)
end

---@protected
---@param obj ControlChild
---@return via.Size
function this:_get_size(obj)
    if obj:get_type_definition():is_a("via.gui.Text") then
        ---@cast obj via.gui.Text
        return obj:get_FontSize()
    end
    ---@cast obj via.gui.Material
    return obj:get_Size()
end

---@protected
---@param obj ControlChild
---@return via.Size
function this:_get_size_scale(obj)
    local size = self:_get_size(obj)

    if
        not self.last_change.size
        or math.abs(self.last_change.size.x - size.w) > 1e-2
        or math.abs(self.last_change.size.y - size.h) > 1e-2
    then
        self.last_known.size = { x = size.w, y = size.h }
    end

    size.w = self.last_known.size.x * self.scale.x
    size.h = self.last_known.size.y * self.scale.y
    self.last_change.size = { x = size.w, y = size.h }
    return size
end

---@protected
---@param obj ControlChild
---@return boolean
function this:_write(obj)
    play_object_defualts.check(obj)

    if self.hide then
        obj:set_ForceInvisible(self.hide)

        return false
    end

    if self.color then
        obj:set_Color(self.color)
    end

    if self.offset then
        obj:set_Position(self.offset)
    end

    if self.rot then
        obj:set_Rotation(self.rot)
    end

    if self.size_x or self.size_y then
        self:_set_size(obj, self:_get_size(obj), self.size_x, self.size_y)
    end

    if self.scale then
        self:_set_size(obj, self:_get_size_scale(obj))
    end

    return true
end

return this
