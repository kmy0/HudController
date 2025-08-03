---@class (exact) MenuButtonGuide : HudBase
---@field get_config fun(): MenuButtonGuideConfig
---@field GUI000005 app.GUI000005?
---@field children {
--- tooltip: HudChild,
--- }

---@class (exact) MenuButtonGuideConfig : HudBaseConfig
---@field children {
--- tooltip: HudChildConfig,
--- }

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local util_game = require("HudController.util.game")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

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

    local children_keys = self:get_children_keys()
    for i = 1, #children_keys do
        local child = self.children[children_keys[i]]
        if self.write_nodes[child] then
            ---@diagnostic disable-next-line: param-type-mismatch
            child:reset_child(hudbase, nil, ctrl, key)
        end
    end
end

---@return MenuButtonGuideConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "MENU_BUTTON_GUIDE"), "MENU_BUTTON_GUIDE") --[[@as MenuButtonGuideConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.MENU_BUTTON_GUIDE

    children.tooltip = hud_child.get_config("tooltip")

    return base
end

return this
