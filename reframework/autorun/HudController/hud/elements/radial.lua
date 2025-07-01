---@class (exact) Radial : HudBase
---@field get_config fun(): RadialConfig
---@field children {pallet: HudChild}

---@class (exact) RadialConfig : HudBaseConfig
---@field children {pallet: HudChildConfig}

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Radial
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- ctrl = PNL_Scale
local ctrl_args = {
    pallet = {
        {
            {
                "PNL_PalletInOut",
            },
        },
    },
}

---@param args RadialConfig
---@return Radial
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Radial

    o.children.pallet = hud_child:new(args.children.pallet, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.pallet)
    end)
    return o
end

---@return RadialConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "SHORTCUT_GAMEPAD"), "SHORTCUT_GAMEPAD") --[[@as RadialConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.RADIAL

    children.pallet = hud_child.get_config("pallet")

    return base
end

return this
