---@class (exact) QuestEndTimer : HudBase
---@field get_config fun(): QuestEndTimerConfig

---@class (exact) QuestEndTimerConfig : HudBaseConfig

local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local hud_base = require("HudController.hud.def.hud_base")
local util_mod = require("HudController.util.mod.init")

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

---@return QuestEndTimerConfig
function this.get_config()
    local base = hud_base.get_config(e.get("app.GUIHudDef.TYPE").QUEST_END_TIMER, "QUEST_END_TIMER") --[[@as QuestEndTimerConfig]]
    base.hud_type = mod.enum.hud_type.QUEST_END_TIMER
    return base
end

return this
