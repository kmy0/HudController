---@class (exact) NameOther : HudBase
---@field get_config fun(): NameOtherConfig
---@field nameplate_type table<string, boolean>

---@class (exact) NameOtherConfig : HudBaseConfig
---@field nameplate_type table<string, boolean>

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class NameOther
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args NameOtherConfig
---@return NameOther
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o NameOther

    o.nameplate_type = args.nameplate_type
    return o
end

---@param name_key string
---@param hide boolean
function this:set_nameplate_type(name_key, hide)
    self.nameplate_type[name_key] = hide
end

---@return NameOtherConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "NAME_OTHER"), "NAME_OTHER") --[[@as NameOtherConfig]]

    base.hud_type = mod.enum.hud_type.NAME_OTHER
    base.nameplate_type = { ALL = false }

    for _, name in pairs(ace_enum.nameplate_type) do
        base.nameplate_type[name] = false
    end

    return base
end

return this
