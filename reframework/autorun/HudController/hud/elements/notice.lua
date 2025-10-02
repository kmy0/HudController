---@class (exact) Notice : HudBase
---@field get_config fun(): NoticeConfig
---@field cache_msg boolean
---@field system_log table<string, boolean>
---@field lobby_log table<string, boolean>
---@field enemy_log table<string, boolean>
---@field camp_log table<string, boolean>
---@field chat_log table<string, boolean>
---@field log_id table<string, integer>
---@field message_log_cache CircularBuffer<CachedMessage>
---@field protected _queued_callbacks table<app.cGUI020100PanelBase, boolean>
---@field get_cls_name_short fun(cls_name: string): string
---@field children {
--- Item: HudChild,
--- Tutorial: HudChild,
--- Text: HudChild,
--- Signal: HudChild,
--- Network: HudChild,
--- Enemy: HudChild,
--- Animal: HudChild,
--- Achieve: HudChild,
--- Communication: HudChild,
--- }

---@class (exact) NoticePnlCache : {
--- app.cGUI020100PanelItem: [app.cGUI020100PanelBase, via.gui.Control][]?,
--- app.cGUI020100PanelTutorial: [app.cGUI020100PanelBase, via.gui.Control][]?,
--- app.cGUI020100PanelText:[app.cGUI020100PanelBase, via.gui.Control][]?,
--- app.cGUI020100PanelSignal: [app.cGUI020100PanelBase, via.gui.Control][]?,
--- app.cGUI020100PanelNetwork: [app.cGUI020100PanelBase, via.gui.Control][]?,
--- app.cGUI020100PanelEnemy: [app.cGUI020100PanelBase, via.gui.Control][]?,
--- app.cGUI020100PanelAnimal: [app.cGUI020100PanelBase, via.gui.Control][]?,
--- app.cGUI020100PanelAchieve: [app.cGUI020100PanelBase, via.gui.Control][]?,
--- app.GUI020100PanelCommunication: [app.cGUI020100PanelBase, via.gui.Control][]?,
--- }

---@class (exact) NoticeConfig : HudBaseConfig
---@field cache_msg boolean
---@field system_log table<string, boolean>
---@field lobby_log table<string, boolean>
---@field enemy_log table<string, boolean>
---@field camp_log table<string, boolean>
---@field chat_log table<string, boolean>
---@field log_id table<string, integer>
---@field contains {hide: boolean, pattern: string}
---@field not_contains {hide: boolean, pattern: string}
---@field children {
--- Item: HudChildConfig,
--- Tutorial: HudChildConfig,
--- Text: HudChildConfig,
--- Signal: HudChildConfig,
--- Network: HudChildConfig,
--- Enemy: HudChildConfig,
--- Animal: HudChildConfig,
--- Achieve: HudChildConfig,
--- Communication: HudChildConfig,
--- }

---@class (exact) CachedMessage
---@field type string
---@field sub_type string?
---@field other_type string?
---@field msg string
---@field cls string
---@field log_id app.ChatDef.LOG_ID

local call_queue = require("HudController.hud.call_queue")
local circular_buffer = require("HudController.util.misc.circular_buffer")
local data = require("HudController.data.init")
local frame_cache = require("HudController.util.misc.frame_cache")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local util_game = require("HudController.util.game.init")
local util_misc = require("HudController.util.misc.init")
local util_ref = require("HudController.util.ref.init")

local ace_enum = data.ace.enum
local ace_map = data.ace.map
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Notice
local this = {
    message_log_cache = circular_buffer:new(50),
}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

local cls_name_array = {
    "app.cGUI020100PanelItem",
    "app.cGUI020100PanelTutorial",
    "app.cGUI020100PanelText",
    "app.cGUI020100PanelSignal",
    "app.cGUI020100PanelNetwork",
    "app.cGUI020100PanelEnemy",
    "app.cGUI020100PanelAnimal",
    "app.cGUI020100PanelAchieve",
    "app.GUI020100PanelCommunication",
}

---@param args NoticeConfig
---@return Notice
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Notice

    o.system_log = args.system_log
    o.lobby_log = args.lobby_log
    o.enemy_log = args.enemy_log
    o.camp_log = args.camp_log
    o.chat_log = args.chat_log
    o.cache_msg = args.cache_msg
    o._queued_callbacks = {}
    o:_set_log_id(args.log_id)

    for _, cls_name in pairs(cls_name_array) do
        local cls_short = this.get_cls_name_short(cls_name)
        o.children[cls_short] = hud_child:new(
            args.children[cls_short],
            o,
            function(s, hudbase, gui_id, ctrl)
                ---@cast hudbase app.GUI020100
                ---@diagnostic disable-next-line: invisible
                return o:_notice_ctrl_getter(s, hudbase, cls_short)
            end,
            nil,
            nil,
            nil,
            nil,
            true
        )

        --FIXME: this feels a bit out of place...
        ace_map.no_lang_key[cls_short] = true
    end

    return o
