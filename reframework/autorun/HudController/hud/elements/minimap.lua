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

---@class (exact) MinimapControlArguments
---@field background PlayObjectGetterFn[]
---@field out_frame_icon PlayObjectGetterFn[]
---@field out_frame_icon_rot PlayObjectGetterFn[]

local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")
local s = require("HudController.util.ref.singletons")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Minimap
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@type MinimapControlArguments
local control_arguments = {
    -- RootWindow
    background = {
        {
            play_object.control.get,
            {
                "PNL_All",
                "PNL_BackLayer",
                "PNL_background_black",
            },
        },
    },
    -- PNL_Scale
    out_frame_icon = {
        {
            play_object.control.all,
            {
                "PNL_Pat00",
                "PNL_Radar",
                "PNL_OutFrameIconMain",
            },
            "PNL_OutFrameIcon00",
            true,
        },
    },
    -- PNL_OutFrameIcon00
    out_frame_icon_rot = {
        {
            play_object.control.get,
            {
                "PNL_OutFrame_rot",
                "PNL_OutFrame_pos",
                "PNL_OutFrame_posY",
            },
        },
    },
}

---@param args MinimapConfig
---@return Minimap
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Minimap

    o.children.background = hud_child:new(
        args.children.background,
        o,
        function(s, hudbase, gui_id, ctrl)
            local root = self:_get_panel()
            ---@cast hudbase app.GUI060010
            if root then
                if not hudbase:get_IsActive() then
                    s:reset()
                else
                    return play_object.iter_args(root, control_arguments.background)
                end
            end
        end,
        nil,
        nil,
        nil,
        nil,
        true
    )
    o.children.out_frame_icon = hud_child:new(
        args.children.out_frame_icon,
        o,
        function(s, hudbase, gui_id, ctrl)
            local icons = play_object.iter_args(ctrl, control_arguments.out_frame_icon)
            return play_object.iter_args(icons, control_arguments.out_frame_icon_rot)
        end,
        nil,
        nil,
        nil,
        nil,
        true
    )

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
        rot = 0,
    }

    return base
end

return this
