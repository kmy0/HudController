---@class (exact) ClassicMinimap : HudChild
---@field get_config fun(): ClassicMinimapConfig
---@field parent Itembar
---@field enabled_classic_minimap boolean
---@field hide_pl_pulse boolean
---@field pl_icon_controller app.cGUIMapPlayerIconController?
---@field ctrl_getter fun(self: ClassicMinimap, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?
---@field ctrl_writer (fun(self: ClassicMinimap, ctrl: via.gui.Control): boolean)?
---@field children {
--- front: HudChild,
--- mask: HudChild,
--- pl_icon_pulse: HudChild,
--- }
---@field protected _mask_scale Vector3f
---@field protected _mask_offset Vector3f

---@class (exact) ClassicMinimap
---@field fov_map number?
---@field scale_icon number?
---@field rot_map number?
---@field angle_map number?

---@class (exact) ClassicMinimapConfig : HudChildConfig
---@field enabled_classic_minimap boolean
---@field hide_pl_pulse boolean
---@field fov_map EnabledNumber
---@field scale_icon EnabledNumber
---@field rot_map EnabledNumber
---@field angle_map EnabledNumber
---@field children {
--- mask: HudChildConfig,
--- front: HudChildConfig,
--- pl_icon_pulse: HudChildConfig,
--- }

---@class (exact) ClassicMinimapArguments
---@field mask PlayObjectGetterFn[]
---@field front PlayObjectGetterFn[]

local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")
local util_ace = require("HudController.util.ace.init")
local util_mod = require("HudController.util.mod.init")
local util_table = require("HudController.util.misc.table")
local play_object_defaults = require("HudController.hud.defaults.init").play_object

---@class ClassicMinimap
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_Scale
---@type ClassicMinimapArguments
local control_arguments = {
    mask = {
        {
            play_object.control.get,
            {
                "PNL_All",
                "PNL_Scale",
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
    mask = "dummy",
    front = "dummy",
}

---@param args ClassicMinimapConfig
---@param parent Minimap
function this:new(args, parent)
    local o = hud_child:new(args, parent, function(_, _, _, ctrl)
        return ctrl
    end, { gui_ignore = true, valid_guiid = 176 })
    setmetatable(o, self)
    ---@cast o ClassicMinimap

    o.properties = util_table.merge(o.properties, {
        enabled_classic_minimap = true,
    })

    o.enabled_classic_minimap = false
    o.hide_pl_pulse = false
    o.children.front = hud_child:new(args.children.front, o, function(_, hudbase, _, _)
        local gui = util_ace.misc.get_gui_component(hudbase)
        return play_object.iter_args(gui:get_View(), control_arguments.front)
    end, { gui_ignore = true, valid_guiid = 176 })
    o.children.mask = hud_child:new(args.children.mask, o, function(_, _, _, _)
        -- guiid 177, it has to be done this way, the main write has to happen while 176 writes, otherwise for whatever reason it falls apart sometimes on scripts reset
        -- maybe race condition of some kind or whatever
        local root = util_mod.get_root_window2("app.GUI060011")
        return play_object.iter_args(root, control_arguments.mask)
    end, { gui_ignore = true, valid_guiid = 176 })
    o.children.pl_icon_pulse = hud_child:new(args.children.pl_icon_pulse, o, function(_, _, _, _)
        local icon_ctrl = o:get_pl_icon_controller()
        if icon_ctrl then
            local mp_icon = icon_ctrl._MasterPlayerIcon
            return play_object.control.get(mp_icon._PlIconPanel, "PNL_PLeffects")
        end
    end, {
        ctrl_writer = function(s, ctrl)
            play_object_defaults:check(ctrl)

            if s.play_state then
                ctrl:set_PlayState(s.play_state)
            end

            return true
        end,
        gui_ignore = true,
        valid_guiid = 177,
    })

    o._mask_scale = Vector3f.new(10, 10, 1)
    o._mask_offset = Vector3f.new(-1500, 1500, 1)

    if args.enabled_classic_minimap then
        o:set_enabled(args.enabled_classic_minimap)
    end

    if args.hide_pl_pulse then
        o:set_hide_pl_pulse(args.hide_pl_pulse)
    end

    if args.fov_map and args.fov_map.enabled then
        o:set_fov(args.fov_map)
    end

    if args.scale_icon and args.scale_icon.enabled then
        o:set_icon_scale(args.scale_icon)
    end

    if args.rot_map and args.rot_map.enabled then
        o:set_rot(args.rot_map)
    end

    if args.angle_map and args.angle_map.enabled then
        o:set_angle(args.angle_map)
    end

    return o
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

---@param val boolean
function this:set_enabled(val)
    self.enabled_classic_minimap = val

    if self.enabled_classic_minimap then
        self.play_state = "dummy"
        self:mark_write("play_state")

        self.children.mask.scale = self._mask_scale
        self.children.mask.offset = self._mask_offset
        self.children.front.hide = true
        self:set_play_states(classic_minimap_states)
    else
        self:reset_play_states(classic_minimap_states)
        self.children.mask.scale = nil
        self.children.mask.offset = nil
        self.children.front.hide = false

        self:reset("play_state")
        self.play_state = nil
        self:mark_idle("play_state")
    end
end

---@param val boolean
function this:set_hide_pl_pulse(val)
    self.hide_pl_pulse = val

    if self.hide_pl_pulse then
        self.children.pl_icon_pulse:set_play_state({ enabled = true, value = "DISABLE" })
    else
        self.children.pl_icon_pulse:set_play_state()
    end
end

---@param val EnabledNumber?
function this:set_fov(val)
    if val and val.enabled then
        self.fov_map = val.value
    else
        self.fov_map = nil
    end
end

---@param val EnabledNumber?
function this:set_icon_scale(val)
    if val and val.enabled then
        self.scale_icon = val.value
    else
        self.scale_icon = nil
    end
end

---@param val EnabledNumber?
function this:set_rot(val)
    if val and val.enabled then
        self.rot_map = val.value
    else
        self.rot_map = nil
    end
end

---@param val EnabledNumber?
function this:set_angle(val)
    if val and val.enabled then
        self.angle_map = val.value
    else
        self.angle_map = nil
    end
end

---@return ClassicMinimapConfig
function this.get_config()
    local base = {
        name_key = "__classic_minimap",
        enabled_classic_minimap = false,
        hide_pl_pulse = false,
        children = {},
        options = {},
        play_state = { enabled = false, value = "" },
        fov_map = { enabled = false, value = 100 },
        scale_icon = { enabled = false, value = 1 },
        rot_map = { enabled = false, value = 0 },
        angle_map = { enabled = false, value = 0 },
    } --[[@as ClassicMinimapConfig]]
    local children = base.children

    children.front = {
        name_key = "__front",
        play_state = { enabled = false, value = "" },
        hide = false,
    }
    children.mask = {
        name_key = "__mask",
        scale = { enabled = false, x = 1, y = 1 },
        offset = { enabled = false, x = 0, y = 0 },
        play_state = { enabled = false, value = "" },
    }
    children.pl_icon_pulse = {
        name_key = "__pl_icon_pulse",
        play_state = { enabled = false, value = "" },
    }

    return base
end

return this
