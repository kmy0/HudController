---@class (exact) ProgressPartNameSub : ProgressPartBase
---@field get_config fun(): ProgressPartNameSubConfig
---@field children {
--- text: ProgressPartText,
--- base: ProgressPartBase,
--- }

---@class (exact) ProgressPartNameSubConfig : ProgressPartBaseConfig
---@field children {
--- text: ProgressPartTextConfig,
--- base: ProgressPartBaseConfig,
--- }

---@class (exact) ProgressPartNameSubControlArguments
---@field name_sub PlayObjectGetterFn[]
---@field base PlayObjectGetterFn[]
---@field text PlayObjectGetterFn[]

local part_base = require("HudController.hud.elements.progress.part_base")
local play_object = require("HudController.hud.play_object")
local text = require("HudController.hud.elements.progress.text")

---@class ProgressPartNameSub
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = part_base })

---@type ProgressPartNameSubControlArguments
local control_arguments = {
    name_sub = {
        {
            play_object.control.all,
            {
                "PNL_Pat00",
            },
            "PNL_name_sub",
        },
    },
    -- PNL_name_sub
    base = {
        {
            play_object.control.get,
            {
                "PNL_base_NM",
            },
        },
    },
    text = {
        {
            play_object.child.get,
            {
                "PNL_txt_NM",
            },
            "txt_name",
            "via.gui.Text",
        },
    },
}

---@param args ProgressPartNameSubConfig
---@param parent Progress
---@return ProgressPartNameSub
function this:new(args, parent)
    local o = part_base.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.name_sub)
    end)
    setmetatable(o, self)
    ---@cast o ProgressPartNameSub

    o.children.text = text:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text)
    end)
    o.children.base = part_base:new(args.children.base, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.base)
    end)

    return o
end

---@return ProgressPartNameSubConfig
function this.get_config()
    local base = part_base.get_config("name_sub") --[[@as ProgressPartNameSubConfig]]
    local children = base.children

    children.text = text.get_config()
    children.base = part_base.get_config("base")
    children.base.enabled_clock_offset_x = nil
    children.base.clock_offset_x = nil

    return base
end

return this
