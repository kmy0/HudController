---@class (exact) HudChild : HudBase
---@field parent HudBase | HudChild
---@field type nil
---@field hud_id nil
---@field properties HudChildProperties
---@field ctrl_getter fun(self: HudChild, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?)
---@field ctrl_writer (fun(self: HudChild, ctrl: via.gui.Control): boolean)?
---@field get_config fun(name_key: string): HudChildConfig
---@field valid_guiid table<app.GUIID.ID, boolean>? when set, ctrl_getter ignores all guiids except these
---@field protected _getter_cache via.gui.Control[]

---@class (exact) HudChildConfig : HudBaseConfig
---@field scale {x:number, y:number}?
---@field offset {x:number, y:number}?
---@field rot number?
---@field opacity number?
---@field segment string?
---@field hide boolean?
---@field enabled_scale boolean?
---@field enabled_offset boolean?
---@field enabled_rot boolean?
---@field enabled_opacity boolean?
---@field enabled_segment boolean?
---@field key nil
---@field hud_id nil
---@field hud_type nil
---@field hud_sub_type nil
---@field gui_thing string? if thing is the only option within child tree node wont be drawn
---@field profile nil
---@field current_profile nil
---@field current_profile_gui nil
---@field enabled nil
---@field default_profile nil

---@class (exact) HudChildDefault : HudBaseDefault
---@class (excat) HudChildDefaultOverwrite : HudBaseDefaultOverwrite
---@class (exact) HudChildChangedProperties : HudBaseChangedProperties
---@class (exact) HudChildProperties : {[HudChildProperty]: boolean}, HudBaseProperties

---@class (exact) HudChildOptionalArgs : HudBaseOptionalArgs
---@field no_cache boolean? by_default, false - if true cache via.gui.Control objects
---@field valid_guiid (app.GUIID.ID | app.GUIID.ID[])? when set, ctrl_getter ignores all guiids except these
---@field cache_index integer? by_default, 1
---@field ctrl_writer (fun(self: HudChild, ctrl: via.gui.Control): boolean)? when set, ctrl_writer is used instead of hud_base._write

---@alias HudChildProperty HudBaseProperty
---@alias HudChildWriteKey HudBaseWriteKey

local cache = require("HudController.util.misc.cache")
local config = require("HudController.config.init")
local frame_cache = require("HudController.util.misc.frame_cache")
local hud_base = require("HudController.hud.def.hud_base")
local hud_debug_log = require("HudController.hud.debug.log")
local mod = require("HudController.data.mod")
local util_misc = require("HudController.util.misc.init")
local util_ref = require("HudController.util.ref.init")
local util_table = require("HudController.util.misc.table")

