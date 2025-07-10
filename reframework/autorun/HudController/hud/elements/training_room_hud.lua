---@class (exact) TrainingRoomHud : HudBase
---@field get_config fun(): TrainingRoomHudConfig
---@field GUI600100 app.GUI600100?
---@field children {
--- command_history: HudChild,
--- button_guide: HudChild,
--- damage: HudChild,
--- combo_guide: HudChild,
--- }

---@class (exact) TrainingRoomHudConfig : HudBaseConfig
---@field children {
--- command_history: HudChildConfig,
--- button_guide: HudChildConfig,
--- damage: HudChildConfig,
--- combo_guide: HudChildConfig,
--- }

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local util_game = require("HudController.util.game")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class TrainingRoomHud
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

local ctrl_args = {
    command_history = {
        {
            {
                "PNL_Group00",
            },
        },
    },
    button_guide = {
        {
            {
                "PNL_Group01",
            },
        },
    },
    damage = {
        {
            {
                "PNL_Group02",
            },
        },
    },
    combo_guide = {
        {
            {
                "PNL_Group03",
            },
        },
    },
}

---@param args TrainingRoomHudConfig
---@param default_overwrite HudBaseDefaultOverwrite?
---@return TrainingRoomHud
function this:new(args, default_overwrite)
    local o = hud_base.new(self, args, nil, default_overwrite)
    setmetatable(o, self)
    ---@cast o TrainingRoomHud

    o.children.command_history = hud_child:new(args.children.command_history, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.command_history)
    end)
    o.children.button_guide = hud_child:new(args.children.button_guide, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.button_guide)
    end)
    o.children.damage = hud_child:new(args.children.damage, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.damage)
    end)
    o.children.combo_guide = hud_child:new(args.children.combo_guide, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.ccombo_guide)
    end)

    return o
end

---@param key HudBaseWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    local hudbase = self:get_GUI600100()
    local pnl = self:get_pnl_all()
    self:reset_ctrl(pnl, key)
    ---@diagnostic disable-next-line: no-unknown
    util_table.do_something(self.children, function(_, _, child)
        if self.write_nodes[child] then
            ---@diagnostic disable-next-line: param-type-mismatch
            child:reset_child(hudbase, hudbase:get_ID(), pnl, key)
        end
    end)
end

---@return app.GUI600100
function this:get_GUI600100()
    if not self.GUI600100 then
        self.GUI600100 = util_game.get_component_any("app.GUI600100")
    end

    return self.GUI600100
end

---@return via.gui.Control
function this:get_pnl_all()
    local pnl = self:get_GUI600100()._TransitionGuide
    return play_object.control.get_parent(pnl, "PNL_All")
end

---@return TrainingRoomHudConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "TRAINING_ROOM_HUD"), "TRAINING_ROOM_HUD") --[[@as TrainingRoomHudConfig]]
    local children = base.children
    base.hud_type = mod.enum.hud_type.TRAINING_ROOM_HUD

    children.command_history = hud_child.get_config("command_history")
    children.button_guide = hud_child.get_config("button_guide")
    children.damage = hud_child.get_config("damage")
    children.combo_guide = hud_child.get_config("combo_guide")

    return base
end

return this
