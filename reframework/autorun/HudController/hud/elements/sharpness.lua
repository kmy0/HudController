---@class (exact) Sharpness : HudBase
---@field get_config fun(): SharpnessConfig
---@field children {anim_max: HudChild}

---@class (exact) SharpnessConfig : HudBaseConfig
---@field options {AUTO_SCALING_SHARPNESS: integer}
---@field children {anim_max: HudChildConfig}

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Sharpness
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- ctrl = PNL_Scale
local ctrl_args = {
    anim_max = {
        {
            {
                "PNL_Pat00",
                "PNL_allRotate",
                "PNL_gaugeMode00Over",
                "PNL_MaxLightMove",
                "PNL_MaxLight",
            },
        },
    },
}

---@param args SharpnessConfig
---@return Sharpness
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Sharpness

    o.children.anim_max = hud_child:new(args.children.anim_max, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.anim_max)
    end)

    return o
end

---@return SharpnessConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "SHARPNESS"), "SHARPNESS") --[[@as SharpnessConfig]]
    local children = base.children
    base.options.AUTO_SCALING_SHARPNESS = -1
    base.hud_type = mod.enum.hud_type.SHARPNESS

    children.anim_max = { name_key = "anim_max", hide = false }

    return base
end

return this
