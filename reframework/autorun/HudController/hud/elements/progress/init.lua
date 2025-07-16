---@class (exact) Progress : HudBase
---@field get_config fun(): ProgressConfig
---@field children {
--- clock: ProgressQuestTimer,
--- task: ProgressPartTask,
--- name_main: ProgressPartNameMain,
--- name_sub: ProgressPartNameSub,
--- guide_assign: ProgressPartGuideAssign,
--- gauge: ProgressPartGauge,
--- text_part: ProgressPartTextPart,
--- timer: ProgressTimer,
--- }
---@field GUI020018 app.GUI020018?

---@class (exact) ProgressConfig : HudBaseConfig
---@field options {
--- ELAPSED_TIME_DISP: integer,
--- }
---@field children {
--- clock: ProgressQuestTimerConfig,
--- task: ProgressPartTaskConfig,
--- timer: ProgressTimerConfig,
--- name_main: ProgressPartNameMainConfig,
--- name_sub: ProgressPartNameSubConfig,
--- guide_assign: ProgressPartGuideAssignConfig,
--- gauge: ProgressPartGaugeConfig,
--- text_part: ProgressPartTextPartConfig,
--- }

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local gauge = require("HudController.hud.elements.progress.gauge")
local guide_assign = require("HudController.hud.elements.progress.guide_assign")
local hud_base = require("HudController.hud.def.hud_base")
local name_main = require("HudController.hud.elements.progress.name_main")
local name_sub = require("HudController.hud.elements.progress.name_sub")
local part_task = require("HudController.hud.elements.progress.task")
local quest_timer = require("HudController.hud.elements.progress.quest_timer")
local s = require("HudController.util.ref.singletons")
local text_part = require("HudController.hud.elements.progress.text_part")
local timer = require("HudController.hud.elements.progress.timer")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Progress
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args ProgressConfig
---@return Progress
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Progress

    o.children.task = part_task:new(args.children.task, o)
    o.children.name_main = name_main:new(args.children.name_main, o)
    o.children.name_sub = name_sub:new(args.children.name_sub, o)
    o.children.guide_assign = guide_assign:new(args.children.guide_assign, o)
    o.children.gauge = gauge:new(args.children.gauge, o)
    o.children.text_part = text_part:new(args.children.text_part, o)
    o.children.timer = timer:new(args.children.timer, o)
    o.children.clock = quest_timer:new(args.children.clock, o)
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
    children.clock = quest_timer.get_config()

    return base
end

return this
