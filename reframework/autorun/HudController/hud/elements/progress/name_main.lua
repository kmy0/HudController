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

local part_base = require("HudController.hud.elements.progress.part_base")
local play_object = require("HudController.hud.play_object")
local text = require("HudController.hud.elements.progress.text")

---@class ProgressPartNameMain
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = part_base })

local ctrl_args = {
    name_main = {
        {
            {
                "PNL_Pat00",
            },
            "PNL_name_main",
        },
    },
    -- PNL_name_main
    base = {
        {
            {
                "PNL_base_NM",
            },
        },
    },
    text = {
        {
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
    local o = part_base.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.all, ctrl, ctrl_args.name_main)
    end)
    setmetatable(o, self)
    ---@cast o ProgressPartNameMain

    o.children.text = text:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.text)
    end)
    o.children.base = part_base:new(args.children.base, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.base)
    end)

    return o
end

---@return ProgressPartNameMainConfig
function this.get_config()
    local base = part_base.get_config("name_main") --[[@as ProgressPartNameMainConfig]]
    local children = base.children

    children.text = text.get_config()
    children.base = part_base.get_config("base")

    return base
end

return this
