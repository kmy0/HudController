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

---@class (exact) ProgressPartGaugeControlArguments
---@field gauge_part PlayObjectGetterFn[]
---@field gauge PlayObjectGetterFn[]
---@field text PlayObjectGetterFn[]

local part_base = require("HudController.hud.elements.progress.part_base")
local play_object = require("HudController.hud.play_object")
local text = require("HudController.hud.elements.progress.text")

---@class ProgressPartGauge
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = part_base })

---@type ProgressPartGaugeControlArguments
local control_arguments = {
    gauge_part = {
        {
            play_object.control.all,
            {
                "PNL_Pat00",
            },
            "PNL_gauge",
        },
    },
    -- PNL_gauge
    gauge = {
        {
            play_object.control.get,
            {
                "PNL_gaugeAnim",
            },
        },
    },
    text = {
        {
            play_object.child.get,
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
        return play_object.iter_args(ctrl, control_arguments.gauge_part)
    end)
    setmetatable(o, self)
    ---@cast o ProgressPartGauge

    o.children.text = text:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text)
    end)
    o.children.gauge = part_base:new(args.children.gauge, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.gauge)
    end)

    return o
end

---@return ProgressPartGaugeConfig
function this.get_config()
    local base = part_base.get_config("gauge") --[[@as ProgressPartGaugeConfig]]
    local children = base.children

    children.text = text.get_config()
    children.gauge = part_base.get_config("gauge")
    children.gauge.enabled_clock_offset_x = nil
    children.gauge.clock_offset_x = nil

    return base
end

return this
