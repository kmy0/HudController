---@class (exact) ProgressPartGauge : ProgressPartBase
---@field get_config fun(): ProgressPartGaugeConfig
---@field children {
--- text: ProgressPartText,
--- gauge: ProgressPartBase,
--- }

---@class (exact) ProgressPartGaugeConfig : ProgressPartBaseConfig
---@field children {
--- text: ProgressPartTextConfig,
--- gauge: ProgressPartBaseConfig,
--- }

local part_base = require("HudController.hud.elements.progress.part_base")
local play_object = require("HudController.hud.play_object")
local text = require("HudController.hud.elements.progress.text")

---@class ProgressPartGauge
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = part_base })

local ctrl_args = {
    gauge = {
        {
            {
                "PNL_Pat00",
            },
            "PNL_gauge",
        },
    },
    -- PNL_gauge
    gauge_ = {
        {
            {
                "PNL_guideAssign",
                "PNL_txt_guide",
                "PNL_baseGuide",
            },
        },
    },
    text = {
        {
            {
                "PNL_txt_gauge",
            },
            "txt_name_gauge",
            "via.gui.Text",
        },
    },
}

---@param args ProgressPartGaugeConfig
---@param parent Progress
---@return ProgressPartGauge
function this:new(args, parent)
    local o = part_base.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.all, ctrl, ctrl_args.gauge)
    end, nil, { hide = false })
    setmetatable(o, self)
    ---@cast o ProgressPartGauge

    o.children.text = text:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.text)
    end, nil, { hide = false })
    o.children.gauge = part_base:new(args.children.gauge, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.gauge_)
    end, nil, { hide = false })

    return o
end

---@return ProgressPartGaugeConfig
function this.get_config()
    local base = part_base.get_config("gauge") --[[@as ProgressPartGaugeConfig]]
    local children = base.children

    children.text = text.get_config()
    children.gauge = part_base.get_config("gauge")

    return base
end

return this
