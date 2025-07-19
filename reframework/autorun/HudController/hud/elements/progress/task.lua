---@class (exact) ProgressPartTask : ProgressPartBase
---@field get_config fun(): ProgressPartTaskConfig
---@field children {
--- text: ProgressPartText,
--- icon: ProgressPartBase,
--- num: ProgressPartBase,
--- checkbox: ProgressPartBase,
--- light: ProgressPartBase,
--- }

---@class (exact) ProgressPartTaskConfig : ProgressPartBaseConfig
---@field children {
--- text: ProgressPartTextConfig,
--- icon: ProgressPartBaseConfig,
--- num: ProgressPartBaseConfig,
--- checkbox: ProgressPartBaseConfig,
--- light: ProgressPartBaseConfig,
--- }

local part_base = require("HudController.hud.elements.progress.part_base")
local play_object = require("HudController.hud.play_object")
local text = require("HudController.hud.elements.progress.text")

---@class ProgressPartTask
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = part_base })

local ctrl_args = {
    task = {
        {
            {
                "PNL_Pat00",
            },
            "PNL_task",
        },
    },
    -- PNL_taskSet
    icon = {
        {
            {
                "PNL_taskSet",
                "PNL_icon",
            },
        },
    },
    num = {
        {
            {
                "PNL_taskSet",
                "PNL_num",
            },
        },
    },
    checkbox = {
        {
            {
                "PNL_taskSet",
                "PNL_ref_CheckBox",
            },
        },
    },
    text = {
        {
            {
                "PNL_taskSet",
                "PNL_taskAccent",
                "PNL_taskLighjt",
            },
            "txt_name_task",
            "via.gui.Text",
        },
    },
    light = {
        {
            {
                "PNL_taskSet",
                "PNL_taskAccent",
                "PNL_taskLighjt",
                "PNL_taskLightColor",
            },
        },
    },
}

---@param args ProgressPartTaskConfig
---@param parent Progress
---@param ctrl_getter (fun(self: ProgressPartBase, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?)?
---@return ProgressPartTask
function this:new(args, parent, ctrl_getter)
    local o = part_base.new(self, args, parent, ctrl_getter or function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.all, ctrl, ctrl_args.task)
    end)
    setmetatable(o, self)
    ---@cast o ProgressPartTask

    o.children.text = text:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.text)
    end)
    o.children.checkbox = part_base:new(args.children.checkbox, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.checkbox)
    end)
    o.children.icon = part_base:new(args.children.icon, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.icon)
    end)
    o.children.num = part_base:new(args.children.num, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.num)
    end)
    o.children.light = part_base:new(args.children.light, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.light)
    end)

    return o
end

---@return ProgressPartTaskConfig
function this.get_config()
    local base = part_base.get_config("task") --[[@as ProgressPartTaskConfig]]
    local children = base.children
    base.enabled_num_offset_x = false
    base.num_offset_x = 0

    children.text = text.get_config()
    children.text.enabled_num_offset_x = false
    children.text.num_offset_x = 0
    children.text.enabled_offset_x = false
    children.text.offset_x = 0
    children.text.enabled_clock_offset_x = false
    children.text.clock_offset_x = 0
    children.checkbox = part_base.get_config("checkbox")
    children.checkbox.enabled_num_offset_x = false
    children.checkbox.num_offset_x = 0
    children.icon = part_base.get_config("icon")
    children.icon.enabled_num_offset_x = false
    children.icon.num_offset_x = 0
    children.num = part_base.get_config("num")
    children.light = part_base.get_config("light")
    children.light.enabled_num_offset_x = false
    children.light.num_offset_x = 0
    return base
end

return this
