---@class (exact) NameOther : HudBase
---@field get_config fun(): NameOtherConfig
---@field nameplate_type table<string, boolean>
---@field pl_draw_distance number
---@field pet_draw_distance number

---@class (exact) NameOtherConfig : HudBaseConfig
---@field nameplate_type table<string, boolean>
---@field pl_draw_distance number
---@field pet_draw_distance number

local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local hud_base = require("HudController.hud.def.hud_base")

local mod = data.mod

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
    o.pl_draw_distance = args.pl_draw_distance
    o.pet_draw_distance = args.pet_draw_distance
    return o
end

---@param val number
function this:set_pl_draw_distance(val)
    self.pl_draw_distance = val
end

---@param val number
function this:set_pet_draw_distance(val)
    self.pet_draw_distance = val
end

---@param name_key string
---@param hide boolean
function this:set_nameplate_type(name_key, hide)
    self.nameplate_type[name_key] = hide
end

---@return NameOtherConfig
function this.get_config()
    local base = hud_base.get_config(e.get("app.GUIHudDef.TYPE").NAME_OTHER, "NAME_OTHER") --[[@as NameOtherConfig]]

    base.hud_type = mod.enum.hud_type.NAME_OTHER
    base.nameplate_type = { ALL = false }
    base.pl_draw_distance = 0
    base.pet_draw_distance = 0

    for name, _ in e.iter("app.cGUIMemberPartsDef.MemberType") do
        base.nameplate_type[name] = false
    end

    return base
end

return this
