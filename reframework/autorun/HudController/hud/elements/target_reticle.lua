---@class (exact) TargetReticle : HudBase
---@field get_config fun(): TargetReticleConfig

---@class (exact) TargetReticleConfig : HudBaseConfig

local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local util_game = require("HudController.util.game.init")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class TargetReticle
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args TargetReticleConfig
---@return TargetReticle
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o TargetReticle

    return o
end

---@param key HudBaseWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    local hudbase = util_game.get_component_any("app.GUI020021")
    if not hudbase then
        return
    end

    local ctrl = hudbase:get__Main()
    self:reset_ctrl(ctrl, key)
    ---@diagnostic disable-next-line: param-type-mismatch
    self:reset_children(hudbase, nil, ctrl, key)
end

---@return TargetReticleConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "TARGET_RETICLE"), "TARGET_RETICLE") --[[@as TargetReticleConfig]]
    base.hud_type = mod.enum.hud_type.TARGET_RETICLE
    return base
end

return this
