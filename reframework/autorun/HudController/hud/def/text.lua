---@class (exact) Text : CtrlChild
---@field hide_glow boolean?
---@field glow_color via.Color?
---@field font_size via.Size?
---@field properties TextProperties
---@field default_overwrite TextDefaultOverwrite
---@field ctrl_getter fun(self: Text, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Text| via.gui.Text[]?
---@field reset fun(self: Text, key: TextWriteKey)

---@class (exact) TextConfig : CtrlChildConfig
---@field hud_sub_type HudSubType
---@field hide_glow boolean?
---@field enabled_glow_color boolean?
---@field glow_color integer?
---@field enabled_font_size boolean?
---@field font_size integer?

---@class (exact) TextDefault : CtrlChildDefault
---@field hide_glow boolean
---@field glow_color integer
---@field font_size integer

---@class (exact) TextDefaultOverwrite : CtrlChildDefaultOverwite
---@field hide_glow boolean?
---@field glow_color integer?
---@field font_size integer?

---@class (exact) TextChangedProperties : CtrlChildChangedProperties
---@field hide_glow boolean?
---@field glow_color integer?
---@field font_size integer?

---@class (exact) TextProperties : {[TextProperty]: boolean}, CtrlChildProperties
---@field hide_glow boolean
---@field glow_color boolean
---@field font_size boolean

---@alias TextProperty CtrlChildProperty | "hide_glow" | "glow_color" | "font_size"
---@alias TextWriteKey CtrlChildWriteKey | TextProperty

local ctrl_child = require("HudController.hud.def.ctrl_child")
local play_object = require("HudController.hud.play_object")
local util_ref = require("HudController.util.ref")
local util_table = require("HudController.util.misc.table")

---@class Text
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = ctrl_child })

---@param args TextConfig
---@param parent HudBase
---@param ctrl_getter fun(self: Text, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Text | via.gui.Text[]?
---@param ctrl_writer (fun(self: HudChild, ctrl: via.gui.Text): boolean)?
---@param default_overwrite TextDefaultOverwrite?
---@param ignore boolean?
---@return Text
function this:new(args, parent, ctrl_getter, ctrl_writer, default_overwrite, ignore)
    local o = ctrl_child.new(self, args, parent, ctrl_getter, ctrl_writer, default_overwrite, ignore)
    o.properties = util_table.merge_t(o.properties, {
        hide_glow = true,
        glow_color = true,
        font_size = true,
    })

    setmetatable(o, self)
    ---@cast o Text

    if args.hide_glow then
        o:set_hide_glow(args.hide_glow)
    end

    if args.enabled_glow_color then
        o:set_glow_color(args.glow_color)
    end

    if args.enabled_font_size then
        o:set_font_size(args.font_size)
    end

    return o
end

---@param hide_glow boolean
function this:set_hide_glow(hide_glow)
    self:reset("hide_glow")

    if self.hide_glow and not hide_glow then
        self:mark_idle()
    elseif not self.hide_glow and hide_glow then
        self:mark_write()
    end
    self.hide_glow = hide_glow
end

---@param color integer?
function this:set_glow_color(color)
    if color then
        self:mark_write()
        self.glow_color = util_ref.value_type("via.Color")
        self.glow_color.rgba = color
    else
        self:reset("glow_color")
        self.glow_color = color
        self:mark_idle()
    end
end

---@param size integer?
function this:set_font_size(size)
    if size then
        self:mark_write()
        self.font_size = util_ref.value_type("via.Size")
        self.font_size.w = size
        self.font_size.h = size
    else
        self:reset("font_size")
        self.font_size = size
        self:mark_idle()
    end
end

---@param obj via.gui.Text
---@param key TextWriteKey
function this:reset_ctrl(obj, key)
    local default = play_object.default.get_default(obj) --[[@as TextDefault]]
    if default then
        default = util_table.merge_t(default, self.default_overwrite or {}) --[[@as TextDefault]]
    else
        default = (self.default_overwrite or {}) --[[@as TextDefault]]
    end

    if self.hide_glow and not key or key == "hide_glow" and default.hide_glow then
        obj:set_GlowEnable(not default.hide_glow)
    end

    if self.glow_color and not key or key == "glow_color" and default.glow_color then
        local color = util_ref.value_type("via.Color")
        color.rgba = default.glow_color
        obj:set_GlowColor(color)
    end

    if self.font_size and not key or key == "font_size" and default.scale then
        local font_size = util_ref.value_type("via.Size")
        font_size.w = default.scale.x
        font_size.h = default.scale.x
        obj:set_FontSize(font_size)
    end

    ---@cast key CtrlChildProperty
    ctrl_child.reset_ctrl(self, obj, key)
end

---@protected
---@param obj via.gui.Text
---@return boolean
function this:_write(obj)
    if not ctrl_child._write(self, obj) then
        return false
    end

    if self.hide_glow then
        obj:set_GlowEnable(false)
    end

    if self.glow_color then
        obj:set_GlowColor(self.glow_color)
    end

    if self.font_size then
        obj:set_FontSize(self.font_size)
    end

    return true
end

return this
