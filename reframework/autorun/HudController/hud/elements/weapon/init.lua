---@class (exact) Weapon : HudBase
---@field get_config fun(): WeaponConfig
---@field no_focus boolean
---@field children {
--- charge_axe: ChargeAxe,
--- tachi: Tachi,
--- twin_sword: TwinSword,
--- whistle: Whistle,
--- gun_lance: GunLance,
--- slash_axe: SlashAxe,
--- rod: Rod,
--- no_focus: HudChild,
--- }

---@class (exact) WeaponConfig : HudBaseConfig
---@field no_focus boolean
---@field children {
--- charge_axe: ChargeAxeConfig,
--- tachi: TachiConfig,
--- twin_sword: TwinSwordConfig,
--- whistle: WhistleConfig,
--- gun_lance: GunLanceConfig,
--- slash_axe: SlashAxeConfig,
--- rod: RodConfig,
--- no_focus: HudChildConfig,
--- }

local charge_axe = require("HudController.hud.elements.weapon.charge_axe")
local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local gun_lance = require("HudController.hud.elements.weapon.gun_lance")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local rod = require("HudController.hud.elements.weapon.rod")
local slash_axe = require("HudController.hud.elements.weapon.slash_axe")
local tachi = require("HudController.hud.elements.weapon.tachi")
local twin_sword = require("HudController.hud.elements.weapon.twin_sword")
local whistle = require("HudController.hud.elements.weapon.whistle.init")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Weapon
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args WeaponConfig
---@return Weapon
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Weapon

    o.children.charge_axe = charge_axe:new(args.children.charge_axe, o)
    o.children.tachi = tachi:new(args.children.tachi, o)
    o.children.twin_sword = twin_sword:new(args.children.twin_sword, o)
    o.children.whistle = whistle:new(args.children.whistle, o)
    o.children.gun_lance = gun_lance:new(args.children.gun_lance, o)
    o.children.slash_axe = slash_axe:new(args.children.slash_axe, o)
    o.children.rod = rod:new(args.children.rod, o)
    o.children.no_focus = hud_child:new(
        args.children.no_focus,
        o,
        function(s, hudbase, gui_id, ctrl)
            return ctrl
        end,
        nil,
        nil,
        true,
        nil,
        true
    )

    o:set_no_focus(args.no_focus)
    return o
end

---@param no_focus boolean
function this:set_no_focus(no_focus)
    self.no_focus = no_focus
    if no_focus then
        self.children.no_focus:set_play_state("DEFAULT")
    else
        self.children.no_focus:set_play_state()
    end
end

---@return WeaponConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "WEAPON"), "WEAPON") --[[@as WeaponConfig]]
    local children = base.children
    base.hud_type = mod.enum.hud_type.WEAPON
    base.no_focus = false

    children.no_focus = { name_key = "__no_focus", enabled_play_state = false, play_state = "" }
    children.charge_axe = charge_axe.get_config()
    children.tachi = tachi.get_config()
    children.twin_sword = twin_sword.get_config()
    children.whistle = whistle.get_config()
    children.gun_lance = gun_lance.get_config()
    children.slash_axe = slash_axe.get_config()
    children.rod = rod.get_config()

    return base
end

return this
