---@class (exact) HealthMaxFall : HudChild
---@field get_config fun(): HealthMaxFallConfig
---@field children {
--- timer: HudChild,
--- point: HudChild,
--- }

---@class (exact) HealthMaxFallConfig : HudChildConfig
---@field children {
--- timer: HudChildConfig,
--- point: HudChildConfig,
--- }

---@class (exact) HealthMaxFallControlArguments
---@field point PlayObjectGetterFn[]
---@field timer PlayObjectGetterFn[]

local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

---@class HealthMaxFall
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

---@type HealthMaxFallControlArguments
local control_arguments = {
    timer = {
        {
            play_object.control.get,
            {
                "PNL_MaxFallTextAnim",
            },
        },
    },
    point = {
        {
            play_object.control.get,
            {
                "PNL_stepMaxFallPoint",
            },
        },
    },
}

---@param args HealthMaxFallConfig
---@param parent Health
---@param ctrl_getter fun(self: HudChild, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): PlayObject[] | PlayObject?
---@return HealthMaxFall
function this:new(args, parent, ctrl_getter)
    local o = hud_child.new(self, args, parent, ctrl_getter)
    setmetatable(o, self)
    ---@cast o HealthMaxFall

    o.children.timer = hud_child:new(args.children.timer, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.timer)
    end)
    o.children.point = hud_child:new(args.children.point, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.point)
    end)

    return o
end

---@return HealthMaxFallConfig
function this.get_config()
    local base = hud_child.get_config("max_fall") --[[@as HealthMaxFallConfig]]
    local children = base.children

    children.timer = hud_child.get_config("timer")
    children.point = {
        name_key = "point",
        hide = false,
    }

    return base
end

return this
