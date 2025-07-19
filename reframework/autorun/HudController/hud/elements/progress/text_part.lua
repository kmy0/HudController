---@class (exact) ProgressPartTextPart : ProgressPartBase
---@field get_config fun(): ProgressPartTextPartConfig
---@field children {
--- text: ProgressPartText,
--- }

---@class (exact) ProgressPartTextPartConfig : ProgressPartBaseConfig
---@field children {
--- text: ProgressPartTextConfig,
--- }

local part_base = require("HudController.hud.elements.progress.part_base")
local play_object = require("HudController.hud.play_object")
local text = require("HudController.hud.elements.progress.text")

---@class ProgressPartTextPart
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = part_base })

local ctrl_args = {
    text = {
        {
            {
                "PNL_Pat00",
            },
            "PNL_text",
        },
    },
    -- PNL_text
    text_ = {
        {
            {
                "PNL_txt_text",
            },
            "txt_name_text",
            "via.gui.Text",
        },
    },
}

---@param args ProgressPartTextPartConfig
---@param parent Progress
---@return ProgressPartTextPart
function this:new(args, parent)
    local o = part_base.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.all, ctrl, ctrl_args.text)
    end)
    setmetatable(o, self)
    ---@cast o ProgressPartTextPart

    o.children.text = text:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.text_)
    end, nil, { hide = false })

    return o
end

---@return ProgressPartTextPartConfig
function this.get_config()
    local base = part_base.get_config("text") --[[@as ProgressPartTextPartConfig]]
    local children = base.children

    children.text = text.get_config()

    return base
end

return this
