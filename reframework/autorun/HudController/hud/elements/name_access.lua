---@class (exact) NameAccess : HudBase
---@field npc_draw_distance number
---@field GUI020001 app.GUI020001?
---@field get_config fun(): NameAccessConfig
---@field object_category table<string, boolean>
---@field gossip_type table<string, boolean>
---@field npc_type table<string, boolean>
---@field panel_type table<string, boolean>
---@field enemy_type table<string, boolean>

---@class (exact) NameAccessConfig : HudBaseConfig
---@field object_category table<string, boolean>
---@field gossip_type table<string, boolean>
---@field npc_type table<string, boolean>
---@field panel_type table<string, boolean>
---@field enemy_type table<string, boolean>
---@field npc_draw_distance number

local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local util_game = require("HudController.util.game.init")
local util_table = require("HudController.util.misc.table")

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
    o.npc_type = args.npc_type
    o.gossip_type = args.gossip_type
    o.panel_type = args.panel_type
    o.enemy_type = args.enemy_type
    o.npc_draw_distance = args.npc_draw_distance
    return o
end

---@param name_key string
---@param hide boolean
function this:set_object_category(name_key, hide)
    self.object_category[name_key] = hide
end

---@param name_key string
---@param hide boolean
function this:set_panel_type(name_key, hide)
    self.panel_type[name_key] = hide
end

---@param name_key string
---@param hide boolean
function this:set_gossip_type(name_key, hide)
    self.gossip_type[name_key] = hide
end

---@param name_key string
---@param hide boolean
function this:set_npc_type(name_key, hide)
    self.npc_type[name_key] = hide
end

---@param name_key string
---@param hide boolean
function this:set_enemy_type(name_key, hide)
    self.enemy_type[name_key] = hide
end

---@return boolean
function this:any_gossip()
    return util_table.any(self.gossip_type)
end

---@return boolean
function this:any_npc()
    return util_table.any(self.npc_type)
end

---@return boolean
function this:any_panel()
    return util_table.any(self.panel_type)
end

---@return boolean
function this:any_enemy()
    return util_table.any(self.enemy_type)
end

---@param val number
function this:set_npc_draw_distance(val)
    self.npc_draw_distance = val
end

---@return app.GUI020001?
function this:get_GUI020001()
    if not self.GUI020001 then
        self.GUI020001 = util_game.get_component_any("app.GUI020001") --[[@as app.GUI020001]]
    end

    return self.GUI020001
end

---@return NameAccessConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "NAME_ACCESSIBLE"), "NAME_ACCESSIBLE") --[[@as NameAccessConfig]]

    base.enabled_offset = nil
    base.hud_type = mod.enum.hud_type.NAME_ACCESS
    base.object_category = { ALL = false }
    base.gossip_type = {}
    base.npc_type = {}
    base.panel_type = {}
    base.npc_draw_distance = 0
    base.enemy_type = {
        BOSS = false,
        ZAKO = false,
        ANIMAL = false,
    }

    for _, name in pairs(ace_enum.object_access_category) do
        base.object_category[name] = false
    end

    for _, name in pairs(ace_enum.interact_gossip_type) do
        base.gossip_type[name] = false
    end

    for _, name in pairs(ace_enum.interact_npc_type) do
        base.npc_type[name] = false
    end

    for _, name in pairs(ace_enum.interact_panel_type) do
        base.panel_type[name] = false
    end

    return base
end

return this
