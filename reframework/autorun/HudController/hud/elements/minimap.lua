---@class (exact) Minimap : HudBase
---@field get_config fun(): MinimapConfig
---@field enabled_classic_minimap boolean
---@field classic_minimap ClassicMinimap
---@field default_filter integer?
---@field pl_icon_controller app.cGUIMapPlayerIconController?
---@field filter_controller app.cGUIFilteringSortPartsCtrl
---@field children {
--- background: HudChild,
--- out_frame_icon: HudChild,
--- mask: HudChild,
--- classic_minimap: HudChild,
--- front: HudChild,
--- pl_icon_pulse: HudChild,
--- }
---@field protected _get_panel fun(): via.gui.Control?
---@field protected _mask_scale Vector3f
---@field protected _mask_offset Vector3f
---@field protected _apply_filter boolean

---@class (exact) MinimapConfig : HudBaseConfig
---@field enabled_classic_minimap boolean
---@field default_filter integer?
---@field options {
--- MAP_RADAR_FIXNORTH: integer,
--- MAP_RADAR_PITCH_TYPE: integer,
--- }
---@field children {
--- background: HudChildConfig,
--- out_frame_icon: HudChildConfig,
--- mask: HudChildConfig,
--- classic_minimap: ClassicMinimapConfig,
--- front: HudChildConfig,
--- pl_icon_pulse: HudChildConfig,
--- }

---@class (exact) MinimapChangedProperties : HudBaseChangedProperties
---@field enabled_classic_minimap boolean?

---@class (exact) MinimapProperties : {[MinimapProperty]: boolean}, HudBaseProperties
---@field enabled_classic_minimap boolean

---@alias MinimapProperty HudBaseProperty | "enabled_classic_minimap" | "default_filter"
---@alias MinimapWriteKey HudBaseWriteKey | "enabled_classic_minimap"

---@class (exact) MinimapControlArguments
---@field background PlayObjectGetterFn[]
---@field out_frame_icon PlayObjectGetterFn[]
---@field out_frame_icon_rot PlayObjectGetterFn[]
---@field mask PlayObjectGetterFn[]
---@field front PlayObjectGetterFn[]

---@class (exact) ClassicMinimap
---@field fov_map number?
---@field scale_icon number?

---@class (exact) ClassicMinimapConfig : HudChildConfig
---@field enabled_fov boolean
---@field enabled_icon_scale boolean
---@field fov_map number
---@field scale_icon number

local data = require("HudController.data.init")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local m = require("HudController.util.ref.methods")
local play_object = require("HudController.hud.play_object.init")
local util_ace = require("HudController.util.ace.init")
local util_table = require("HudController.util.misc.table")
local play_object_defaults = require("HudController.hud.defaults.init").play_object
local util_mod = require("HudController.util.mod.init")

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
    mask = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_Radar",
            },
        },
    },
    front = {
        {
            play_object.control.get,
            {
                "RootWindow",
                "PNL_All",
            },
        },
    },
}
local classic_minimap_states = {
    classic_minimap = "dummy",
    mask = "dummy",
    front = "dummy",
}

