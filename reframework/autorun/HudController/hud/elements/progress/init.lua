---@class (exact) Progress : HudBase
---@field get_config fun(): ProgressConfig
---@field children {
--- clock: ProgressClock,
--- task: ProgressPartTask,
--- name_main: ProgressPartNameMain,
--- name_sub: ProgressPartNameSub,
--- guide_assign: ProgressPartGuideAssign,
--- gauge: ProgressPartGauge,
--- text_part: ProgressPartTextPart,
--- timer: ProgressTimer,
--- quest_timer: ProgressQuestTimer,
--- best_timer: ProgressQuestTimerBest,
--- faint: ProgressPartTaskFaint,
--- }
---@field GUI020018 app.GUI020018?

---@class (exact) ProgressConfig : HudBaseConfig
---@field options {
--- ELAPSED_TIME_DISP: integer,
--- }
---@field children {
--- clock: ProgressClockConfig,
--- task: ProgressPartTaskConfig,
--- timer: ProgressTimerConfig,
--- name_main: ProgressPartNameMainConfig,
--- name_sub: ProgressPartNameSubConfig,
--- guide_assign: ProgressPartGuideAssignConfig,
--- gauge: ProgressPartGaugeConfig,
--- text_part: ProgressPartTextPartConfig,
--- quest_timer: ProgressQuestTimerConfig,
--- best_timer: ProgressQuestTimerBestConfig,
--- faint: ProgressPartTaskFaintConfig,
--- }

---@class (exact) ProgressControlArguments
---@field task PlayObjectGetterFn[]
---@field timer PlayObjectGetterFn[]

local best_timer = require("HudController.hud.elements.progress.best_timer")
local clock = require("HudController.hud.elements.progress.clock")
local data = require("HudController.data")
local faint = require("HudController.hud.elements.progress.faint")
local game_data = require("HudController.util.game.data")
local gauge = require("HudController.hud.elements.progress.gauge")
local guide_assign = require("HudController.hud.elements.progress.guide_assign")
local hud_base = require("HudController.hud.def.hud_base")
local name_main = require("HudController.hud.elements.progress.name_main")
local name_sub = require("HudController.hud.elements.progress.name_sub")
local part_task = require("HudController.hud.elements.progress.task")
local play_object = require("HudController.hud.play_object")
local play_object_defaults = require("HudController.hud.defaults.play_object")
local quest_timer = require("HudController.hud.elements.progress.quest_timer")
local s = require("HudController.util.ref.singletons")
local text_part = require("HudController.hud.elements.progress.text_part")
local timer = require("HudController.hud.elements.progress.timer")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Progress
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@type ProgressControlArguments
local control_arguments = {
    timer = {
        {
            play_object.control.all,
            {
                "PNL_Pat00",
            },
            "PNL_time",
            true,
        },
    },
    task = {
        {
            play_object.control.all,
            {
                "PNL_Pat00",
            },
            "PNL_task",
        },
    },
}

---@param args ProgressConfig
---@return Progress
function this:new(args)
    local o = hud_base.new(self, args, nil, nil, nil, nil, function(a_key, b_key)
        local t = { "faint", "best_timer", "quest_timer" }

        if util_table.contains(t, a_key) then
            return false
        end

        if util_table.contains(t, b_key) then
            return true
        end
        return a_key < b_key
    end)
    setmetatable(o, self)
    ---@cast o Progress

    o.children.task = part_task:new(args.children.task, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.task)
    end)
    o.children.name_main = name_main:new(args.children.name_main, o)
    o.children.name_sub = name_sub:new(args.children.name_sub, o)
    o.children.guide_assign = guide_assign:new(args.children.guide_assign, o)
    o.children.gauge = gauge:new(args.children.gauge, o)
    o.children.text_part = text_part:new(args.children.text_part, o)
    o.children.timer = timer:new(args.children.timer, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.timer)
    end)
    o.children.clock = clock:new(args.children.clock, o)
    o.children.quest_timer = quest_timer:new(args.children.quest_timer, o, function(s, hudbase, gui_id, ctrl)
        ---@diagnostic disable-next-line: invisible
        local pnl = s._get_panel(s)
        if pnl then
            ---@diagnostic disable-next-line: param-type-mismatch
            o.children.timer:reset_specific(nil, nil, pnl)
        end
        return pnl
    end, nil, nil, nil, nil, true)
    o.children.best_timer = best_timer:new(args.children.best_timer, o)
    o.children.faint = faint:new(args.children.faint, o)
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

---@param hudbase app.GUIHudBase
---@param gui_id app.GUIID.ID
---@param ctrl via.gui.Control
function this:write(hudbase, gui_id, ctrl)
    if self:any() and not self:_write(ctrl) then
        return
    end

    if self:get_GUI020018()._DispSmallMissionTargetList:get_Count() > 0 then
        self:write_children(hudbase, gui_id, ctrl)
    end
end

function this:reset_defaults()
    play_object_defaults.clear_obj("GUI/ui020000/ui020000/ui020018//RootWindow/PNL_All/PNL_Scale/PNL_Pat00")
end

---@return boolean
function this:is_visible_quest_timer()
    local GUI020018 = self:get_GUI020018()
    local watch = GUI020018._WatchPanelData
    return watch and watch:isVisibleWatch()
end

---@return ProgressConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "PROGRESS"), "PROGRESS") --[[@as ProgressConfig]]
    local children = base.children
    base.hud_type = mod.enum.hud_type.PROGRESS
    base.options.ELAPSED_TIME_DISP = -1

    children.task = part_task.get_config()
    children.name_main = name_main.get_config()
    children.name_sub = name_sub.get_config()
    children.guide_assign = guide_assign.get_config()
    children.gauge = gauge.get_config()
    children.text_part = text_part.get_config()
    children.timer = timer.get_config()
    children.clock = clock.get_config()
    children.quest_timer = quest_timer.get_config()
    children.best_timer = best_timer.get_config()
    children.faint = faint.get_config()

    return base
end

return this
