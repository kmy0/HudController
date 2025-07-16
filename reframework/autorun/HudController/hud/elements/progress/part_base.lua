---@class (exact) ProgressPartBase : HudChild
---@field offset_x number?
---@field clock_offset_x number?
---@field root Progress
---@field ctrl_getter fun(self: ProgressPartBase, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?
---@field ctrl_writer (fun(self: ProgressPartBase, ctrl: via.gui.Control): boolean)?
---@field get_config fun(name_key: string): ProgressPartBaseConfig

---@class (exact) ProgressPartBaseConfig : HudChildConfig
---@field offset_x number?
---@field enabled_offset_x boolean?
---@field clock_offset_x number?
---@field enabled_clock_offset_x boolean?

---@class (exact) ProgressPartBaseDefault: HudChildDefault
---@field offset_x number
---@field clock_offset_x number

---@class (exact) ProgressPartBaseDefaultOverwrite : HudChildDefaultOverwrite
---@field offset_x number?
---@field clock_offset_x number?

---@class (exact) ProgressPartBaseChangedProperties : HudChildChangedProperties
---@field offset_x number?
---@field clock_offset_x number?

---@class (exact) ProgressPartBaseProperties : {[ProgressPartBaseProperty]: boolean}, HudChildProperties
---@field offset_x boolean
---@field clock_offset_x boolean

---@alias ProgressPartBaseProperty "offset_x" | "clock_offset_x"
---@alias ProgressPartBaseWriteKey ProgressPartBaseProperty | HudChildProperties

local data = require("HudController.data")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local util_table = require("HudController.util.misc.table")
---@class MethodUtil
local m = require("HudController.util.ref.methods")

local mod = data.mod

---@class ProgressPartBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

---@param args ProgressPartBaseConfig
---@param parent HudBase
---@param ctrl_getter fun(self: ProgressPartBase, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?
---@param ctrl_writer (fun(self: ProgressPartBase, ctrl: via.gui.Control): boolean)?
---@param default_overwrite ProgressPartBaseDefaultOverwrite?
---@param gui_ignore boolean?
---@param children_sort (fun(a_key: string, b_key: string): boolean)?
---@return ProgressPartBase
function this:new(args, parent, ctrl_getter, ctrl_writer, default_overwrite, gui_ignore, children_sort)
    local o = hud_child.new(self, args, parent, ctrl_getter, ctrl_writer, default_overwrite, gui_ignore, children_sort)
    o.properties = util_table.merge_t(o.properties, {
        offset_x = true,
        clock_offset_x = true,
    })
    setmetatable(o, self)
    ---@cast o ProgressPartBase

    if args.enabled_offset_x then
        o:set_offset_x(args.offset_x)
    end

    if args.enabled_clock_offset_x then
        o:set_clock_offset_x(args.clock_offset_x)
    end
    return o
end

---@param offset_x number?
function this:set_offset_x(offset_x)
    if offset_x then
        self:mark_write()
        self.offset_x = offset_x
    else
        self:reset("offset")
        self.offset_x = offset_x
        self.offset = nil
        self:mark_idle()
    end
end

---@param clock_offset_x number?
function this:set_clock_offset_x(clock_offset_x)
    if clock_offset_x then
        self:mark_write()
        self.clock_offset_x = clock_offset_x
    else
        self:reset("offset")
        self.clock_offset_x = clock_offset_x
        self.offset = nil
        self:mark_idle()
    end
end

---@protected
---@param ctrl via.gui.Control
---@return boolean
function this:_write(ctrl)
    play_object.default.check(ctrl)

    if self.offset_x then
        local vec = ctrl:get_Position()
        vec.x = self.offset_x
        self.offset = vec

        if self.clock_offset_x and self.root:is_visible_quest_timer() then
            self.offset.x = self.offset_x + self.clock_offset_x
        end
    end

    return hud_child._write(self, ctrl)
end

---@param name_key string
---@return ProgressPartBaseConfig
function this.get_config(name_key)
    return {
        name_key = name_key,
        hide = false,
        enabled_offset_x = false,
        offset_x = 0,
        enabled_clock_offset_x = false,
        clock_offset_x = 0,
        enabled_scale = false,
        scale = { x = 1, y = 1 },
        children = {},
        hud_sub_type = mod.enum.hud_sub_type.PROGRESS_PART,
    }
end

return this
