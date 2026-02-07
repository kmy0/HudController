---@class (exact) Whistle : HudChild
---@field get_config fun(): WhistleConfig
---@field children {
--- background: HudChild,
--- resonance: HudChild,
--- melody: HudChild,
--- notice: WhistleNotice,
--- perform: WhistlePerform,
---}

---@class (exact) WhistleConfig : HudChildConfig
---@field children {
--- background: HudChildConfig,
--- resonance: HudChildConfig,
--- melody: HudChildConfig,
--- notice: WhistleNoticeConfig,
--- perform: WhistlePerformConfig,
--- }

---@class (exact) WhistleControlArguments
---@field background PlayObjectGetterFn[]
---@field resonance PlayObjectGetterFn[]
---@field melody PlayObjectGetterFn[]

local e = require("HudController.util.game.enum")
local hud_child = require("HudController.hud.def.hud_child")
local notice = require("HudController.hud.elements.weapon.whistle.notice")
local perform = require("HudController.hud.elements.weapon.whistle.perform")
local play_object = require("HudController.hud.play_object.init")

---@class Whistle
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_All
---@type WhistleControlArguments
local control_arguments = {
    background = {
        {
            play_object.control.get,
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_UnderBase",
            },
        },
    },
    resonance = {
        {
            play_object.control.get,
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_Resonance",
            },
        },
    },
    melody = {
        {
            play_object.control.get,
            {
                "PNL_Scale1",
                "PNL_Pat00",
                "PNL_Melody",
            },
        },
    },
}

---@param args WhistleConfig
---@param parent HudBase
---@return Whistle
function this:new(args, parent)
    local o = hud_child.new(
        self,
        args,
        parent,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        e.get("app.GUIID.ID").UI020030
    )
    setmetatable(o, self)
    ---@cast o Whistle

    o.children.background = hud_child:new(args.children.background, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.background)
    end)
    o.children.resonance = hud_child:new(args.children.resonance, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.resonance)
    end)
    o.children.melody = hud_child:new(args.children.melody, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.melody)
    end)
    o.children.notice = notice:new(args.children.notice, o)
    o.children.perform = perform:new(args.children.perform, o)

    return o
end

---@return WhistleConfig
function this.get_config()
    local base = hud_child.get_config("WHISTLE") --[[@as WhistleConfig]]
    local children = base.children

    children.background = {
        name_key = "background",
        hide = false,
    }
    children.resonance = hud_child.get_config("resonance")
    children.melody = hud_child.get_config("melody")
    children.notice = notice.get_config()
    children.perform = perform.get_config()

    return base
end

return this
