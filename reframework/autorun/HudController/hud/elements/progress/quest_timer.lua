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

---@class (exact) ProgressQuestTimerControlArguments
---@field background PlayObjectGetterFn[]

local ctrl_child = require("HudController.hud.def.ctrl_child")
local play_object = require("HudController.hud.play_object.init")
local timer = require("HudController.hud.elements.progress.timer")

---@class ProgressQuestTimer
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = timer })

-- PNL_time
---@type ProgressQuestTimerControlArguments
local control_arguments = {
    background = {
        {
            play_object.child.get,
            {
                "PNL_timeNum",
            },
            "mat_base10",
            "via.gui.Material",
        },
        {
            play_object.child.get,
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
---@param ctrl_getter fun(self: ProgressQuestTimer, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?)
---@param ctrl_writer (fun(self: ProgressQuestTimer, ctrl: via.gui.Control): boolean)?
---@param default_overwrite ProgressPartBaseDefaultOverwrite?
---@param gui_ignore boolean?
---@param children_sort (fun(a: HudChild, b: HudChild): boolean)?
---@param no_cache boolean?
---@param valid_guiid (app.GUIID.ID | app.GUIID.ID[])?
---@return ProgressQuestTimer
function this:new(
    args,
    parent,
    ctrl_getter,
    ctrl_writer,
    default_overwrite,
    gui_ignore,
    children_sort,
    no_cache,
    valid_guiid
)
    local o = timer.new(
        self,
        args,
        parent,
        ctrl_getter,
        ctrl_writer,
        default_overwrite,
        gui_ignore,
        children_sort,
        no_cache,
        valid_guiid
    )
    setmetatable(o, self)
    ---@cast o ProgressQuestTimer

    o.children.background = ctrl_child:new(
        args.children.background,
        o,
        function(s, hudbase, gui_id, ctrl)
            local panel = this._get_panel(o)
            if panel then
                return play_object.iter_args(panel, control_arguments.background)
            end
        end,
        nil,
        { hide = false }
    )

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
