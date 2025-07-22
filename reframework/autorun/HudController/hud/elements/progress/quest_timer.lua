---@class (exact) ProgressQuestTimer : ProgressTimer
---@field get_config fun(): ProgressQuestTimerConfig
---@field children {
--- text: ProgressPartBase,
--- rank: ProgressPartBase,
--- background: CtrlChild,
--- }
---@field root Progress

---@class (exact) ProgressQuestTimerConfig : ProgressTimerConfig
---@field children {
--- text: ProgressPartBaseConfig,
--- rank: ProgressPartBaseConfig,
--- background: CtrlChildConfig,
--- }

local ctrl_child = require("HudController.hud.def.ctrl_child")
local play_object = require("HudController.hud.play_object")
local timer = require("HudController.hud.elements.progress.timer")

---@class ProgressQuestTimer
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = timer })

-- ctrl = PNL_time
local ctrl_args = {
    background = {
        {
            {
                "PNL_timeNum",
            },
            "mat_base10",
            "via.gui.Material",
        },
        {
            {
                "PNL_timeNum",
            },
            "mat_base11",
            "via.gui.Material",
        },
    },
}

---@param args ProgressQuestTimerConfig
---@param parent Progress
---@param ctrl_getter (fun(self: ProgressPartBase, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?)?
---@return ProgressQuestTimer
function this:new(args, parent, ctrl_getter)
    local o = timer.new(self, args, parent, ctrl_getter or function(s, hudbase, gui_id, ctrl)
        local pnl = this._get_panel(s)
        if pnl then
            parent.children.timer:reset_specific(nil, pnl)
        end
        return pnl
    end)
    setmetatable(o, self)
    ---@cast o ProgressQuestTimer

    o.children.background = ctrl_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        local panel = this._get_panel(o)
        if panel then
            return play_object.iter_args(play_object.child.get, panel, ctrl_args.background)
        end
    end, nil, { hide = false })

    return o
end

---@protected
---@return via.gui.Panel?
function this:_get_panel()
    local GUI020018 = self.root:get_GUI020018()
    local timer_panel = GUI020018._TimerPanelData
    if timer_panel then
        return timer_panel._DuplicatePanel
    end
end

---@return ProgressQuestTimerConfig
function this.get_config()
    local base = timer.get_config() --[[@as ProgressQuestTimerConfig]]
    local children = base.children

    base.name_key = "quest_timer"
    base.enabled_offset = false
    base.offset = { x = 0, y = 0 }
    base.enabled_clock_offset_x = nil
    base.clock_offset_x = nil

    children.background = { name_key = "background", hide = false }
    return base
end

return this
