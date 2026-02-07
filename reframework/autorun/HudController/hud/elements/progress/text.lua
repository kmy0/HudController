---@class (exact) ProgressPartText : Text, ProgressPartBaseConfig
---@field align_left boolean
---@field ctrl_getter fun(self: ProgressPartText, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?
---@field ctrl_writer (fun(self: ProgressPartText, ctrl: via.gui.Control): boolean)?
---@field get_config fun(): ProgressPartTextConfig
---@field set_offset_x fun(self: ProgressPartText, val: number?)
---@field set_clock_offset_x fun(self: ProgressPartText, val: number?)
---@field set_num_offset_x fun(self: ProgressPartText, val: number?)
---@field mark_write fun(self: ProgressPartText, key: ProgressPartTextProperty)
---@field mark_idle fun(self: ProgressPartText, key: ProgressPartTextProperty)

---@class (exact) ProgressPartTextConfig : TextConfig, ProgressPartBaseConfig
---@field align_left boolean?

---@class (exact) ProgressPartTextdDefault : TextDefault, ProgressPartBaseDefault
---@field align_left boolean

---@class (exact) ProgressPartTextDefaultOverwite : TextDefaultOverwrite, ProgressPartBaseDefaultOverwrite
---@field align_left boolean?

---@class (exact) ProgressPartTextChangedProperties : TextChangedProperties, ProgressPartBaseChangedProperties
---@field align_left boolean?

---@class (exact) ProgressPartTextProperties : {[ProgressPartTextProperty]: boolean}, TextProperties, ProgressPartBaseProperties
---@field align_left boolean

---@alias ProgressPartTextProperty "align_left" | ProgressPartBaseProperty
---@alias ProgressPartTextWriteKey ProgressPartTextProperty | TextProperties

local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local part_base = require("HudController.hud.elements.progress.part_base")
local text = require("HudController.hud.def.text")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

---@class ProgressPartText
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = text })

---@param args ProgressPartTextConfig
---@param parent HudBase
---@param ctrl_getter fun(self: ProgressPartText, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?
---@param ctrl_writer (fun(self: ProgressPartText, ctrl: via.gui.Control): boolean)? when set, ctrl_writer is used instead of hud_base._write
---@param default_overwrite ProgressPartTextDefaultOverwite?
---@param gui_ignore boolean? by_default, false - if true, do not draw in imgui window
---@param children_sort (fun(a: HudChild, b: HudChild): boolean)? children iteration order
---@param no_cache boolean? by_default, false - if true cache via.gui.Control objects
---@param valid_guiid (app.GUIID.ID | app.GUIID.ID[])? when set, ctrl_getter ignores all guiids except these
---@return ProgressPartText
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
    local o = text.new(
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
        align_left = true,
        offset_x = true,
        clock_offset_x = true,
        num_offset_x = true,
    })

    setmetatable(o, self)
    ---@cast o ProgressPartText

    --FIXME: this suck ass
    o.set_offset_x = part_base.set_offset_x
    o.set_num_offset_x = part_base.set_num_offset_x
    o.set_clock_offset_x = part_base.set_clock_offset_x

    if args.align_left then
        o:set_align_left(args.align_left)
    end

    if args.enabled_offset_x then
        o:set_offset_x(args.offset_x)
    end

    if args.enabled_clock_offset_x then
        o:set_clock_offset_x(args.clock_offset_x)
    end

    if args.enabled_num_offset_x then
        o:set_num_offset_x(args.num_offset_x)
    end

    return o
end

---@param align_left boolean
function this:set_align_left(align_left)
    if align_left then
        self:mark_write("align_left")
        self.align_left = align_left
        self.page_alignment = e.get("via.gui.PageAlignment").LeftCenter
    else
        self:reset("page_alignment")
        self.align_left = align_left
        self.page_alignment = nil
        self:mark_idle("align_left")
    end
end

function this:any()
    return part_base.any(self)
end

function this:any_gui()
    return part_base.any_gui(self)
end

---@protected
---@param ctrl via.gui.Text
---@return boolean
function this:_write(ctrl)
    ---@diagnostic disable-next-line: invisible, param-type-mismatch
    local ret = part_base._write(self, ctrl)

    --FIXME: this writes hud_child properties twice
    if ret and text.any(self) then
        text._write(self, ctrl)
    end
    return ret
end

---@return ProgressPartTextConfig
function this.get_config()
    return {
        name_key = "text",
        align_left = false,
        hud_sub_type = mod.enum.hud_sub_type.PROGRESS_TEXT,
        gui_thing = "align_left",
    }
end

return this
