---@class (exact) QuestEndTimer : HudBase
---@field quest_end_timer QuestEndTimerSetting
---@field get_config fun(): QuestEndTimerConfig

---@class (exact) QuestEndTimerConfig : HudBaseConfig
---@field quest_end_timer QuestEndTimerSetting

local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local hud_base = require("HudController.hud.def.hud_base")
local util_mod = require("HudController.util.mod.init")
local mod_enum = require("HudController.data.mod").enum

local mod = data.mod

---@class QuestEndTimer
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args QuestEndTimerConfig
---@return QuestEndTimer
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o QuestEndTimer

    o.quest_end_timer = args.quest_end_timer
    return o
end

---@param key HudBaseWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    local hudbase = util_mod.get_gui_cls("app.GUI020202")
    if not hudbase then
        return
    end

    local ctrl = util_mod.get_root_window(hudbase)
    self:reset_ctrl(ctrl, key)
    ---@diagnostic disable-next-line: param-type-mismatch
    self:reset_children(hudbase, nil, ctrl, key)
end

---@param val QuestEndTimerSetting
function this:set_quest_end_timer(val)
    self.quest_end_timer = val
end

---@return QuestEndTimerConfig
function this.get_config()
    local base =
        hud_base.get_config(e.get_noexact("app.GUIHudDef.TYPE").QUEST_END_TIMER, "QUEST_END_TIMER") --[[@as QuestEndTimerConfig]]
    base.hud_type = mod.enum.hud_type.QUEST_END_TIMER
    base.quest_end_timer = mod_enum.quest_end_timer.DISABLED
    return base
end

return this
