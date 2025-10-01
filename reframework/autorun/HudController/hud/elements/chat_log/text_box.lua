---@class (exact) ChatLogTextBox: HudChild
---@field get_config fun(): ChatLogTextBoxConfig
---@field children {
--- background: Scale9,
--- new_message: HudChild,
--- text: Text,
--- }

---@class (exact) ChatLogTextBoxConfig : HudChildConfig
---@field children {
--- background: Scale9Config,
--- new_message: HudChildConfig,
--- text: TextConfig,
--- }

---@class (exact) ChatLogTextBoxControlArguments
---@field background PlayObjectGetterFn[]
---@field text_box PlayObjectGetterFn[]
---@field text PlayObjectGetterFn[]

local data = require("HudController.data.init")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")
local scale9 = require("HudController.hud.def.scale9")
local text = require("HudController.hud.def.text")

local mod = data.mod

---@class ChatLogTextBox
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_All
---@type ChatLogTextBoxControlArguments
local control_arguments = {
    text_box = {
        {
            play_object.control.get,
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_inputfoam",
            },
        },
    },
    background = {
        {
            play_object.child.get,
            {},
            "s9g_InputBg00",
            "via.gui.Scale9Grid",
        },
        {
            play_object.child.get,
            {
                "PNL_ref_inputForm00",
                "PNL_ConvertList00",
            },
            "s9g_inputBg00",
            "via.gui.Scale9Grid",
        },
        {
            play_object.child.get,
            {
                "PNL_ref_inputForm00",
                "PNL_inputBg00",
            },
            "s9g_InputBg00",
            "via.gui.Scale9Grid",
        },
    },
    new_message = {
        {
            play_object.control.get,
            {
                "PNL_inputfoam_New",
            },
        },
    },
    text = {
        {
            play_object.child.all_type,
            nil,
            "via.gui.Text",
        },
    },
}

---@param args ChatLogTextBoxConfig
---@param parent HudBase
---@return ChatLogTextBox
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text_box)
    end)
    setmetatable(o, self)
    ---@cast o ChatLogTextBox

    o.children.background = scale9:new(
        args.children.background,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.background)
        end
    )
    o.children.new_message = hud_child:new(
        args.children.new_message,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.new_message)
        end
    )
    o.children.text = text:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text)
    end)

    return o
end

---@return ChatLogTextBoxConfig
function this.get_config()
    local base = hud_child.get_config("text_box") --[[@as ChatLogTextBoxConfig]]
    local children = base.children

    base.enabled_opacity = nil
    base.opacity = nil
    children.background = {
        name_key = "background",
        hide = false,
        hud_sub_type = mod.enum.hud_sub_type.SCALE9,
        enabled_color = false,
        color = 0,
        enabled_alpha_channel = false,
        alpha_channel = "None",
    }
    children.new_message = {
        name_key = "new_message",
        hide = false,
    }
    children.text = {
        name_key = "text",
        hud_sub_type = mod.enum.hud_sub_type.TEXT,
        color = 0,
        enabled_color = false,
    }

    return base
end

return this
