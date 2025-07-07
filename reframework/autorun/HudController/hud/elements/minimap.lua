---@class (exact) Minimap : HudBase
---@field get_config fun(): MinimapConfig
---@field children {background: HudChild}
---@field protected _get_panel fun(): via.gui.Control?

---@class (exact) MinimapConfig : HudBaseConfig
---@field children {background: HudChildConfig}

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local s = require("HudController.util.ref.singletons")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Minimap
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

local ctrl_args = {
    background = {
        {
            {
                "PNL_All",
                "PNL_BackLayer",
                "PNL_background_black",
            },
        },
    },
}

---@param args MinimapConfig
---@param default_overwrite HudBaseDefaultOverwrite?
---@return Minimap
function this:new(args, default_overwrite)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Minimap

    o.children.background = hud_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        local root = play_object.control.from_func(self._get_panel) --[[@as via.gui.Control?]]
        ---@cast hudbase app.GUI060010
        if root then
            if not hudbase:get_IsActive() then
                s:reset()
            else
                return play_object.iter_args(play_object.control.get, root, ctrl_args.background)
            end
        end
    end)

    return o
end

---@protected
---@return via.gui.Control?
function this._get_panel()
    local map3d = s.get("app.GUIManager"):get_MAP3D()
    local GUI060001 = map3d:get_GUIBack()
    return GUI060001._RootWindow
end

---@return MinimapConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "MINIMAP"), "MINIMAP") --[[@as MinimapConfig]]
    local children = base.children
    base.hud_type = mod.enum.hud_type.MINIMAP

    children.background = {
        name_key = "background",
        hide = false,
        enabled_offset = false,
        offset = { x = 0, y = 0 },
    }

    return base
end

return this
