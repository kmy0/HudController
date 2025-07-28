---@class (exact) Minimap : HudBase
---@field get_config fun(): MinimapConfig
---@field children {
--- background: HudChild,
--- out_frame_icon: HudChild,
--- }
---@field protected _get_panel fun(): via.gui.Control?

---@class (exact) MinimapConfig : HudBaseConfig
---@field children {
--- background: HudChildConfig,
--- out_frame_icon: HudChildConfig,
--- }

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local s = require("HudController.util.ref.singletons")
local util_table = require("HudController.util.misc.table")

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
    out_frame_icon = {
        {
            {
                "PNL_Pat00",
                "PNL_Radar",
                "PNL_OutFrameIconMain",
            },
            "PNL_OutFrameIcon00",
            true,
        },
    },
    ["out_frame_icon.rot"] = {
        {
            {
                "PNL_OutFrame_rot",
                "PNL_OutFrame_pos",
                "PNL_OutFrame_posY",
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
        local root = self:_get_panel()
        ---@cast hudbase app.GUI060010
        if root then
            if not hudbase:get_IsActive() then
                s:reset()
            else
                return play_object.iter_args(play_object.control.get, root, ctrl_args.background)
            end
        end
    end)
    o.children.out_frame_icon = hud_child:new(args.children.out_frame_icon, o, function(s, hudbase, gui_id, ctrl)
        local ret = {}
        local icons = play_object.iter_args(play_object.control.all, ctrl, ctrl_args.out_frame_icon)

        for _, icon in pairs(icons) do
            ---@cast icon via.gui.Control
            util_table.array_merge_t(
                ret,
                play_object.iter_args(play_object.control.get, icon, ctrl_args["out_frame_icon.rot"])
            )
        end

        return ret
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
    children.out_frame_icon = {
        name_key = "out_frame_icon",
        hide = false,
        enabled_rot = false,
        rot = { x = 0, y = 0, z = 0 },
    }

    return base
end

return this
