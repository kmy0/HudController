---@class (exact) ProgressPartNameMain : ProgressPartBase
---@field get_config fun(): ProgressPartNameMainConfig
---@field children {
--- text: ProgressPartText,
--- base: ProgressPartBase,
--- }

---@class (exact) ProgressPartNameMainConfig : ProgressPartBaseConfig
---@field children {
--- text: ProgressPartTextConfig,
--- base: ProgressPartBaseConfig,
--- }

---@class (exact) ProgressPartNameMainControlArguments
---@field name_main PlayObjectGetterFn[]
---@field base PlayObjectGetterFn[]
---@field text PlayObjectGetterFn[]

local part_base = require("HudController.hud.elements.progress.part_base")
local play_object = require("HudController.hud.play_object.init")
local text = require("HudController.hud.elements.progress.text")

---@class ProgressPartNameMain
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = part_base })

---@type ProgressPartNameMainControlArguments
local control_arguments = {
    name_main = {
        {
            play_object.control.all,
            {
                "PNL_Pat00",
            },
            "PNL_name_main",
        },
    },
    -- PNL_name_main
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

---@param args ProgressPartNameMainConfig
---@param parent Progress
---@return ProgressPartNameMain
function this:new(args, parent)
    local o = part_base.new(self, args, parent, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.name_main)
    end)
    setmetatable(o, self)
    ---@cast o ProgressPartNameMain

    o.children.text = text:new(args.children.text, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text)
    end)
    o.children.base = part_base:new(args.children.base, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.base)
    end)

    return o
end

---@return ProgressPartNameMainConfig
function this.get_config()
    local base = part_base.get_config("name_main") --[[@as ProgressPartNameMainConfig]]
    local children = base.children

    children.text = text.get_config()
    children.base = part_base.get_config("base")
    children.base.enabled_clock_offset_x = nil
    children.base.clock_offset_x = nil

    return base
end

return this
