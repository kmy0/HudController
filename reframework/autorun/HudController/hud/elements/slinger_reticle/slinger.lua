---@class (exact) SlingerReticleSlinger : HudChild
---@field hide_slinger_empty boolean
---@field root SlingerReticle
---@field get_config fun(): SlingerReticleSlingerConfig
---@field ctrl_getter fun(self: SlingerReticleSlinger, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?
---@field ctrl_writer (fun(self: SlingerReticleSlinger, ctrl: via.gui.Control): boolean)?
---@field reset fun(self: SlingerReticleSlinger, key: SlingerReticleSlingerWriteKey)
---@field children {}

---@class (exact) SlingerReticleSlingerConfig : HudChildConfig
---@field hide_slinger_empty boolean
---@field children {}

---@alias SlingerReticleSlingerWriteKey HudChildWriteKey | "hide_slinger_empty"

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

---@class SlingerReticleSlinger
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- ctrl = PNL_Scale
local ctrl_args = {
    slinger = {
        {
            {
                "PNL_Pat00",
                "PNL_slinger",
            },
        },
    },
}

---@param args SlingerReticleSlingerConfig
---@param parent HudBase
---@param ctrl_getter fun(self: SlingerReticleSlinger, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?
---@param ctrl_writer (fun(self: SlingerReticleSlinger, ctrl: via.gui.Control): boolean)?
---@param default_overwrite HudBaseDefaultOverwrite?
---@param gui_ignore boolean?
---@param children_sort (fun(a_key: string, b_key: string): boolean)?
---@return SlingerReticleSlinger
function this:new(args, parent, ctrl_getter, ctrl_writer, default_overwrite, gui_ignore, children_sort)
    local o = hud_child.new(self, args, parent, ctrl_getter, ctrl_writer, default_overwrite, gui_ignore, children_sort)
    o.properties = util_table.merge_t(o.properties, {
        hide_slinger_empty = true,
    })
    setmetatable(o, self)
    ---@cast o SlingerReticleSlinger

    if args.hide_slinger_empty then
        o:set_hide_slinger_empty(args.hide_slinger_empty)
    end

    return o
end

---@return boolean
function this:is_open()
    return self.root:is_GUI020000_visible() and not self.root:is_GUI020002_visible()
end

---@return boolean
function this:is_no_ammo()
    if not self.root:is_GUI020000_visible() then
        return false
    end

    local GUI020000 = self.root:get_GUI020000()
    return GUI020000:get__SetMainAmmoType() == rl(ace_enum.slinger_ammo, "NONE")
end

---@return via.gui.Control
function this:get_slinger_pnl()
    local pnl = self.root:get_GUI020000_pnl()
    return play_object.control.get(pnl, ctrl_args.slinger[1][1]) --[[@as via.gui.Control]]
end

---@protected
---@param ctrl via.gui.Control
---@return boolean
function this:_write(ctrl)
    print(self.hide_slinger_empty)
    if self.hide_slinger_empty then
        print(self:is_no_ammo())
        if self:is_no_ammo() then
            self:change_visibility(ctrl, false)
            return false
        else
            self:change_visibility(ctrl, true)
        end
    end

    return hud_child._write(self, ctrl)
end

---@param ctrl via.gui.Control
---@param key  SlingerReticleSlingerWriteKey
function this:reset_ctrl(ctrl, key)
    if self.hide_slinger_empty and (not key or key == "hide_slinger_empty") then
        self:change_visibility(ctrl, true)
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    hud_child.reset_ctrl(self, ctrl, key)
end

---@param hide boolean
function this:set_hide_slinger_empty(hide)
    self:reset("hide_slinger_empty")

    if self.hide_slinger_empty and not hide then
        self:mark_idle()
    elseif not self.hide_slinger_empty and hide then
        self:mark_write()
    end
    self.hide_slinger_empty = hide
end

---@return SlingerReticleSlingerConfig
function this.get_config()
    local base = hud_child.get_config("slinger") --[[@as SlingerReticleSlingerConfig]]
    base.hide_slinger_empty = false

    return base
end

return this
