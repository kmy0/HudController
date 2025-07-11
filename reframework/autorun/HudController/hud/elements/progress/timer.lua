---@class (exact) ProgressTimer : HudChild
---@field get_config fun(): ProgressTimerConfig
---@field children {text: HudChild, background: CtrlChild, rank: HudChild}
---@field always_visible boolean
---@field own_timer app.MissionGuideGUIParts.TimePanelData?
---@field properties ProgressTimerProperties
---@field root Progress
---@field protected _txt_name_time_set boolean

---@class (exact) ProgressTimerConfig : HudChildConfig
---@field hud_sub_type HudSubType
---@field children {text: HudChildConfig, background: CtrlChildConfig, rank: HudChildConfig}
---@field always_visible boolean

---@class (exact) ProgressTimerChangedProperties : HudChildChangedProperties
---@field always_visible boolean?

---@class (exact) ProgressTimerProperties : {[ProgressTimerProperty]: boolean}, HudChildProperties
---@field always_visible boolean

---@alias ProgressTimerProperty "always_visible" | HudChildProperty
---@alias ProgressTimerWriteKey ProgressTimerProperty | HudChildWriteKey

local call_queue = require("HudController.hud.call_queue")
local ctrl_child = require("HudController.hud.def.ctrl_child")
local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local game_lang = require("HudController.util.game.lang")
local hud_child = require("HudController.hud.def.hud_child")
local m = require("HudController.util.ref.methods")
local play_object = require("HudController.hud.play_object")
local s = require("HudController.util.ref.singletons")
local util_game = require("HudController.util.game")
local util_ref = require("HudController.util.ref")
local util_table = require("HudController.util.misc.table")

local rl = game_data.reverse_lookup
local ace_enum = data.ace.enum

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

    o.properties = util_table.merge_t(o.properties, {
        always_visible = true,
    })

    o.children.text = hud_child:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        local panel = this._get_panel(o)
        if panel then
            return play_object.iter_args(play_object.control.get, panel, ctrl_args.text)
        end
    end)
    o.children.background = ctrl_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        local panel = this._get_panel(o)
        if panel then
            return play_object.iter_args(play_object.child.get, panel, ctrl_args.background)
        end
    end)
    o.children.rank = hud_child:new(args.children.rank, o, function(s, hudbase, gui_id, ctrl)
        local panel = this._get_panel(o)
        if panel then
            return play_object.iter_args(play_object.control.get, panel, ctrl_args.rank)
        end
    end)

    if args.always_visible then
        o:set_always_visible(args.always_visible)
    end

    return o
end

---@param always_visible boolean
function this:set_always_visible(always_visible)
    self:reset("dummy")
    self.always_visible = always_visible
    if always_visible then
        self:mark_write()
    else
        self:mark_idle()
    end
end

---@param key ProgressTimerWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    call_queue.queue_func(self.root.hud_id, function()
        self:_timer_dtor()
    end)

    ---@cast key HudChildProperty
    hud_child.reset(self, key)
end

---@param hudbase app.GUIHudBase
---@param gui_id app.GUIID.ID
---@param ctrl via.gui.Control | via.gui.Control[]
---@param key ProgressTimerWriteKey
function this:reset_child(hudbase, gui_id, ctrl, key)
    if not self.initialized then
        return
    end

    call_queue.queue_func(self.root.hud_id, function()
        self:_timer_dtor()
    end)

    ---@cast key HudChildProperty
    hud_child.reset_child(self, hudbase, gui_id, ctrl, key)
end

---@param hudbase app.GUIHudBase
---@param gui_id app.GUIID.ID
---@param ctrl via.gui.Control | via.gui.Control[]
function this:write_child(hudbase, gui_id, ctrl)
    if self.always_visible or self.own_timer then
        local _is_visible_watch = self:_is_visible_watch()

        if self.always_visible and _is_visible_watch and not self.own_timer then
            self.own_timer = self:_own_timer_ctor()
        elseif self.own_timer and (not self.always_visible or not _is_visible_watch) then
            self:_timer_dtor()
        end

        if self.own_timer then
            self:_disappear_ori_timer()
            self:_force_time_remaining()
        end
    end

    hud_child.write_child(self, hudbase, gui_id, ctrl)
end

---@return boolean
function this:any_gui()
    return util_table.any(self.properties, function(key, value)
        if key ~= "always_visible" and self[key] then
            return true
        end
        return false
    end)
