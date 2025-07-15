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
                "PNL_icon",
                "PNL_ref_icon00",
            },
        },
    },
    num = {
        {
            {
                "PNL_num",
            },
        },
    },
    checkbox = {
        {
            {
                "PNL_ref_CheckBox",
            },
        },
    },
    text = {
        {
            {
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
                "PNL_taskAccent",
                "PNL_taskLighjt",
                "PNL_taskLightColor",
            },
        },
    },
}

---@param args ProgressPartTaskConfig
---@param parent Progress
---@return ProgressPartTask
function this:new(args, parent)
    local o = part_base.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.control.get_from_all(
            play_object.iter_args(play_object.control.all, ctrl, ctrl_args.task),
            "PNL_taskSet"
        )
    end, nil, { hide = false })
    setmetatable(o, self)
    ---@cast o ProgressPartTask

    o.children.text = text:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.text)
    end, nil, { hide = false })
    o.children.checkbox = part_base:new(args.children.checkbox, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.checkbox)
    end, nil, { hide = false })
    o.children.icon = part_base:new(args.children.icon, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.icon)
    end, nil, { hide = false })
    o.children.num = part_base:new(args.children.num, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.num)
    end, nil, { hide = false })
    o.children.light = part_base:new(args.children.light, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.light)
    end, nil, { hide = false })

    return o
end

---@return ProgressPartTaskConfig
function this.get_config()
    local base = part_base.get_config("task") --[[@as ProgressPartTaskConfig]]
    local children = base.children

    children.text = text.get_config()
    children.checkbox = part_base.get_config("checkbox")
    children.icon = part_base.get_config("icon")
    children.num = part_base.get_config("num")
    children.light = part_base.get_config("light")
    return base
end

return this
