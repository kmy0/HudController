---@class (exact) NameAccess : HudBase
---@field get_config fun(): NameAccessConfig
---@field object_category table<string, boolean>

---@class (exact) NameAccessConfig : HudBaseConfig
---@field object_category table<string, boolean>

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class NameAccess
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args NameAccessConfig
---@return NameAccess
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o NameAccess

    o.object_category = args.object_category
    return o
end

---@param name_key string
---@param hide boolean
function this:set_object_category(name_key, hide)
    self.object_category[name_key] = hide
end

---@return NameAccessConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "NAME_ACCESSIBLE"), "NAME_ACCESSIBLE") --[[@as NameAccessConfig]]

    base.hud_type = mod.enum.hud_type.NAME_ACCESS
    base.object_category = { ALL = false }

    for _, name in pairs(ace_enum.object_access_category) do
        base.object_category[name] = false
    end

    return base
end

return this
