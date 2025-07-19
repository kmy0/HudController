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

local part_base = require("HudController.hud.elements.progress.part_base")
local play_object = require("HudController.hud.play_object")
local text = require("HudController.hud.elements.progress.text")

---@class ProgressPartGuideAssign
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = part_base })

local ctrl_args = {
    guide_assign = {
        {
            {
                "PNL_Pat00",
            },
            "PNL_guideAssign",
        },
    },
    -- PNL_guideAssign
    base = {
        {
            {
                "PNL_guideAssign",
                "PNL_txt_guide",
                "PNL_baseGuide",
            },
        },
    },
    icon = {
        {
            {
                "PNL_txt_guide",
                "PNL_pos_assing",
            },
        },
    },
    text = {
        {
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
        return play_object.iter_args(play_object.control.all, ctrl, ctrl_args.guide_assign)
    end)
    setmetatable(o, self)
    ---@cast o ProgressPartGuideAssign

    o.children.text = text:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.text)
    end)
    o.children.base = part_base:new(args.children.base, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.base)
    end)
    o.children.icon = part_base:new(args.children.icon, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.icon)
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

    return base
end

return this
