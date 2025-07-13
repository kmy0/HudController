---@class (exact) SlingerReticle : HudBase
---@field hide_slinger_empty boolean
---@field get_config fun(): SlingerReticleConfig
---@field GUI020002 app.GUI020002
---@field GUI020000 app.GUI020000
---@field children {
--- slinger: HudChild,
--- capture: HudChild,
--- focus: HudChild,
--- }

---@class (exact) SlingerReticleConfig : HudBaseConfig
---@field hide_slinger_empty boolean
---@field children {
--- slinger: HudChildConfig,
--- capture: HudChildConfig,
--- focus: HudChildConfig,
--- }

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local util_game = require("HudController.util.game")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class SlingerReticle
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

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
    slinger_state = {
        {
            {

                "PNL_Pat00",
                "PNL_slinger",
                "PNL_slingerReticle",
            },
        },
    },
    capture = {
        {
            {
                "PNL_Pat00",
                "PNL_capture",
            },
        },
    },
}

---@param args SlingerReticleConfig
---@return SlingerReticle
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o SlingerReticle

    o.children.slinger = hud_child:new(args.children.slinger, o, function(s, hudbase, gui_id, ctrl)
        ---@cast hudbase app.GUI020000

        local state_pnl = play_object.control.get(ctrl, ctrl_args.slinger_state[1][1])
        if not state_pnl then
            return
        end

        if state_pnl:get_Visible() and not o:is_GUI020002_visible() then
            if o.hide_slinger_empty then
                if hudbase:get__SetMainAmmoType() == rl(ace_enum.slinger_ammo, "NONE") then
                    s.hide = true
                elseif not s:get_current_config().hide then
                    s:reset()
                    s.hide = false
                end
            end

            return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.slinger)
        else
            s:reset()
        end
    end)
    o.children.capture = hud_child:new(args.children.capture, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.capture)
    end)
    o.children.focus = hud_child:new(args.children.focus, o, function(s, hudbase, gui_id, ctrl)
        if o:is_GUI020002_visible() then
            local ret = play_object.iter_args(play_object.control.get, o:get_GUI020000_pnl(), ctrl_args.slinger_state)
            table.insert(ret, o:get_GUI020002_pnl())
            return ret
        else
            s:reset()
        end
    end)

    if args.hide_slinger_empty then
        o:set_hide_slinger_empty(args.hide_slinger_empty)
    end

    return o
end

---@param hide boolean
function this:set_hide_slinger_empty(hide)
    self.children.slinger:reset("hide")

    if self.hide_slinger_empty and not hide then
        if not self.children.slinger:get_current_config().hide then
            self.children.slinger.hide = hide
        end
        self.children.slinger:mark_idle()
    elseif not self.hide_slinger_empty and hide then
        self.children.slinger:mark_write()
    end
    self.hide_slinger_empty = hide
end

---@return app.GUI020002
function this:get_GUI020002()
    if not self.GUI020002 then
        self.GUI020002 = util_game.get_component_any("app.GUI020002") --[[@as app.GUI020002]]
    end

    return self.GUI020002
end

---@return app.GUI020000
function this:get_GUI020000()
    if not self.GUI020000 then
        self.GUI020000 = util_game.get_component_any("app.GUI020000") --[[@as app.GUI020000]]
    end

    return self.GUI020000
end

---@return via.gui.Control
function this:get_GUI020000_pnl()
    local disp_ctrl = self:get_GUI020000()._DisplayControl
    return disp_ctrl._TargetControl
end

---@return via.gui.Control
function this:get_GUI020002_pnl()
    local disp_ctrl = self:get_GUI020002()._DisplayControl
    return disp_ctrl._TargetControl
end

function this:is_GUI020002_visible()
    local ctrl = self:get_GUI020002_pnl()
    local gui = ctrl:get_Component()
    return gui:get_Enabled()
end

---@return SlingerReticleConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "SLINGER_RETICLE"), "SLINGER_RETICLE") --[[@as SlingerReticleConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.SLINGER_RETICLE
    base.hide_slinger_empty = false

    children.slinger = hud_child.get_config("slinger")
    children.capture = hud_child.get_config("capture")
    children.focus = hud_child.get_config("focus")

    return base
end

return this
