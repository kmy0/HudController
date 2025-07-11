---@class (exact) ProgressTimer : HudChild
---@field get_config fun(): ProgressTimerConfig
---@field children {text: HudChild, background: CtrlChild, rank: HudChild, best_times: HudChild}
---@field root Progress

---@class (exact) ProgressTimerConfig : HudChildConfig
---@field children {text: HudChildConfig, background: CtrlChildConfig, rank: HudChildConfig, best_times: HudChildConfig}

local ctrl_child = require("HudController.hud.def.ctrl_child")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

---@class ProgressTimer
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- ctrl = PNL_time
local ctrl_args = {
    text = {
        {
            {
                "PNL_txt_time",
            },
        },
    },
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
    rank = {
        {
            {
                "PNL_ref_arenaRankIcon00",
            },
        },
    },
}

---@param args ProgressTimerConfig
---@param parent HudBase
---@return ProgressTimer
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return this._get_panel(s)
    end, nil, { hide = false })
    setmetatable(o, self)
    ---@cast o ProgressTimer

    o.children.text = hud_child:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        local panel = this._get_panel(o)
        if panel then
            return play_object.iter_args(play_object.control.get, panel, ctrl_args.text)
        end
    end, nil, { hide = false })
    o.children.background = ctrl_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        local panel = this._get_panel(o)
        if panel then
            return play_object.iter_args(play_object.child.get, panel, ctrl_args.background)
        end
    end, nil, { hide = false })
    o.children.rank = hud_child:new(args.children.rank, o, function(s, hudbase, gui_id, ctrl)
        local panel = this._get_panel(o)
        if panel then
            return play_object.iter_args(play_object.control.get, panel, ctrl_args.rank)
        end
    end, nil, { hide = false })
    o.children.best_times = hud_child:new(args.children.best_times, o, function(s, hudbase, gui_id, ctrl)
        ---@diagnostic disable-next-line: invisible
        return o:_get_panel_best_times()
    end, nil, { hide = false })

    return o
end

---@protected
---@return via.gui.Panel?
function this:_get_panel()
    local timer_panel = self:_get_timer()
    if timer_panel then
        return timer_panel._DuplicatePanel
    end
end

---@protected
---@return via.gui.Panel
function this:_get_panel_best_times()
    local GUI020018 = self.root:get_GUI020018()
    local best = GUI020018._BestRecordPanelData
    return best._DuplicatePanel
end

---@protected
---@return app.MissionGuideGUIParts.TimePanelData
function this:_get_timer()
    local GUI020018 = self.root:get_GUI020018()
    return GUI020018._TimerPanelData
end

---@return ProgressTimerConfig
function this.get_config()
    local base = hud_child.get_config("timer") --[[@as ProgressTimerConfig]]
    local children = base.children

    children.text = { name_key = "text", hide = false }
    children.background = { name_key = "background", hide = false }
    children.rank = { name_key = "rank", hide = false }
    children.best_times = { name_key = "best_times", hide = false }

    return base
end

return this
