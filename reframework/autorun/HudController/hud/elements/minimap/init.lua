---@class (exact) Minimap : HudBase
---@field get_config fun(): MinimapConfig
---@field default_filter integer?
---@field filter_controller app.cGUIFilteringSortPartsCtrl
---@field children {
--- background: HudChild,
--- out_frame_icon: HudChild,
--- classic_minimap: ClassicMinimap,
--- }
---@field protected _get_panel fun(): via.gui.Control?
---@field protected _apply_filter boolean

---@class (exact) MinimapConfig : HudBaseConfig
---@field default_filter integer?
---@field children {
--- background: HudChildConfig,
--- out_frame_icon: HudChildConfig,
--- classic_minimap: ClassicMinimapConfig,
--- }

---@class (exact) MinimapChangedProperties : HudBaseChangedProperties
---@class (exact) MinimapProperties : {[MinimapProperty]: boolean}, HudBaseProperties

---@alias MinimapProperty HudBaseProperty | "default_filter"
---@alias MinimapWriteKey HudBaseWriteKey

---@class (exact) MinimapControlArguments
---@field background PlayObjectGetterFn[]
---@field out_frame_icon PlayObjectGetterFn[]
---@field out_frame_icon_rot PlayObjectGetterFn[]

local classic = require("HudController.hud.elements.minimap.classic")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local m = require("HudController.util.ref.methods")
local play_object = require("HudController.hud.play_object.init")
local util_mod = require("HudController.util.mod.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

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

    o.properties = util_table.merge(o.properties, {
        default_filter = true,
    })

    o.children.background = hud_child:new(args.children.background, o, function(_, _, _, _)
        ---@diagnostic disable-next-line: invisible
        local root = o:_get_panel()
        if root then
            return play_object.iter_args(root, control_arguments.background)
        end
    end, { no_cache = true })
    o.children.out_frame_icon = hud_child:new(
        args.children.out_frame_icon,
        o,
        function(_, _, _, ctrl)
            local icons = play_object.iter_args(ctrl, control_arguments.out_frame_icon)
            return play_object.iter_args(icons, control_arguments.out_frame_icon_rot)
        end,
        { valid_guiid = 176 }
    )
    o.children.classic_minimap = classic:new(args.children.classic_minimap, o)

    o._apply_filter = false

    if args.default_filter then
        o:set_default_filter(args.default_filter)
    end

    return o
end

---@param val integer?
function this:set_default_filter(val)
    if val == -1 then
        val = nil
    end

    self.default_filter = val
    if self.default_filter then
        self._apply_filter = true
    end
end

---@protected
---@return via.gui.Control?
function this._get_panel()
    local GUI060001 = util_mod.get_gui_cls("app.GUI060001")
    return util_mod.get_root_window(GUI060001)
end

---@return app.cGUIFilteringSortPartsCtrl
function this:get_filter_controller()
    if not self.filter_controller then
        local GUI060101 = util_mod.get_gui_cls("app.GUI060101")
        local filter_list = GUI060101._FilterList
        self.filter_controller = filter_list._FilteringPartsCtrl
    end

    return self.filter_controller
end

---@protected
---@param ctrl via.gui.Control
---@return boolean
function this:_write(ctrl)
    if self._apply_filter and self.default_filter and self.default_filter ~= -1 then
        local filter = self:get_filter_controller()
        m.requestMapFilter(filter, nil, nil, self.default_filter)
        self._apply_filter = false
    end

    return hud_base._write(self, ctrl)
end

---@param self HudBase?
---@return string[]
function this.get_boolean_config_keys(self)
    local t = {}

    if not self then
        return t
    end

    return util_table.merge(hud_child.get_boolean_config_keys(self), t)
end

---@return MinimapConfig
function this.get_config()
    local base = hud_base.get_config(e.get("app.GUIHudDef.TYPE").MINIMAP, "MINIMAP") --[[@as MinimapConfig]]
    local children = base.children
    base.hud_type = mod.enum.hud_type.MINIMAP
    base.default_filter = -1

    children.background = {
        name_key = "background",
        hide = false,
        offset = { enabled = false, x = 0, y = 0 },
    }
    children.out_frame_icon = {
        name_key = "out_frame_icon",
        hide = false,
        rot = { enabled = false, value = 0 },
    }
    children.classic_minimap = classic.get_config()

    return base
end

return this
