---@class (exact) ShortcutKeyboardPrepare : HudChild
---@field get_config fun(): ShortcutKeyboardPrepareConfig
---@field children {
--- arrow: HudChild,
--- background: HudChild,
--- item_background: HudChild,
--- }

---@class (exact) ShortcutKeyboardPrepareConfig : HudChildConfig
---@field children {
--- arrow: HudChildConfig,
--- background: HudChildConfig,
--- item_background: HudChildConfig,
--- }

---@class (exact) ShortcutKeyboardPrepareControlArguments
---@field arrow PlayObjectGetterFn[]
---@field background PlayObjectGetterFn[]
---@field item_background PlayObjectGetterFn[]
---@field prepare PlayObjectGetterFn[]

local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

---@class ShortcutKeyboardPrepare
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

---@type ShortcutKeyboardPrepareControlArguments
local control_arguments = {
    text = {
        {
            play_object.control.get,
            {
                "PNL_ref_Key_S02",
            },
        },
    },
    background = {
        {
            play_object.control.get,
            {
                "PNL_ref_window08",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_Group00",
                "PNL_ref_window01",
            },
        },
    },
    item_background = {
        {
            play_object.control.get,
            {
                "PNL_Group00",
                "PNL_craftMaterial",
                "SCG_List00",
                "ITM_ref_button00",
                "PNL_ItemPanelBase",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_Group00",
                "PNL_craftMaterial",
                "SCG_List00",
                "item1",
                "PNL_ItemPanelBase",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_Group00",
                "PNL_craftResult",
                "SCG_List02",
                "ITM_ref_button02",
                "PNL_ItemPanelBase",
            },
        },
    },
    arrow = {
        {
            play_object.control.get,
            {
                "PNL_Group00",
                "PNL_craftResult",
                "PNL_craftInfo",
            },
        },
    },
    prepare = {
        {
            play_object.control.get,
            {
                "PNL_preparation",
            },
        },
    },
}

---@param args ShortcutKeyboardPrepareConfig
---@param parent ShortcutKeyboard
---@return ShortcutKeyboardPrepare
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.prepare)
    end)
    setmetatable(o, self)
    ---@cast o ShortcutKeyboardPrepare

    o.children.background = hud_child:new(
        args.children.background,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.background)
        end
    )
    o.children.item_background = hud_child:new(
        args.children.item_background,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.item_background)
        end
    )
    o.children.arrow = hud_child:new(args.children.arrow, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.arrow)
    end)

    return o
end

---@return ShortcutKeyboardPrepareConfig
function this.get_config()
    local base = hud_child.get_config("craft") --[[@as ShortcutKeyboardPrepareConfig]]
    local children = base.children

    children.background = {
        name_key = "background",
        hide = false,
    }
    children.item_background = {
        name_key = "item_background",
        hide = false,
    }
    children.arrow = {
        name_key = "arrow",
        hide = false,
    }

    return base
end

return this
