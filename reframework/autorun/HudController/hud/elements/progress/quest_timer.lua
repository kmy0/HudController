---@class (exact) ProgressQuestTimer: HudChild
---@field get_config fun(): ProgressQuestTimerConfig
---@field children {
--- frame_base: HudChild,
--- frame_main: HudChild,
--- limit: HudChild,
--- }
---@field root Progress

---@class (exact) ProgressQuestTimerConfig : HudChildConfig
---@field children {
--- frame_base: HudChildConfig,
--- frame_main: HudChildConfig,
--- limit: HudChildConfig,
--- }

local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

---@class ProgressQuestTimer
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

local ctrl_args = {
    clock = {
        {
            {
                "PNL_Pat00",
                "PNL_questTimer",
            },
        },
    },
    -- ctrl = PNL_questTimer
    frame_base = {
        {
            {
                "PNL_ref_questTimer",
                "PNL_TimerAnim",
                "PNL_base",
            },
        },
    },
    frame_main = {
        {
            {
                "PNL_ref_questTimer",
                "PNL_TimerAnim",
                "PNL_mainframe",
            },
        },
    },
    limit = {
        {
            {
                "PNL_ref_questTimer",
                "PNL_TimerAnim",
                "PNL_limit3",
            },
        },
    },
}

---@param args ProgressQuestTimerConfig
---@param parent HudBase
---@return ProgressQuestTimer
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.clock)
    end, nil, { hide = false })
    setmetatable(o, self)
    ---@cast o ProgressQuestTimer

    o.children.frame_base = hud_child:new(args.children.frame_base, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.frame_base)
    end, nil, { hide = false })
    o.children.frame_main = hud_child:new(args.children.frame_main, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.frame_main)
    end, nil, { hide = false })
    o.children.limit = hud_child:new(args.children.limit, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.limit)
    end, nil, { hide = false })

    return o
end

---@return ProgressQuestTimerConfig
function this.get_config()
    local base = hud_child.get_config("clock") --[[@as ProgressQuestTimerConfig]]
    local children = base.children

    children.frame_base = { name_key = "frame_base", hide = false, enabled_scale = false, scale = { x = 1, y = 1 } }
    children.frame_main = { name_key = "frame_main", hide = false, enabled_scale = false, scale = { x = 1, y = 1 } }
    children.limit = { name_key = "limit", hide = false }

    return base
end

return this
