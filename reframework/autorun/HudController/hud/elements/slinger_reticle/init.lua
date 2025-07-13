---@class (exact) SlingerReticle : HudBase
---@field get_config fun(): SlingerReticleConfig
---@field GUI020002 app.GUI020002
---@field GUI020000 app.GUI020000
---@field children {
--- slinger: SlingerReticleSlinger,
--- capture: HudChild,
--- focus: SlingerReticleFocus,
--- }

---@class (exact) SlingerReticleConfig : HudBaseConfig
---@field children {
--- slinger: SlingerReticleSlingerConfig,
--- capture: HudChildConfig,
--- focus: SlingerReticleFocusConfig,
--- }

local data = require("HudController.data")
local focus = require("HudController.hud.elements.slinger_reticle.focus")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local slinger = require("HudController.hud.elements.slinger_reticle.slinger")
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

    o.children.slinger = slinger:new(args.children.slinger, o, function(s, hudbase, gui_id, ctrl)
        ---@cast s SlingerReticleSlinger

        if s:is_open() then
            return s:get_slinger_pnl()
        else
            s:reset()
        end
    end)

    o.children.capture = hud_child:new(args.children.capture, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.capture)
    end)
    o.children.focus = focus:new(args.children.focus, o)

    return o
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

---@return boolean
function this:is_GUI020002_visible()
    local ctrl = self:get_GUI020002_pnl()
    local gui = ctrl:get_Component()
    return gui:get_Enabled()
end

---@return boolean
function this:is_GUI020000_visible()
    local ctrl = self:get_GUI020000_pnl()
    local pnl = play_object.control.get(ctrl, ctrl_args.slinger_state[1][1]) --[[@as via.gui.Control]]
    return pnl:get_Visible()
end

---@return SlingerReticleConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "SLINGER_RETICLE"), "SLINGER_RETICLE") --[[@as SlingerReticleConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.SLINGER_RETICLE

    children.slinger = slinger.get_config()
    children.capture = hud_child.get_config("capture")
    children.focus = focus.get_config()

    return base
end

return this
