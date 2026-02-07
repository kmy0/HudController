---@class (exact) WhistlePerform : HudChild
---@field get_config fun(): WhistlePerformConfig
---@field children {
--- melody1: HudChild,
--- melody2: HudChild,
--- melody3: HudChild,
--- arrow: HudChild,
--- }

---@class (exact) WhistlePerformConfig : HudChildConfig
---@field children {
--- melody1: HudChildConfig,
--- melody2: HudChildConfig,
--- melody3: HudChildConfig,
--- arrow: HudChildConfig,
--- }

---@class (exact) WhistlePerformControlArguments
---@field melody PlayObjectGetterFn[]
---@field arrow PlayObjectGetterFn[]
---@field perform PlayObjectGetterFn[]

local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")

---@class WhistlePerform
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

---@type WhistlePerformControlArguments
local control_arguments = {
    melody = {
        {
            play_object.control.all,
            {},
            "PNL_PMelody",
            true,
        },
    },
    arrow = {
        {
            play_object.control.get,
            {
                "PNL_arrow",
            },
        },
    },
    perform = {
        {
            play_object.control.get,
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_Perform",
            },
        },
    },
}

---@param args WhistlePerformConfig
---@param parent Whistle
---@return WhistlePerform
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(_, _, _, ctrl)
        return play_object.iter_args(ctrl, control_arguments.perform)
    end)
    setmetatable(o, self)
    ---@cast o WhistlePerform

    for i = 1, 3 do
        o.children["melody" .. i] = hud_child:new(
            args.children["melody" .. i],
            o,
            function(_, _, _, ctrl)
                return play_object.control.get(ctrl, "PNL_PMelody0" .. i - 1)
            end
        )
    end
    o.children.arrow = hud_child:new(args.children.arrow, o, function(_, _, _, ctrl)
        local melody = play_object.iter_args(ctrl, control_arguments.melody)
        return play_object.iter_args(melody, control_arguments.arrow)
    end)

    return o
end

---@return WhistlePerformConfig
function this.get_config()
    local base = hud_child.get_config("perform") --[[@as WhistlePerformConfig]]
    local children = base.children

    for i = 1, 3 do
        children["melody" .. i] = hud_child.get_config("melody" .. i)
    end
    children.arrow = hud_child.get_config("arrow")

    return base
end

return this
