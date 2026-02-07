---@class (exact) Tachi : HudChild
---@field get_config fun(): TachiConfig
---@field children {
--- background: HudChild,
---}

---@class (exact) TachiConfig : HudChildConfig
---@field children {background: HudChildConfig}

---@class (exact) TachiControlArguments
---@field background PlayObjectGetterFn[]

local e = require("HudController.util.game.enum")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")

---@class Tachi
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_Scale
---@type TachiControlArguments
local control_arguments = {
    background = {
        {
            play_object.control.get,
            {
                "PNL_PNL_Pat00",
                "PNL_LS_HUD",
                "PNL_LS_Gauge",
                "PNL_Base",
            },
        },
    },
}

---@param args TachiConfig
---@param parent HudBase
---@return Tachi
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
        e.get("app.GUIID.ID").UI020023
    )
    setmetatable(o, self)
    ---@cast o Tachi

    o.children.background = hud_child:new(args.children.background, o, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.background)
    end)

    return o
end

---@return TachiConfig
function this.get_config()
    local base = hud_child.get_config("TACHI") --[[@as TachiConfig]]
    local children = base.children

    children.background = {
        name_key = "background",
        hide = false,
    }

    return base
end

return this
