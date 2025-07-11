---@class (exact) Progress : HudBase
---@field get_config fun(): ProgressConfig
---@field children {clock: HudChild, task: HudChild, timer: ProgressTimer}
---@field GUI020018 app.GUI020018?

---@class (exact) ProgressConfig : HudBaseConfig
---@field children {
--- clock: ProgressClockConfig,
--- task: HudChildConfig,
--- timer: ProgressTimerConfig,
--- }

---@class (exact) ProgressClockConfig : HudChildConfig
---@field children {
--- frame_base: HudChildConfig,
--- frame_main: HudChildConfig,
--- limit: HudChildConfig,
--- }

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local s = require("HudController.util.ref.singletons")
local timer = require("HudController.hud.elements.progress.timer")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Progress
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- ctrl = PNL_Scale
local ctrl_args = {
    task = {
        {
            {
                "PNL_Pat00",
            },
            "PNL_task",
        },
        {
            {
                "PNL_Pat00",
            },
            "PNL_gauge",
        },
        {
            {
                "PNL_Pat00",
            },
            "PNL_guideAssign",
        },
        {
            {
                "PNL_Pat00",
            },
            "PNL_name_main",
        },
        {
            {
                "PNL_Pat00",
            },
            "PNL_name_sub",
        },
        {
            {
                "PNL_Pat00",
            },
            "PNL_text",
        },
    },
    clock = {
        {
            {
                "PNL_Pat00",
                "PNL_questTimer",
            },
        },
    },
    -- ctrl = PNL_questTimer
    ["clock.frame_base"] = {
        {
            {
                "PNL_ref_questTimer",
                "PNL_TimerAnim",
                "PNL_base",
            },
        },
    },
    ["clock.frame_main"] = {
        {
            {
                "PNL_ref_questTimer",
                "PNL_TimerAnim",
                "PNL_mainframe",
            },
        },
    },
    ["clock.limit"] = {
        {
            {
                "PNL_ref_questTimer",
                "PNL_TimerAnim",
                "PNL_limit3",
            },
        },
    },
}

---@param args ProgressConfig
---@return Progress
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Progress

    o.children.task = hud_child:new(args.children.task, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.all, ctrl, ctrl_args.task)
    end, nil, { hide = false })
    o.children.clock = hud_child:new(args.children.clock, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.clock)
    end, nil, { hide = false })
    o.children.clock.children.frame_base = hud_child:new(
        args.children.clock.children.frame_base,
        o.children.clock,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args["clock.frame_base"])
        end,
        nil,
        { hide = false }
    )
    o.children.clock.children.frame_main = hud_child:new(
        args.children.clock.children.frame_main,
        o.children.clock,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args["clock.frame_main"])
        end,
        nil,
        { hide = false }
    )
    o.children.clock.children.limit = hud_child:new(
        args.children.clock.children.limit,
        o.children.clock,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args["clock.limit"])
        end,
        nil,
        { hide = false }
    )
    o.children.timer = timer:new(args.children.timer, o)
    return o
end

---@return app.GUI020018
function this:get_GUI020018()
    if not self.GUI020018 then
        local accessor = s.get("app.GUIManager"):get_GUI020018Accessor()
        self.GUI020018 = accessor.MissionGuideGUI
    end
    return self.GUI020018
end

---@return ProgressConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "PROGRESS"), "PROGRESS") --[[@as ProgressConfig]]
    local children = base.children
    base.hud_type = mod.enum.hud_type.PROGRESS

    children.clock = hud_child.get_config("clock") --[[@as ProgressClockConfig]]
    children.task = { name_key = "task", hide = false }
    children.timer = timer.get_config()

    ---@diagnostic disable-next-line: cast-local-type
    children = children.clock.children
    children.frame_base = { name_key = "frame_base", hide = false, enabled_scale = false, scale = { x = 1, y = 1 } }
    children.frame_main = { name_key = "frame_main", hide = false, enabled_scale = false, scale = { x = 1, y = 1 } }
    children.limit = { name_key = "limit", hide = false }

    return base
end

return this
