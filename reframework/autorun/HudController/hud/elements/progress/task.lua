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

---@class (exact) ProgressPartTaskControlArguments
---@field icon PlayObjectGetterFn[]
---@field text PlayObjectGetterFn[]
---@field num PlayObjectGetterFn[]
---@field checkbox PlayObjectGetterFn[]
---@field light PlayObjectGetterFn[]

local part_base = require("HudController.hud.elements.progress.part_base")
local play_object = require("HudController.hud.play_object.init")
local text = require("HudController.hud.elements.progress.text")

---@class ProgressPartTask
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = part_base })

-- PNL_task
---@type ProgressPartTaskControlArguments
local control_arguments = {
    icon = {
        {
            play_object.control.get,
            {
                "PNL_taskSet",
                "PNL_icon",
            },
        },
    },
    num = {
        {
            play_object.control.get,
            {
                "PNL_taskSet",
                "PNL_num",
            },
        },
    },
    checkbox = {
        {
            play_object.control.get,
            {
                "PNL_taskSet",
                "PNL_ref_CheckBox",
            },
        },
    },
    text = {
        {
            play_object.child.get,
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
            play_object.control.get,
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
---@param ctrl_getter fun(self: ProgressPartBase, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?
---@param ctrl_writer (fun(self: ProgressPartBase, ctrl: via.gui.Control): boolean)?
---@param default_overwrite ProgressPartBaseDefaultOverwrite?
---@param gui_ignore boolean?
---@param children_sort (fun(a: HudChild, b: HudChild): boolean)?
---@param no_cache boolean?
---@param valid_guiid (app.GUIID.ID | app.GUIID.ID[])?
---@param cache_index integer?
---@return ProgressPartTask
function this:new(
    args,
    parent,
    ctrl_getter,
    ctrl_writer,
    default_overwrite,
    gui_ignore,
    children_sort,
    no_cache,
    valid_guiid,
    cache_index
)
    local o = part_base.new(
        self,
        args,
        parent,
        ctrl_getter,
        ctrl_writer,
        default_overwrite,
        gui_ignore,
        children_sort,
        no_cache,
        valid_guiid,
        cache_index
    )
    setmetatable(o, self)
    ---@cast o ProgressPartTask

    o.children.text = text:new(args.children.text, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text)
    end)
    o.children.checkbox = part_base:new(args.children.checkbox, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.checkbox)
    end)
    o.children.icon = part_base:new(args.children.icon, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.icon)
    end)
    o.children.num = part_base:new(args.children.num, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.num)
    end)
    o.children.light = part_base:new(args.children.light, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.light)
    end)

    return o
end

---@return ProgressPartTaskConfig
function this.get_config()
    local base = part_base.get_config("task") --[[@as ProgressPartTaskConfig]]
    local children = base.children

    children.text = text.get_config()
    children.text.enabled_num_offset_x = false
    children.text.num_offset_x = 0
    children.text.enabled_offset_x = false
    children.text.offset_x = 0
    children.checkbox = part_base.get_config("checkbox")
    children.checkbox.enabled_num_offset_x = false
    children.checkbox.num_offset_x = 0
    children.checkbox.enabled_clock_offset_x = nil
    children.checkbox.clock_offset_x = nil
    children.icon = part_base.get_config("icon")
    children.icon.enabled_num_offset_x = false
    children.icon.num_offset_x = 0
    children.icon.enabled_clock_offset_x = nil
    children.icon.clock_offset_x = nil
    children.num = part_base.get_config("num")
    children.num.enabled_clock_offset_x = nil
    children.num.clock_offset_x = nil
    children.light = part_base.get_config("light")
    children.light.enabled_num_offset_x = false
    children.light.num_offset_x = 0
    children.light.enabled_clock_offset_x = nil
    children.light.clock_offset_x = nil
    return base
end

return this
