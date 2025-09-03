---@class (exact) WhistleNotice : HudChild
---@field get_config fun(): WhistleNoticeConfig
---@field children {
--- arrow: CtrlChild,
--- }

---@class (exact) WhistleNoticeConfig : HudChildConfig
---@field children {
--- arrow: CtrlChildConfig,
--- }

---@class (exact) WhistleNoticeControlArguments
---@field arrow PlayObjectGetterFn[]

local ctrl_child = require("HudController.hud.def.ctrl_child")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

---@class WhistleNotice
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

---@type WhistleNoticeControlArguments
local control_arguments = {
    arrow = {
        {
            play_object.child.get,
            {
                "PNL_Notice00",
                "PNL_NoticeAnim",
            },
            "tex_arrow",
            "via.gui.Texture",
        },
        {
            play_object.child.get,
            {
                "PNL_Notice01",
                "PNL_NoticeAnim",
            },
            "tex_arrow",
            "via.gui.Texture",
        },
    },
}

---@param args WhistleNoticeConfig
---@param parent Whistle
---@param ctrl_getter fun(self: HudChild, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?
---@return WhistleNotice
function this:new(args, parent, ctrl_getter)
    local o = hud_child.new(self, args, parent, ctrl_getter)
    setmetatable(o, self)
    ---@cast o WhistleNotice

    o.children.arrow = ctrl_child:new(args.children.arrow, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.arrow)
    end)

    return o
end

---@return WhistleNoticeConfig
function this.get_config()
    local base = hud_child.get_config("notice") --[[@as WhistleNoticeConfig]]
    local children = base.children

    children.arrow = { name_key = "arrow", hide = false }

    return base
end

return this
