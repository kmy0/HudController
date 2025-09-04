---@class (exact) Scale9 : CtrlChild
---@field ignore_alpha boolean?
---@field control_point via.gui.ControlPoint?
---@field blend via.gui.BlendType?
---@field alpha_channel via.gui.AlphaChannelType?
---@field properties Scale9Properties
---@field default_overwrite Scale9DefaultOverwrite
---@field ctrl_getter fun(self: Scale9, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Scale9Grid | via.gui.Scale9Grid[]?
---@field reset fun(self: Scale9, key: Scale9WriteKey)
---@field mark_write fun(self: Scale9, key: Scale9Property)
---@field mark_idle fun(self: Scale9, key: Scale9Property)

---@class (exact) Scale9Config : CtrlChildConfig
---@field hud_sub_type HudSubType
---@field enabled_ignore_alpha boolean?
---@field ignore_alpha boolean?
---@field enabled_control_point boolean?
---@field control_point string?
---@field enabled_blend boolean?
---@field blend string?
---@field enabled_alpha_channel boolean?
---@field alpha_channel string?

---@class (exact) Scale9Default : CtrlChildDefault
---@field ignore_alpha boolean
---@field control_point via.gui.ControlPoint
---@field blend via.gui.BlendType
---@field alpha_channel via.gui.AlphaChannelType

---@class (exact) Scale9DefaultOverwrite : CtrlChildDefaultOverwite
---@field ignore_alpha boolean?
---@field control_point via.gui.ControlPoint?
---@field blend via.gui.BlendType?
---@field alpha_channel via.gui.AlphaChannelType?

---@class (exact) Scale9ChangedProperties : CtrlChildChangedProperties
---@field ignore_alpha boolean?
---@field control_point via.gui.ControlPoint?
---@field blend via.gui.BlendType?

---@class (exact) Scale9Properties : {[Scale9Property]: boolean}, CtrlChildProperties
---@field ignore_alpha boolean
---@field control_point boolean
---@field blend boolean

---@alias Scale9Property CtrlChildProperty | "ignore_alpha" | "control_point" | "blend" | "alpha_channel"
---@alias Scale9WriteKey CtrlChildWriteKey | Scale9Property

local ctrl_child = require("HudController.hud.def.ctrl_child")
local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local play_object_defaults = require("HudController.hud.defaults.play_object")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

---@class Scale9
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = ctrl_child })

---@param args Scale9Config
---@param parent HudBase
---@param ctrl_getter fun(self: Scale9, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Scale9Grid | via.gui.Scale9Grid[]?
---@param ctrl_writer (fun(self: HudChild, ctrl: via.gui.Scale9Grid): boolean)?
---@param default_overwrite Scale9DefaultOverwrite?
---@param gui_ignore boolean?
---@return Scale9
function this:new(args, parent, ctrl_getter, ctrl_writer, default_overwrite, gui_ignore)
    local o = ctrl_child.new(self, args, parent, ctrl_getter, ctrl_writer, default_overwrite, gui_ignore)
    o.properties = util_table.merge_t(o.properties, {
        ignore_alpha = true,
        control_point = true,
        blend = true,
        alpha_channel = true,
    })

    setmetatable(o, self)
    ---@cast o Scale9

    if args.enabled_control_point then
        o:set_control_point(args.control_point)
    end

    if args.enabled_blend then
        o:set_blend(args.blend)
    end

    if args.enabled_ignore_alpha then
        o:set_ignore_alpha(args.ignore_alpha)
    end

    if args.enabled_alpha_channel then
        o:set_alpha_channel(args.alpha_channel)
    end

    return o
end

---@param alpha_channel string?
function this:set_alpha_channel(alpha_channel)
    if alpha_channel then
        self:mark_write("alpha_channel")
        self.alpha_channel = rl(ace_enum.alpha_channel, alpha_channel)
    else
        self:reset("alpha_channel")
        self.color = alpha_channel
        self:mark_idle("alpha_channel")
    end
end

---@param control_point string?
function this:set_control_point(control_point)
    if control_point then
        self:mark_write("control_point")
        self.control_point = rl(ace_enum.control_point, control_point)
    else
        self:reset("control_point")
        self.color = control_point
        self:mark_idle("control_point")
    end
end

---@param blend string?
function this:set_blend(blend)
    if blend then
        self:mark_write("blend")
        self.blend = rl(ace_enum.blend, blend)
    else
        self:reset("blend")
        self.color = blend
        self:mark_idle("blend")
    end
end

---@param ignore_alpha boolean?
function this:set_ignore_alpha(ignore_alpha)
    if ignore_alpha ~= nil then
        self:mark_write("ignore_alpha")
        self.ignore_alpha = ignore_alpha
    else
        self:reset("ignore_alpha")
        self.ignore_alpha = ignore_alpha
        self:mark_idle("ignore_alpha")
    end
end

---@param obj via.gui.Scale9Grid
---@param key Scale9WriteKey
function this:reset_ctrl(obj, key)
    local default = play_object_defaults.get_default(obj) --[[@as Scale9Default]]
    if default then
        default = util_table.merge_t(default, self.default_overwrite or {}) --[[@as Scale9Default]]
    else
        default = (self.default_overwrite or {}) --[[@as Scale9Default]]
    end

    if self.control_point and not key or key == "control_point" and default.control_point then
        obj:set_ControlPoint(default.control_point)
    end

    if self.blend and not key or key == "blend" and default.blend then
        obj:set_BlendType(default.blend)
    end

    if self.ignore_alpha ~= nil and not key or key == "ignore_alpha" and default.ignore_alpha ~= nil then
        obj:set_IgnoreAlpha(default.ignore_alpha)
    end

    if self.alpha_channel and not key or key == "alpha_channel" and default.alpha_channel then
        obj:set_AlphaChannelType(default.alpha_channel)
    end

    ---@cast key CtrlChildProperty
    ctrl_child.reset_ctrl(self, obj, key)
end

---@protected
---@param obj via.gui.Scale9Grid
---@return boolean
function this:_write(obj)
    if not ctrl_child._write(self, obj) then
        return false
    end

    if self.control_point then
        obj:set_ControlPoint(self.control_point)
    end

    if self.blend then
        obj:set_BlendType(self.blend)
    end

    if self.ignore_alpha then
        obj:set_IgnoreAlpha(self.ignore_alpha)
    end

    if self.alpha_channel then
        obj:set_AlphaChannelType(self.alpha_channel)
    end

    return true
end

return this