---@param args MinimapConfig
---@return Minimap
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o Minimap

    o.properties = util_table.merge_t(o.properties, {
        enabled_classic_minimap = true,
        default_filter = true,
    })
    o.classic_minimap = {
        scale_icon = 1,
        fov_map = 1,
    }

    o.children.background = hud_child:new(
        args.children.background,
        o,
        function(s, hudbase, gui_id, ctrl)
            ---@diagnostic disable-next-line: invisible
            local root = o:_get_panel()
            ---@cast hudbase app.GUI060010
            if root then
                return play_object.iter_args(root, control_arguments.background)
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
        nil,
        176
    )
    o.children.classic_minimap = hud_child:new(
        args.children.classic_minimap,
        o,
        function(s, hudbase, gui_id, ctrl)
            return ctrl
        end,
        nil,
        nil,
        true,
        nil,
        nil,
        176
    )
    o.children.front = hud_child:new(args.children.front, o, function(s, hudbase, gui_id, ctrl)
        local gui = util_ace.misc.get_gui_component(hudbase)
        return play_object.iter_args(gui:get_View(), control_arguments.front)
    end, nil, nil, true, nil, nil, 176)
    o.children.mask = hud_child:new(args.children.mask, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.mask)
    end, nil, nil, true, nil, nil, 177)
    o.children.pl_icon_pulse = hud_child:new(
        args.children.pl_icon_pulse,
        o,
        function(s, hudbase, gui_id, ctrl)
            local icon_ctrl = o:get_pl_icon_controller()
            if icon_ctrl then
                local mp_icon = icon_ctrl._MasterPlayerIcon
                return play_object.control.get(mp_icon._PlIconPanel, "PNL_PLeffects")
            end
        end,
        function(s, ctrl)
            play_object_defaults:check(ctrl)

            if s.play_state then
                ctrl:set_PlayState(s.play_state)
            end

            return true
        end,
        nil,
        true,
        nil,
        nil,
        177
    )

    o._mask_scale = Vector3f.new(10, 10, 1)
    o._mask_offset = Vector3f.new(-1500, 1500, 1)
    o._apply_filter = false

    if args.enabled_classic_minimap then
        o:set_enable_classic_minimap(args.enabled_classic_minimap)
    end

    if args.children.classic_minimap.fov_map then
        o:set_classic_minimap_fov(args.children.classic_minimap.fov_map)
    end

    if args.children.classic_minimap.scale_icon then
        o:set_classic_minimap_icon_scale(args.children.classic_minimap.scale_icon)
    end

    if args.default_filter then
        o:set_default_filter(args.default_filter)
    end

    return o
end

---@param val boolean
function this:set_enable_classic_minimap(val)
    self:reset()
    self.enabled_classic_minimap = val

    if self.enabled_classic_minimap then
        self.children.mask.scale = self._mask_scale
        self.children.mask.offset = self._mask_offset
        self.children.front.hide = true
        self:set_play_states(classic_minimap_states)
    else
        self:reset_play_states(classic_minimap_states)
        self.children.mask.scale = nil
        self.children.mask.offset = nil
        self.children.front.hide = false
    end
end

---@param val number?
function this:set_classic_minimap_fov(val)
    self.classic_minimap.fov_map = val
end

---@param val number?
function this:set_classic_minimap_icon_scale(val)
    self.classic_minimap.scale_icon = val
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

---@return app.cGUIMapPlayerIconController?
function this:get_pl_icon_controller()
    if not self.pl_icon_controller then
        local GUI060002 = util_mod.get_gui_cls("app.GUI060002")
        local icon_controller = GUI060002:get_IconController()
        if icon_controller then
            self.pl_icon_controller = icon_controller._PLIconCtrl
        end
    end
    return self.pl_icon_controller
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
    if self._apply_filter and self.default_filter ~= -1 then
        local filter = self:get_filter_controller()
        m.requestMapFilter(filter, nil, nil, self.default_filter)
        self._apply_filter = false
    end

    return hud_base._write(self, ctrl)
end

---@return MinimapConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "MINIMAP"), "MINIMAP") --[[@as MinimapConfig]]
    local children = base.children
    base.hud_type = mod.enum.hud_type.MINIMAP

    base.enabled_classic_minimap = false
    base.options.MAP_RADAR_FIXNORTH = -1
    base.options.MAP_RADAR_PITCH_TYPE = -1
    base.default_filter = -1

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
    children.mask = {
        name_key = "__mask",
        scale = { x = 1, y = 1 },
        offset = { x = 0, y = 0 },
        play_state = "",
    }
    children.classic_minimap = {
        name_key = "__classic_minimap",
        play_state = "",
        enabled_fov = false,
        fov_map = 100,
        enabled_icon_scale = false,
        scale_icon = 1,
    }
    children.front = {
        name_key = "__front",
        play_state = "",
        hide = false,
    }
    children.pl_icon_pulse = {
        name_key = "__pl_icon_pulse",
        play_state = "",
        enabled_play_state = false,
    }

    return base
end

return this
