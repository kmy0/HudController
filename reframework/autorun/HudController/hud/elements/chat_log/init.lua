---@class (exact) ChatLog : HudBase
---@field get_config fun(): ChatLogConfig
---@field GUI000008 app.GUI000008?
---@field children {
--- button_guide: HudChild,
--- background: HudChild,
--- keybind: HudChild,
--- list: HudChild,
--- new_message: HudChild,
--- filter: ChatLogFilter,
--- recipient: ChatLogRecipient,
--- text_box: ChatLogTextBox,
--- }

---@class (exact) ChatLogConfig : HudBaseConfig
---@field children {
--- button_guide: HudChildConfig,
--- background: HudChildConfig,
--- keybind: HudChildConfig,
--- list: HudChildConfig,
--- new_message: HudChildConfig,
--- filter: ChatLogFilterConfig,
--- recipient: ChatLogRecipientConfig,
--- text_box: ChatLogTextBoxConfig,
--- }

---@class (exact) ChatLogControlArguments
---@field background PlayObjectGetterFn[]
---@field keybind PlayObjectGetterFn[]
---@field list PlayObjectGetterFn[]
---@field new_message PlayObjectGetterFn[]

local data = require("HudController.data.init")
local filter = require("HudController.hud.elements.chat_log.filter")
local frame_cache = require("HudController.util.misc.frame_cache")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")
local recipient = require("HudController.hud.elements.chat_log.recipient")
local text_box = require("HudController.hud.elements.chat_log.text_box")
local util_mod = require("HudController.util.mod.init")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class ChatLog
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- PNL_All
---@type ChatLogControlArguments
local control_arguments = {
    background = {
        {
            play_object.control.get,
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_List00",
                "PNL_ref_window05",
            },
        },
    },
    list = {
        {
            play_object.control.get,
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_List00",
                "FSL_List00",
            },
        },
    },
    new_message = {
        {
            play_object.control.get,
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_List00",
                "PNL_Newmessage",
            },
        },
    },
    keybind = {
        {
            play_object.control.get,
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_filtering",
                "PNL_ref_filtering",
                "PNL_filtering",
                "PNL_ref_Key_S00",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_List00",
                "PNL_SendSelect",
                "PNL_ref_SendSelect",
                "PNL_SendSelect",
                "PNL_SendSelect00",
                "PNL_ref_Key_S00",
            },
        },
    },
}

---@param args ChatLogConfig
---@return ChatLog
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o ChatLog

    o.get_all_panel = frame_cache.memoize(o.get_all_panel)

    o.children.button_guide = hud_child:new(
        args.children.button_guide,
        o,
        function(s, hudbase, gui_id, ctrl)
            local GUI000008 = o:get_GUI000008()
            if GUI000008 then
                return play_object.control.get(GUI000008._RootWindow, "PNL_All")
            end
        end
    )
    o.children.recipient = recipient:new(args.children.recipient, o)
    o.children.text_box = text_box:new(args.children.text_box, o)
    o.children.filter = filter:new(args.children.filter, o)
    o.children.background = hud_child:new(
        args.children.background,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.background)
        end
    )
    o.children.list = hud_child:new(args.children.list, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.list)
    end)
    o.children.new_message = hud_child:new(
        args.children.new_message,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.new_message)
        end
    )
    o.children.keybind = hud_child:new(args.children.keybind, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.keybind)
    end)
    return o
end

---@param key HudBaseWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    local GUI020101 = util_mod.get_gui_cls("app.GUI020101")
    if not GUI020101 then
        return
    end

    local pnl = self:get_all_panel(GUI020101)
    self:reset_ctrl(pnl, key)
    ---@diagnostic disable-next-line: param-type-mismatch
    self:reset_children(GUI020101, GUI020101:get_ID(), pnl, key)
end

---@return app.GUI000008?
function this:get_GUI000008()
    if not self.GUI000008 then
        self.GUI000008 = util_mod.get_gui_cls("app.GUI000008")
    end

    return self.GUI000008
end

---@param hudbase app.GUI020101
---@return via.gui.Control
function this:get_all_panel(hudbase)
    local root = hudbase._RootWindow
    return play_object.control.get(root, "PNL_All") --[[@as via.gui.Control]]
end

---@return ChatLogConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "CHAT_LOG"), "CHAT_LOG") --[[@as ChatLogConfig]]
    local children = base.children
    base.hud_type = mod.enum.hud_type.CHAT_LOG

    children.recipient = recipient.get_config()
    children.text_box = text_box.get_config()
    children.filter = filter.get_config()
    children.list = hud_child.get_config("list")
    children.new_message = hud_child.get_config("new_message")
    children.background = { name_key = "background", hide = false }
    children.keybind = { name_key = "keybind", hide = false }
    children.button_guide = {
        name_key = "button_guide",
        enabled_offset = false,
        offset = { x = 0, y = 0 },
    }

    return base
end

return this
