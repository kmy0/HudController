---@class (exact) ProgressTimer : ProgressPartBase
---@field get_config fun(): ProgressTimerConfig
---@field children {
--- text: ProgressPartBase,
--- rank: ProgressPartBase,
--- }
---@field root Progress

---@class (exact) ProgressTimerConfig : ProgressPartBaseConfig
---@field children {
--- text: ProgressPartBaseConfig,
--- rank: ProgressPartBaseConfig,
--- }

local part_base = require("HudController.hud.elements.progress.part_base")
local play_object = require("HudController.hud.play_object")

---@class ProgressTimer
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = part_base })

local ctrl_args = {
    timer = {
        {
            {
                "PNL_Pat00",
            },
            "PNL_time",
            true,
        },
    },
    -- ctrl = PNL_time
    text = {
        {
            {
                "PNL_txt_time",
            },
        },
    },
    rank = {
        {
            {
                "PNL_ref_arenaRankIcon00",
            },
        },
    },
}

---@param args ProgressTimerConfig
---@param parent Progress
---@param ctrl_getter (fun(self: ProgressPartBase, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?)?
---@return ProgressTimer
function this:new(args, parent, ctrl_getter)
    local o = part_base.new(self, args, parent, ctrl_getter or function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.all, ctrl, ctrl_args.timer)
    end)
    setmetatable(o, self)
    ---@cast o ProgressTimer

    o.children.text = part_base:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.text)
    end, nil, { hide = false })
    o.children.rank = part_base:new(args.children.rank, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.rank)
    end, nil, { hide = false })

    return o
end

---@return ProgressTimerConfig
function this.get_config()
    local base = part_base.get_config("timer") --[[@as ProgressTimerConfig]]
    local children = base.children

    children.text = {
        name_key = "text",
        hide = false,
    }
    children.rank = {
        name_key = "rank",
        hide = false,
    }

    return base
end

return this