end

---@protected
---@param log_id table<string, integer>
function this:_set_log_id(log_id)
    self.log_id = {}
    -- required because of merge2, merge2 removes all keys that do not exist in default config
    for k, v in pairs(log_id) do
        if type(v) == "number" then
            self.log_id[k] = v
        end
    end
end

---@param name_key string
---@param hide boolean
function this:set_system_log(name_key, hide)
    self.system_log[name_key] = hide
end

---@param name_key string
---@param hide boolean
function this:set_lobby_log(name_key, hide)
    self.lobby_log[name_key] = hide
end

---@param name_key string
---@param hide boolean
function this:set_enemy_log(name_key, hide)
    self.enemy_log[name_key] = hide
end

---@param name_key string
---@param hide boolean
function this:set_camp_log(name_key, hide)
    self.camp_log[name_key] = hide
end

---@param name_key string
---@param hide boolean
function this:set_chat_log(name_key, hide)
    self.chat_log[name_key] = hide
end

---@param val boolean
function this:set_cache_msg(val)
    self.cache_msg = val
end

---@param key string
---@param val integer?
function this:set_log_id(key, val)
    self.log_id[key] = val
end

---@param msg CachedMessage
function this:push_back(msg)
    this.message_log_cache:push_back(msg)
end

---@protected
---@param hudchild HudChild
---@param hudbase app.GUI020100
---@param cls_name string
---@return via.gui.Control[]?
function this:_notice_ctrl_getter(hudchild, hudbase, cls_name)
    local pnl_cache = self:_get_active_notifications(hudbase)
    local cached = pnl_cache[cls_name]
    local ret = {}

    if cached then
        for _, pnl in pairs(cached) do
            local pnl_base = pnl[1]
            local ctrl = pnl[2]
            table.insert(ret, ctrl)

            if not self._queued_callbacks[pnl_base] then
                local function reset_pnl()
                    if pnl_base:get_reference_count() == 1 or not ctrl:get_ActualVisible() then
                        hudchild:reset_ctrl(ctrl)
                        self._queued_callbacks[pnl_base] = nil
                    else
                        call_queue.queue_func_next(self.hud_id, reset_pnl)
                    end
                end

                call_queue.queue_func(self.hud_id, reset_pnl)
                self._queued_callbacks[pnl_base] = true
            end
        end
    end

    return ret
end

---@protected
---@param hudbase app.GUI020100
---@return NoticePnlCache
function this:_get_active_notifications(hudbase)
    ---@type NoticePnlCache
    local ret = {}
    util_game.do_something(hudbase:get__LogPanels(), function(system_array, index, value)
        -- notifcations with other elements attached to it (important, result etc.)
        if not value:get_IsFix() then
            local cls_name = this.get_cls_name_short(util_ref.whoami(value))
            local pnl = value:get_BasePanel()
            ret[cls_name] = ret[cls_name] or {}
            table.insert(ret[cls_name], { value, pnl })
        end
    end)

    return ret
end

---@param cls_name string
---@return string
function this.get_cls_name_short(cls_name)
    return util_misc.split_string(cls_name, "GUI020100Panel")[2] or ""
end

---@return NoticeConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "NOTICE"), "NOTICE") --[[@as NoticeConfig]]

    base.hud_type = mod.enum.hud_type.NOTICE
    base.system_log = { ALL = false }
    base.lobby_log = {}
    base.chat_log = { ALL = false }
    base.enemy_log = {}
    base.camp_log = {}
    base.cache_msg = false
    base.log_id = {}

    for _, cls_name in pairs(cls_name_array) do
        local cls_short = this.get_cls_name_short(cls_name)
        base.children[cls_short] = hud_child.get_config(cls_short)
        base.children[cls_short].hide = nil
    end

    for _, name in pairs(ace_enum.system_msg) do
        base.system_log[name] = false
    end

    for _, name in pairs(ace_enum.send_target) do
        base.lobby_log[name] = false
    end

    for _, name in pairs(ace_enum.enemy_log) do
        base.enemy_log[name] = false
    end

    for _, name in pairs(ace_enum.camp_log) do
        base.camp_log[name] = false
    end

    for _, name in pairs(ace_enum.chat_log) do
        base.chat_log[name] = false
    end

    for e, _ in pairs(ace_enum.log_id) do
        -- required because of merge2, merge2 removes all keys that do not exist in default config
        ---@diagnostic disable-next-line: assign-type-mismatch
        base.log_id[tostring(e)] = "dummy"
    end

    return base
end

---@diagnostic disable-next-line: inject-field
this._get_active_notifications = frame_cache.memoize(this._get_active_notifications)

return this
