---@class (exact) ProgressPartGuideAssign : ProgressPartBase
---@field get_config fun(): ProgressPartGuideAssignConfig
---@field children {
--- text: ProgressPartText,
--- base: ProgressPartBase,
--- icon: ProgressPartBase,
--- }

---@class (exact) ProgressPartGuideAssignConfig : ProgressPartBaseConfig
---@field children {
--- text: ProgressPartTextConfig,
--- base: ProgressPartBaseConfig,
--- icon: ProgressPartBaseConfig,
--- }

---@class (exact) ProgressPartGuideAssignControlArguments
---@field guide_assign PlayObjectGetterFn[]
---@field base PlayObjectGetterFn[]
---@field text PlayObjectGetterFn[]
---@field icon PlayObjectGetterFn[]

local part_base = require("HudController.hud.elements.progress.part_base")
local play_object = require("HudController.hud.play_object.init")
local text = require("HudController.hud.elements.progress.text")

---@class ProgressPartGuideAssign
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = part_base })

---@type ProgressPartGuideAssignControlArguments
local control_arguments = {
    guide_assign = {
        {
            play_object.control.all,
            {
                "PNL_Pat00",
            },
            "PNL_guideAssign",
        },
    },
    -- PNL_guideAssign
    base = {
        {
            play_object.control.get,
            {
                "PNL_txt_guide",
                "PNL_baseGuide",
            },
        },
    },
    icon = {
        {
            play_object.control.get,
            {
                "PNL_txt_guide",
                "PNL_pos_assing",
            },
        },
    },
    text = {
        {
            play_object.child.get,
            {
                "PNL_txt_guide",
            },
            "txt_name_guide",
            "via.gui.Text",
        },
    },
}

---@param args ProgressPartGuideAssignConfig
---@param parent Progress
---@return ProgressPartGuideAssign
function this:new(args, parent)
    local o = part_base.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.guide_assign)
    end)
    setmetatable(o, self)
    ---@cast o ProgressPartGuideAssign

    o.children.text = text:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text)
    end)
    o.children.base = part_base:new(args.children.base, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.base)
    end)
    o.children.icon = part_base:new(args.children.icon, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.icon)
    end)

    return o
end

---@return ProgressPartGuideAssignConfig
function this.get_config()
    local base = part_base.get_config("guide_assign") --[[@as ProgressPartGuideAssignConfig]]
    local children = base.children

    children.text = text.get_config()
    children.base = part_base.get_config("base")
    children.icon = part_base.get_config("icon")
    children.base.enabled_clock_offset_x = nil
    children.base.clock_offset_x = nil
    children.icon.enabled_clock_offset_x = nil
    children.icon.clock_offset_x = nil

    return base
end

return this
