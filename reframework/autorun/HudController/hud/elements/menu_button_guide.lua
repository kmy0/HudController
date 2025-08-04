---@class (exact) MenuButtonGuide : HudBase
---@field get_config fun(): MenuButtonGuideConfig
---@field GUI000005 app.GUI000005?
---@field children {
--- tooltip: HudChild,
--- group1: HudChild,
--- group2: HudChild,
--- group3: HudChild,
--- }

---@class (exact) MenuButtonGuideConfig : HudBaseConfig
---@field children {
--- tooltip: HudChildConfig,
--- group1: HudChildConfig,
--- group2: HudChildConfig,
--- group3: HudChildConfig,
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

local ctrl_args = {
    group1 = {
        {
            {
                "PNL_All",
            },
        },
    },
    group2 = {
        {
            {
                "PNL_All_1",
            },
        },
    },
    group3 = {
        {
            {
                "PNL_All_2",
            },
        },
    },
}

---@class MenuButtonGuide
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args MenuButtonGuideConfig
---@return MenuButtonGuide
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o MenuButtonGuide

    o.children.tooltip = hud_child:new(args.children.tooltip, o, function(s, hudbase, gui_id, ctrl)
        local GUI000005 = o:get_GUI000005()
        if GUI000005 then
            return GUI000005:get_HelpPanel()
        end
    end)
    o.children.group1 = hud_child:new(args.children.group1, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.group1)
    end)
    o.children.group2 = hud_child:new(args.children.group2, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.group2)
    end)
    o.children.group3 = hud_child:new(args.children.group3, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.group3)
    end)
    return o
end

---@return app.GUI000005?
function this:get_GUI000005()
    if not self.GUI000005 then
        self.GUI000005 = util_game.get_component_any("app.GUI000005")
    end

    return self.GUI000005
end

---@param key HudBaseWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    local hudbase = util_game.get_component_any("app.GUI000008")
    if not hudbase then
        return
    end

    local ctrl = hudbase:get_Control()
    self:reset_ctrl(ctrl, key)
    ---@diagnostic disable-next-line: param-type-mismatch
    self:reset_children(hudbase, nil, ctrl, key)
end

---@return MenuButtonGuideConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "MENU_BUTTON_GUIDE"), "MENU_BUTTON_GUIDE") --[[@as MenuButtonGuideConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.MENU_BUTTON_GUIDE

    children.tooltip = hud_child.get_config("tooltip")
    children.group1 = {
        name_key = "group1",
        enabled_offset = false,
        offset = { x = 0, y = 0 },
        enabled_scale = false,
        scale = { x = 1, y = 1 },
    }
    children.group2 = {
        name_key = "group2",
        enabled_offset = false,
        offset = { x = 0, y = 0 },
        enabled_scale = false,
        scale = { x = 1, y = 1 },
    }
    children.group3 = {
        name_key = "group3",
        enabled_offset = false,
        offset = { x = 0, y = 0 },
        enabled_scale = false,
        scale = { x = 1, y = 1 },
    }
    return base
end

return this