---@class HudChild
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args HudChildConfig
---@param parent HudBase | HudChild
---@param ctrl_getter (fun(self: HudChild, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?)?
---@param optional_args HudChildOptionalArgs?
---@return HudChild
function this:new(args, parent, ctrl_getter, optional_args)
    optional_args = optional_args or {}

    local o = hud_base.new(self, args, parent, optional_args)
    setmetatable(o, self)
    ---@cast o HudChild

    local config_debug = config.debug.current.debug
    if
        not optional_args.no_cache
        and config_debug.combo_elem_cache ~= mod.enum.elem_cache.DISABLED
    then
        if config_debug.combo_elem_cache == mod.enum.elem_cache.FRAME then
            o._ctrl_getter = frame_cache.memoize(o._ctrl_getter, {
                max_frame = config_debug.slider_frame,
                jitter = config_debug.slider_jitter,
                cache_index = optional_args.cache_index,
            })
        elseif config_debug.combo_elem_cache == mod.enum.elem_cache.ONCE then
            o._ctrl_getter = cache.memoize(o._ctrl_getter, nil, {
                cache_index = optional_args.cache_index,
            })
        end
    end

    o.ctrl_getter = ctrl_getter or function(_, _, _, ctrl)
        return ctrl
    end
    o.ctrl_writer = optional_args.ctrl_writer
    o._getter_cache = {}

    if optional_args.valid_guiid then
        local valid_guiid = optional_args.valid_guiid
        o.valid_guiid = {}

        if type(valid_guiid) == "number" then
            o.valid_guiid[valid_guiid] = true
        else
            for _, guiid in
                pairs(valid_guiid --[==[@as app.GUIID.ID[]]==])
            do
                o.valid_guiid[guiid] = true
            end
        end
    end
    return o
end

---@protected
---@param ctrl via.gui.Control
---@return boolean
function this:_write(ctrl)
    if self.ctrl_writer then
        return self:ctrl_writer(ctrl)
    end
    return hud_base._write(self, ctrl)
end

---@protected
---@param hudbase app.GUIHudBase
---@param gui_id app.GUIID.ID
---@param ctrls via.gui.Control[]
---@return via.gui.Control[]
function this:_ctrl_getter(hudbase, gui_id, ctrls)
    ---@type via.gui.Control[]
    local ret = {}
    for _, ctrl in pairs(ctrls) do
        local res = self:ctrl_getter(hudbase, gui_id, ctrl)

        if not res then
            if config.debug.current.debug.is_debug then
                hud_debug_log.log(
                    string.format(
                        "Ctrl getter failed!\nGame Class: %s,\nName Chain: %s,\nClass Chain: %s,\nCtrl: %s",
                        util_ref.whoami(hudbase),
                        self:whoami(),
                        self:whoami_cls(),
                        ctrl:get_Name()
                    ),
                    hud_debug_log.log_debug_type.CONTROL_GETTER
                )
            end

            goto continue
        end

        if type(res) == "table" then
            util_table.array_merge(ret, res)
        else
            table.insert(ret, res)
        end
        ::continue::
    end

    if not util_table.empty(ret) then
        self._getter_cache = ret
    end

    return ret
end

function this:cache_clear()
    util_misc.try(function()
        ---@diagnostic disable-next-line: undefined-field
        self._ctrl_getter.clear()
    end)
end

---@param key HudChildWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    for _, ctrl in pairs(self._getter_cache) do
        self:reset_ctrl(ctrl, key)
    end
end

---@param hudbase app.GUIHudBase
---@param gui_id app.GUIID.ID
---@param ctrl via.gui.Control | via.gui.Control[]
---@param key HudChildWriteKey
function this:reset_child(hudbase, gui_id, ctrl, key)
    if not self.initialized then
        return
    end

    if self.valid_guiid and not self.valid_guiid[gui_id] then
        return
    end

    if type(ctrl) ~= "table" then
        ctrl = { ctrl }
    end

    local child_ctrls = self:_ctrl_getter(hudbase, gui_id, ctrl)
    for _, c in pairs(child_ctrls) do
        if config.debug.current.debug.is_debug then
            if c:get_reference_count() <= 0 then
                hud_debug_log.log(
                    string.format(
                        "Dead Control object!\nName Chain: %s,\nClass Chain: %s",
                        self:whoami(),
                        self:whoami_cls()
                    ),
                    hud_debug_log.log_debug_type.CACHE
                )
            end
        end

        self:reset_ctrl(c, key)
    end

    self:reset_children(hudbase, gui_id, child_ctrls, key)
end

---@param hudbase app.GUIHudBase
---@param gui_id app.GUIID.ID
---@param ctrl via.gui.Control | via.gui.Control[]
function this:write_child(hudbase, gui_id, ctrl)
    if self.valid_guiid and not self.valid_guiid[gui_id] then
        return
    end

    if type(ctrl) ~= "table" then
        ctrl = { ctrl }
    end

    local any = self:any()
    local child_ctrls = {}
    for _, c in pairs(self:_ctrl_getter(hudbase, gui_id, ctrl)) do
        -- a node can be in write_nodes purely because a descendant has something to write, not itself.
        -- in that case any() is false and we skip _write entirely but still pass the ctrl down so children can write to it.
        -- if any() is true, _write is called and returns false when propagation should stop (e.g. hidden node without hide_write),
        -- filtering that ctrl out so children won't write to it either.
        if not any or self:_write(c) then
            table.insert(child_ctrls, c)
        end
    end

    if util_table.empty(child_ctrls) then
        return
    end

    self:write_children(hudbase, gui_id, child_ctrls)
end

---@param name_key string
---@return HudChildConfig
function this.get_config(name_key)
    return {
        enabled_offset = false,
        enabled_rot = false,
        enabled_scale = false,
        enabled_opacity = false,
        enabled_segment = false,
        segment = "HUD",
        hide = false,
        scale = { x = 1, y = 1 },
        offset = { x = 0, y = 0 },
        rot = 0,
        opacity = 1,
        children = {},
        options = {},
        name_key = name_key,
    }
end

return this
