---@class (exact) BarrelScoreName : HudChild
---@field get_config fun(): BarrelScoreNameConfig
---@field children {
--- background: HudChild,
--- }

---@class (exact) BarrelScoreNameConfig : HudChildConfig
---@field children {
--- background: HudChildConfig,
--- }

---@class (exact) BarrelScoreNameControlArguments
---@field guide PlayObjectGetterFn[]
---@field background PlayObjectGetterFn[]

local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

---@class BarrelScoreName
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_Scale
---@type BarrelScoreNameControlArguments
local control_arguments = {
    guide = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_Guide",
            },
        },
    },
    background = {
        {
            play_object.control.get,
            {
                "PNL_Base",
            },
        },
    },
}

---@param args BarrelScoreNameConfig
---@param parent BarrelScore
---@return BarrelScoreName
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.guide)
    end)
    setmetatable(o, self)

    ---@cast o BarrelScoreName
    o.children.background = hud_child:new(
        args.children.background,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.background)
        end
    )

    return o
end

---@return BarrelScoreNameConfig
function this.get_config()
    local base = hud_child.get_config("name") --[[@as BarrelScoreNameConfig]]
    local children = base.children

    children.background = { name_key = "background", hide = false }

    return base
end

return this