end

---@protected
---@return boolean
function this:_is_visible_watch()
    local GUI020018 = self.root:get_GUI020018()
    local watch = GUI020018._WatchPanelData
    return watch and watch:isVisibleWatch()
end

---@protected
---@return app.MissionGuideGUIParts.TimePanelData
function this:_own_timer_ctor()
    local GUI020018 = self.root:get_GUI020018()
    local info = util_ref.ctor("app.MissionGuideGUIParts.MissionGuideGUIDef.SmallMissionInfo", true)
    local guid = util_ref.value_type("System.Guid")
    info:call(
        ".ctor(app.MissionIDList.ID, System.Int32, System.Guid, System.Guid, app.MissionManager.MSG_STATE)",
        0xFFFFFFFF,
        0,
        guid,
        guid,
        0
    )
    info.IsEnableCheck = false
    local ret = GUI020018:createSmallMissionGuide(info, rl(ace_enum.guide_panel, "TIME")) --[[@as app.MissionGuideGUIParts.TimePanelData]]
    GUI020018._TimerPanelData = nil
    return ret
end

---@protected
function this:_timer_dtor()
    local GUI020018 = self.root:get_GUI020018()
    local parts_enum = util_game.get_array_enum(GUI020018._PartsList)
    while parts_enum:MoveNext() do
        local part = parts_enum:get_Current()
        if part:get_type_definition():is_a("app.MissionGuideGUIParts.TimePanelData") then
            ---@cast part app.MissionGuideGUIParts.TimePanelData
            GUI020018:releaseSmallMissionGuide(part:get_SmallMissionInfo())
        end
    end

    self.own_timer = nil
    self._txt_name_time_set = false
end

---@protected
function this:_disappear_ori_timer()
    local GUI020018 = self.root:get_GUI020018()
    local timer_panel = GUI020018._TimerPanelData
    if timer_panel then
        timer_panel._DuplicatePanel:set_Visible(false)
    end
end

---@protected
function this:_force_time_remaining()
    local quest_dir = s.get("app.MissionManager"):get_QuestDirector()
    local quest_clear = quest_dir:isTargetClearAll()

    if self.own_timer:getIsArenaQuest() and not quest_clear then
        return
    end

    local txt_time = self.own_timer._TextTime
    local elapsed = quest_dir:get_QuestElapsedTime()
    local minutes = math.floor(elapsed / 60)
    local seconds = elapsed % 60 --[[@as number]]
    local seconds_d = math.floor(seconds)
    ---@type string
    local time_formated

    if not quest_clear then
        time_formated = string.format("%02d:%02d", minutes, seconds_d)
    else
        time_formated = string.format("%02d:%02d.%03d", minutes, seconds_d, math.floor((seconds - seconds_d) * 1000))
        txt_time:set_AutoRegionFit(rl(ace_enum.region_fit, "Vertical"))
        if not self.children.background.hide then
            local font_size = txt_time:get_FontSize()
            font_size.w = 20
            font_size.h = 20
            txt_time:set_FontSize(font_size)
        end
    end

    if not self._txt_name_time_set then
        local txt_name_time = play_object.child.get(self.own_timer._DuplicatePanel, {
            "PNL_txt_time",
        }, "txt_name_time", "via.gui.Text") --[[@as via.gui.Text?]]

        if txt_name_time then
            local txt_name_time_guid = m.getGuidByName("MsgGUI020018_0006")
            local txt_name_time_local = game_lang.get_message_local(txt_name_time_guid, game_lang.get_language(), true)
            txt_name_time:set_Message(txt_name_time_local)
            self._txt_name_time_set = true
        end
    end

    txt_time:set_Message(time_formated)
end

---@protected
---@return via.gui.Panel?
function this:_get_panel()
    if self.own_timer then
        return self.own_timer._DuplicatePanel
    end

    local GUI020018 = self.root:get_GUI020018()
    local timer_panel = GUI020018._TimerPanelData
    if timer_panel then
        return timer_panel._DuplicatePanel
    end
end

---@return ProgressTimerConfig
function this.get_config()
    local base = hud_child.get_config("timer") --[[@as ProgressTimerConfig]]
    local children = base.children

    base.always_visible = false

    children.text = { name_key = "text", hide = false }
    children.background = { name_key = "background", hide = false }
    children.rank = { name_key = "rank", hide = false }

    return base
end

return this
