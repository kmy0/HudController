---@class (exact) Material : CtrlChild
---@field var0 number?
---@field var1 number?
---@field var2 number?
---@field var3 number?
---@field var4 number?
---@field last_known {
--- size: {x: number, y: number}?,
--- var0: number?,
--- var1: number?,
--- var2: number?,
--- var3: number?,
--- var4: number?,
--- }
---@field last_change {
--- size: {x: number, y: number}?,
--- var0: number?,
--- var1: number?,
--- var2: number?,
--- var3: number?,
--- var4: number?,
--- }
---@field properties MaterialProperties
---@field default_overwrite MaterialDefaultOverwrite
---@field ctrl_getter fun(self: Material, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Material | via.gui.Material[]?
---@field reset fun(self: Material, key: MaterialWriteKey)
---@field mark_write fun(self: Material, key: MaterialProperty)
---@field mark_idle fun(self: Material, key: MaterialProperty)

---@class (exact) MaterialConfig : CtrlChildConfig
---@field hud_sub_type HudSubType
---@field enabled_var0 boolean?
---@field enabled_var1 boolean?
---@field enabled_var2 boolean?
---@field enabled_var3 boolean?
---@field enabled_var4 boolean?
---@field var0 MaterialVarFloat?
---@field var1 MaterialVarFloat?
---@field var2 MaterialVarFloat?
---@field var3 MaterialVarFloat?
---@field var4 MaterialVarFloat?

---@class (exact) MaterialVarFloat
---@field name_key string
---@field value number

---@class (exact) MaterialDefault : CtrlChildDefault
---@field var_float {var0: number, var1: number, var2: number, var3: number, var4: number}

---@class (exact) MaterialDefaultOverwrite : CtrlChildDefaultOverwite
---@field var_float {var0: number?, var1: number?, var2: number?, var3: number?, var4: number?}?

---@class (exact) MaterialChangedProperties : CtrlChildChangedProperties
---@field var0 number?
---@field var1 number?
---@field var2 number?
---@field var3 number?
---@field var4 number?

---@class (exact) MaterialProperties : {[MaterialProperty]: boolean}, HudBaseProperties
---@field var0 boolean
---@field var1 boolean
---@field var2 boolean
---@field var3 boolean
---@field var4 boolean

---@alias MaterialProperty CtrlChildProperty | "var0" | "var1" | "var2" | "var3" | "var4"
---@alias MaterialWriteKey CtrlChildWriteKey | MaterialProperty

local ctrl_child = require("HudController.hud.def.ctrl_child")
local play_object_defaults = require("HudController.hud.defaults.init").play_object
local util_table = require("HudController.util.misc.table")

---@class Material
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = ctrl_child })

---@param args MaterialConfig
---@param parent HudBase
---@param ctrl_getter (fun(self: Material, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Material | via.gui.Material[]?)?
---@param ctrl_writer (fun(self: Material, ctrl: via.gui.Material): boolean)? when set, ctrl_writer is used instead of hud_base._write
---@param default_overwrite MaterialDefaultOverwrite?
---@param gui_ignore boolean? by_default, false - if true, do not draw in imgui window
---@param children_sort (fun(a_key: string, b_key: string): boolean)? children iteration order
---@param no_cache boolean? by_default, false - if true cache via.gui.Control objects
---@param valid_guiid (app.GUIID.ID | app.GUIID.ID[])? when set, ctrl_getter ignores all guiids except these
---@return Material
function this:new(
    args,
    parent,
    ctrl_getter,
    ctrl_writer,
    default_overwrite,
    gui_ignore,
    children_sort,
    no_cache,
    valid_guiid
)
    local o = ctrl_child.new(
        self,
        args,
        parent,
        ctrl_getter,
        ctrl_writer,
        default_overwrite,
        gui_ignore,
        children_sort,
        no_cache,
        valid_guiid
    )
    o.properties = util_table.merge_t(o.properties, {
        var0 = true,
        var1 = true,
        var2 = true,
        var3 = true,
        var4 = true,
    })

    setmetatable(o, self)
    ---@cast o Material

    if args.enabled_var0 then
        o:set_var(args.var0.value, "var0")
    end

    if args.enabled_var1 then
        o:set_var(args.var1.value, "var1")
    end

    if args.enabled_var2 then
        o:set_var(args.var2.value, "var2")
    end

    if args.enabled_var3 then
        o:set_var(args.var3.value, "var3")
    end

    if args.enabled_var4 then
        o:set_var(args.var4.value, "var4")
    end

    return o
end

---@param val number?
---@param key MaterialProperty
function this:set_var(val, key)
    if val then
        self:mark_write(key)
    else
        self:reset(key)
        self:mark_idle(key)
    end
    ---@diagnostic disable-next-line: no-unknown
    self[key] = val
end

---@param obj via.gui.Material
---@param key MaterialWriteKey
function this:reset_ctrl(obj, key)
    local default = play_object_defaults:get(obj) --[[@as MaterialDefault]]
    if default then
        default = util_table.merge_t(default, self.default_overwrite or {})
    else
        default = (self.default_overwrite or {}) --[[@as MaterialDefault]]
    end

    if default.var_float then
        if self.var0 and (not key or key == "var0") and default.var_float.var0 then
            obj:set_VariableFloat0(default.var_float.var0)
            self.last_change.var0 = nil
            self.last_known.var0 = nil
        end

        if self.var1 and (not key or key == "var1") and default.var_float.var1 then
            obj:set_VariableFloat1(default.var_float.var1)
            self.last_change.var1 = nil
            self.last_known.var1 = nil
        end

        if self.var2 and (not key or key == "var2") and default.var_float.var2 then
            obj:set_VariableFloat2(default.var_float.var2)
            self.last_change.var2 = nil
            self.last_known.var2 = nil
        end

        if self.var3 and (not key or key == "var3") and default.var_float.var3 then
            obj:set_VariableFloat3(default.var_float.var3)
            self.last_change.var3 = nil
            self.last_known.var3 = nil
        end

        if self.var4 and (not key or key == "var4") and default.var_float.var4 then
            obj:set_VariableFloat4(default.var_float.var4)
            self.last_change.var4 = nil
            self.last_known.var4 = nil
        end
    end

    ---@cast key CtrlChildProperty
    ctrl_child.reset_ctrl(self, obj, key)
end

---@protected
---@param key MaterialProperty
---@param value number
function this:_get_var(key, value)
    if not self.last_change[key] or math.abs(self.last_change[key] - value) > 1e-2 then
        ---@diagnostic disable-next-line: no-unknown
        self.last_known[key] = value
    end

    ---@diagnostic disable-next-line: no-unknown
    self.last_change[key] = self.last_known[key] * self[key]
    return self.last_change[key]
end

---@protected
---@param obj via.gui.Material
---@return boolean
function this:_write(obj)
    if not ctrl_child._write(self, obj) then
        return false
    end

    if self.var0 then
        obj:set_VariableFloat0(self:_get_var("var0", obj:get_VariableFloat0()))
    end

    if self.var1 then
        obj:set_VariableFloat1(self:_get_var("var1", obj:get_VariableFloat1()))
    end

    if self.var2 then
        obj:set_VariableFloat2(self:_get_var("var2", obj:get_VariableFloat2()))
    end

    if self.var3 then
        obj:set_VariableFloat3(self:_get_var("var3", obj:get_VariableFloat3()))
    end

    if self.var4 then
        obj:set_VariableFloat4(self:_get_var("var4", obj:get_VariableFloat4()))
    end

    return true
end

return this
