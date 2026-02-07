---@class (exact) ChatLogRecipient: HudChild
---@field get_config fun(): ChatLogRecipientConfig
---@field children {
--- background: HudChild,
--- text: Text,
--- }

---@class (exact) ChatLogRecipientConfig : HudChildConfig
---@field children {
--- background: HudChildConfig,
--- text: TextConfig,
--- }

---@class (exact) ChatLogRecipientControlArguments
---@field background PlayObjectGetterFn[]
---@field recipient PlayObjectGetterFn[]
---@field text PlayObjectGetterFn[]

local data = require("HudController.data.init")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")
local text = require("HudController.hud.def.text")

local mod = data.mod

---@class ChatLogRecipient
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_All
---@type ChatLogRecipientControlArguments
local control_arguments = {
    recipient = {
        {
            play_object.control.get,
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_List00",
                "PNL_SendSelect",
            },
        },
    },
    background = {
        {
            play_object.control.get,
            {
                "PNL_ref_SendSelect",
                "PNL_SendSelect",
                "PNL_blurBG_lib",
            },
        },
        {
            play_object.child.get,
            {
                "PNL_ref_SendSelect",
                "PNL_SendSelect",
                "PNL_MemberSelect",
            },
            "s9g_SendSelectBg01",
            "via.gui.Scale9Grid",
        },
    },
    text = {
        {
            play_object.child.get,
            {
                "PNL_ref_SendSelect",
                "PNL_SendSelect",
                "PNL_SendSelect00",
            },
            "txt_SendSelect",
            "via.gui.Text",
        },
    },
}

---@param args ChatLogRecipientConfig
---@param parent HudBase
---@return ChatLogRecipient
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.recipient)
    end)
    setmetatable(o, self)
    ---@cast o ChatLogRecipient

    o.children.background = hud_child:new(args.children.background, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.background)
    end)
    o.children.text = text:new(args.children.text, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text)
    end)

    return o
end

---@return ChatLogRecipientConfig
function this.get_config()
    local base = hud_child.get_config("recipient") --[[@as ChatLogRecipientConfig]]
    local children = base.children

    children.background = { name_key = "background", hide = false }
    children.text = { name_key = "text", hud_sub_type = mod.enum.hud_sub_type.TEXT, hide = false }

    return base
end

return this
