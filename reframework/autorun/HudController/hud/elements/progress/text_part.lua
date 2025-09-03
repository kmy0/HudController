---@class (exact) ProgressPartTextPart : ProgressPartBase
---@field get_config fun(): ProgressPartTextPartConfig
---@field children {
--- text: ProgressPartText,
--- }

---@class (exact) ProgressPartTextPartConfig : ProgressPartBaseConfig
---@field children {
--- text: ProgressPartTextConfig,
--- }

---@class (exact) ProgressPartTextPartControlArguments
---@field text_part PlayObjectGetterFn[]
---@field text PlayObjectGetterFn[]

local part_base = require("HudController.hud.elements.progress.part_base")
local play_object = require("HudController.hud.play_object")
local text = require("HudController.hud.elements.progress.text")

---@class ProgressPartTextPart
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = part_base })

---@type ProgressPartTextPartControlArguments
local control_arguments = {
    text_part = {
        {
            play_object.control.all,
            {
                "PNL_Pat00",
            },
            "PNL_text",
        },
    },
    -- PNL_text
    text = {
        {
            play_object.child.get,
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
        return play_object.iter_args(ctrl, control_arguments.text_part)
    end)
    setmetatable(o, self)
    ---@cast o ProgressPartTextPart

    o.children.text = text:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text)
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
