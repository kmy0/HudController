---@class (exact) HudBase
---@field hud_id app.GUIHudDef.TYPE
---@field type HudType
---@field sub_type HudSubType
---@field name_key string
---@field scale Vector3f?
---@field offset Vector3f?
---@field rot Vector3f?
---@field opacity number?
---@field color_scale via.Float4?
---@field hide boolean?
---@field hide_write boolean? write other settings when hidden
---@field hide_changed boolean
---@field play_state string?
---@field segment app.GUIDefApp.DRAW_SEGMENT?
---@field default_overwrite HudBaseDefaultOverwrite?
---@field parent HudBase
---@field root HudBase
---@field children table<string, HudChild>
---@field write_nodes table<HudBase, integer>
---@field write_properies table<HudBaseProperty, boolean>
---@field options table<string, integer>
---@field initialized boolean
---@field properties HudBaseProperties
---@field gui_ignore boolean? --dont draw gui for this element
---@field gui_header_children boolean? --draw children with collapsed header instead of tree
---@field children_sort (fun(a_key: string, b_key: string): boolean)?
---@field apply_option fun(option_name: string, option_value: integer)
---@field get_config fun(hud_id: app.GUIHudDef.TYPE, name_key: string): HudBaseConfig
---@field restore_all_force_invis fun()

---@class (exact) HudBaseConfig
---@field name_key string
---@field key integer
---@field hud_id app.GUIHudDef.TYPE
---@field hud_type HudType
---@field hud_sub_type HudSubType
---@field scale {x:number, y:number}
---@field offset {x:number, y:number}
---@field segment string
---@field rot number
---@field opacity number
---@field hide boolean
---@field play_state string?
---@field color_scale {x:number, y:number, z:number}?
---@field enabled_scale boolean
---@field enabled_offset boolean
---@field enabled_rot boolean
---@field enabled_opacity boolean
---@field enabled_segment boolean
---@field enabled_play_state boolean?
---@field enabled_color_scale boolean?
---@field options table<string, integer>?
---@field children table<string, HudChildConfig>?

---@class (exact) HudBaseDefault
---@field scale {x:number, y:number}
---@field offset {x:number, y:number}
---@field rot number
---@field opacity number
---@field hide boolean
---@field play_state string
---@field color_scale {x:number, y:number, z:number}
---@field segment string
---@field display string?

---@class (exact) HudBaseDefaultOverwrite
---@field scale {x:number, y:number}?
---@field offset {x:number, y:number}?
---@field rot number?
---@field opacity number?
---@field hide boolean?
---@field play_state string?
---@field color_scale {x:number, y:number, z:number}?
---@field display string?
---@field segment string?

---@class (exact) HudBaseProperties : {[HudBaseProperty]: boolean}
---@field scale boolean
---@field offset boolean
---@field rot boolean
---@field opacity boolean
---@field color_scale boolean
---@field hide boolean
---@field play_state boolean
---@field segment boolean

---@class (exact) HudBaseChangedProperties : {[HudBaseProperty]: any}
---@field scale Vector3f?
---@field offset Vector3f?
---@field rot Vector3f?
---@field opacity number?
---@field color_scale via.Float4?
---@field hide boolean?
---@field play_state string?
---@field segment app.GUIDefApp.DRAW_SEGMENT?

---@alias HudBaseProperty "scale" | "offset" | "rot" | "opacity" | "hide" | "play_state" | "color_scale" | "segment"
---@alias HudBaseWriteKey HudBaseProperty | "dummy"?

local ace_misc = require("HudController.util.ace.misc")
local ace_player = require("HudController.util.ace.player")
local call_queue = require("HudController.hud.call_queue")
local config = require("HudController.config")
local data = require("HudController.data")
local defaults = require("HudController.hud.defaults")
local fade_manager = require("HudController.hud.fade")
local frame_counter = require("HudController.util.misc.frame_counter")
local game_data = require("HudController.util.game.data")
local hud_debug_log = require("HudController.hud.debug.log")
local m = require("HudController.util.ref.methods")
local play_object = require("HudController.hud.play_object")
local play_object_defaults = require("HudController.hud.defaults.play_object")
local util_ref = require("HudController.util.ref")
local util_table = require("HudController.util.misc.table")
---@module"HudController.hud"
local hud

local ace_enum = data.ace.enum
local ace_map = data.ace.map
local mod = data.mod
local rl = game_data.reverse_lookup

---@class HudBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param args HudBaseConfig | HudChildConfig
---@param parent HudBase | HudChild?
---@param default_overwrite HudBaseDefaultOverwrite?
---@param gui_ignore boolean?
---@param gui_header_children boolean?
---@param children_sort (fun(a_key: string, b_key: string): boolean)?
---@return HudBase
function this:new(args, parent, default_overwrite, gui_ignore, gui_header_children, children_sort)
    local o = {
        hud_id = args.hud_id,
        name_key = args.name_key,
        type = args.hud_type,
        sub_type = args.hud_sub_type or mod.enum.hud_sub_type.BASE,
        parent = parent,
        children = {},
        options = {},
        write_nodes = {},
        write_properies = {},
        properties = {
            scale = true,
            offset = true,
            rot = true,
            opacity = true,
            color_scale = true,
            hide = true,
            play_state = true,
        },
        initialized = false,
        default_overwrite = default_overwrite,
        gui_ignore = gui_ignore,
        gui_header_children = gui_header_children,
        children_sort = children_sort,
    }
    setmetatable(o, self)
    ---@cast o HudBase

    o.root = o:get_root()

    o:set_hide(args.hide)
    if args.enabled_scale then
        o:set_scale(args.scale)
    end

    if args.enabled_offset then
        o:set_offset(args.offset)
    end

    if args.enabled_rot then
        o:set_rot(args.rot)
    end

    if args.enabled_opacity then
        o:set_opacity(args.opacity)
    end

    if args.enabled_play_state then
        o:set_play_state(args.play_state)
    end

    if args.enabled_color_scale then
        o:set_color_scale(args.color_scale)
    end

    if args.enabled_segment then
        o:set_segment(args.segment)
    end

    for option, value in pairs(args.options or {}) do
        o:set_option(option, value)
    end

    o.hide_changed = true
    if
        o.hud_id
        and not o.hide
        and ace_enum.hud_display[ace_misc.get_hud_manager():getHudDisplay(o.hud_id)] == "HIDDEN"
    then
        ---@diagnostic disable-next-line: param-type-mismatch
        o:change_visibility(nil, true, "DEFAULT")
    end

    o.initialized = true
    return o
end

---@param option_name string
---@param option_value integer
function this:set_option(option_name, option_value)
    self.options[option_name] = option_value
    this.apply_option(option_name, option_value)
end

---@param scale {x:number, y:number, z:number}?
function this:set_color_scale(scale)
    if scale then
        self.color_scale = util_ref.value_type("via.Float4")
        self.color_scale.x = scale.x
        self.color_scale.y = scale.y
        self.color_scale.z = scale.z
        self:mark_write("color_scale")
    else
        self:reset("color_scale")
        self.color_scale = scale
        self:mark_idle("color_scale")
    end
end

---@param scale {x:number, y:number}?
function this:set_scale(scale)
    if scale then
        self.scale = Vector3f.new(scale.x, scale.y, 0)
        self:mark_write("scale")
    else
        self:reset("scale")
        self.scale = scale
        self:mark_idle("scale")
    end
end

---@param segment string?
function this:set_segment(segment)
    if segment then
        self.segment = rl(ace_enum.draw_segment, segment)
        self:mark_write("segment")
    else
        self:reset("segment")
        self.segment = segment
        self:mark_idle("segment")
    end
end

---@param offset {x:number, y:number}?
function this:set_offset(offset)
    if offset then
        self:mark_write("offset")
        self.offset = Vector3f.new(offset.x, offset.y, 0)
    else
        self:reset("offset")
        self.offset = offset
        self:mark_idle("offset")
    end
end

---@param rot number?
function this:set_rot(rot)
    if rot then
        self:mark_write("rot")
        self.rot = Vector3f.new(0, 0, rot)
    else
        self:reset("rot")
        self.rot = rot
        self:mark_idle("rot")
    end
end

---@param hide boolean
function this:set_hide(hide)
    self.hide_changed = hide ~= self.hide
    self:reset("hide")

    if self.hide and not hide then
        self:mark_idle("hide")
    elseif not self.hide and hide then
        self:mark_write("hide")
    end
    self.hide = hide
end

---@param opacity number?
function this:set_opacity(opacity)
    if opacity then
        self:mark_write("opacity")
        self.opacity = opacity
    else
        self:reset("opacity")
        self.opacity = opacity
        self:mark_idle("opacity")
    end
end

---@param play_state string?
function this:set_play_state(play_state)
    if play_state then
        self:mark_write("play_state")
        self.play_state = play_state
    else
        self:reset("play_state")
        self.play_state = play_state
        self:mark_idle("play_state")
    end
end

---@return string
function this:whoami()
    local ret = { self.name_key }
    local parent = self.parent

    while parent do
        table.insert(ret, 1, parent.name_key)
        parent = parent.parent
    end

    return table.concat(ret, ".")
end

---@return string
function this:whoami_cls()
    local function get_cls_file(cls)
        local info = debug.getinfo(cls.new, "S")
        local source = info.source
        ---@type string[]
        local path_parts = {}

        for part in source:gmatch("[^/\\]+") do
            table.insert(path_parts, part)
        end

        local filename = path_parts[#path_parts]
        if filename == "init.lua" and #path_parts > 1 then
            return path_parts[#path_parts - 1]
        else
            return filename:gsub("%.lua$", "")
        end
    end

    ---@type string[]
    local chain = {}
    ---@type table<HudBase, boolean>
    local seen = {}
    ---@type table<string, boolean>
    local seen_file = {}
    local cls = self

    while cls and type(cls) == "table" and not seen[cls] do
        seen[cls] = true

        local file = get_cls_file(cls)
        if not seen_file[file] then
            table.insert(chain, 1, file)
            seen_file[file] = true
        end

        local mt = getmetatable(cls)
        if mt and type(mt.__index) == "table" then
            ---@diagnostic disable-next-line: no-unknown
            cls = mt.__index
        else
            break
        end
    end

    return table.concat(chain, ".")
end

---@param key HudBaseProperty
function this:mark_write(key)
    if self.write_properies[key] then
        return
    end

    self.write_properies[key] = true
    self:_mark_write()
end

---@param key HudBaseProperty
function this:mark_idle(key)
    if not self.write_properies[key] then
        return
    end

    self.write_properies[key] = nil
    self:_mark_idle()
end

---@protected
function this:_mark_write()
    if not self.parent then
        return
    end

    if self.parent.write_nodes[self] then
        self.parent.write_nodes[self] = self.parent.write_nodes[self] + 1
    else
        self.parent.write_nodes[self] = 1
    end

    self.parent:_mark_write()
end

---@protected
function this:_mark_idle()
    if not self.parent then
        return
    end

    if self.parent.write_nodes[self] then
        self.parent.write_nodes[self] = self.parent.write_nodes[self] - 1
    end

    if self.parent.write_nodes[self] == 0 then
        self.parent.write_nodes[self] = nil
    end

    self.parent:_mark_idle()
end

---@param option_name string
---@param option_value integer
function this.apply_option(option_name, option_value)
    local option_data = ace_map.option[option_name]
    if not option_data then
        return
    end

    if option_value == -1 then
        local default = defaults.option.get_default(option_data.id)

        if not default then
            return
        end

        option_value = default
    else
        defaults.option.check(option_data.id)
    end

    m.setOptionValue(option_data.id, option_value)
end

---@param ctrl via.gui.Control
---@param visible boolean
---@param hud_display string?
function this:change_visibility(ctrl, visible, hud_display)
    if self.hud_id and ace_map.hudid_to_can_hide[self.hud_id] then
        if not visible then
            ace_misc.get_hud_manager():setHudDisplay(self.hud_id, rl(ace_enum.hud_display, "HIDDEN"))
        elseif visible and hud_display then
            hud_display = hud_display ~= "HIDDEN" and hud_display or "DEFAULT"
            ace_misc.get_hud_manager():setHudDisplay(self.hud_id, rl(ace_enum.hud_display, hud_display))
        else
            ace_misc.get_hud_manager():setHudDisplay(self.hud_id, rl(ace_enum.hud_display, "DEFAULT"))
        end

        -- hiding root till FADE_IN or FADE_OUT finishes, there doesn't seem to be a way to instantly finish those
        -- specific playstates without breaking everything
        if
            ctrl
            and self.hide_changed
            -- ignore when game is force revealing item bar or ammo bar

            and not (
                (self.name_key == "SLIDER_BULLET" or self.name_key == "SLIDER_ITEM")
                and ace_player.check_continue_flag(rl(ace_enum.hunter_continue_flag, "OPEN_ITEM_SLIDER"))
            )
        then
            local root_window = play_object.control.get_parent(ctrl, "RootWindow", true)

            if root_window then
                root_window:set_ForceInvisible(true)
                local frame = frame_counter.frame
                local frame_max = 6

                local function restore_vis()
                    if self:_is_fade_state_finished(root_window) or frame_counter.frame - frame >= frame_max then
                        root_window:set_ForceInvisible(false)
                    else
                        call_queue.queue_func_next(self.hud_id, restore_vis)
                    end
                end

                call_queue.queue_func(self.hud_id, restore_vis)
            end
        end
    else
        ctrl:set_ForceInvisible(not visible)
    end

    self.hide_changed = false
end

---@return {ctrl: via.gui.Control, hud_base: app.GUIHudBase, gui_id: app.GUIID.ID}[]
function this:get_all_ctrl()
    ---@type {ctrl: via.gui.Control, hud_base: app.GUIHudBase, gui_id: app.GUIID.ID}[]
    local ret = {}
    local hudman = ace_misc.get_hud_manager()

    for _, gui_id in pairs(ace_map.hudid_to_guiid[self.hud_id]) do
        local disp_ctrl = hudman:findDisplayControl(gui_id)
        if not disp_ctrl then
            goto continue
        end

        table.insert(ret, { ctrl = disp_ctrl._TargetControl, hud_base = disp_ctrl:get_Owner(), gui_id = gui_id })
        ::continue::
    end

    if config.debug.current.debug.is_debug and #ret > 1 then
        local hudbase = util_table.values(ret, function(o)
            return util_ref.whoami(o.hud_base)
        end) --[=[@as string[]]=]
        hud_debug_log.log(
            string.format(
                "More than one Game Class\nGame Classes: %s,\nName Chain: %s,\nClass Chain: %s,\nHud Type: %s",
                table.concat(hudbase, ", "),
                self:whoami(),
                self:whoami_cls(),
                ace_enum.hud[self.hud_id]
            ),
            hud_debug_log.log_debug_type.GAME_CLASS
        )
    end

    return ret
end

---@return HudBase
function this:get_root()
    if self.root then
        return self.root
    end

    local parent = self.parent
    local ret = parent
    while parent do
        parent = parent.parent
        if parent then
            ret = parent
        end
    end

    if not ret then
        ret = self
    end

    self.root = ret
    return ret
end

---@return boolean
function this:any()
    return util_table.any(self.properties, function(key, value)
        if self[key] then
            return true
        end
        return false
    end)
end

---@return boolean
function this:any_gui()
    return self:any()
end

---@return HudBaseChangedProperties
function this:get_changed()
    ---@type HudBaseChangedProperties
    local ret = {}
    for k, _ in pairs(self.properties) do
        if self[k] then
            ret[k] = self[k]
        end
    end
    return ret
end

---@return string[]
function this:get_children_keys()
    local keys = util_table.keys(self.children)
    if self.children_sort then
        return util_table.sort(keys, self.children_sort)
    end
    return keys
end

---@param key HudBaseWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    for _, args in pairs(self:get_all_ctrl()) do
        self:reset_ctrl(args.ctrl, key)
        self:reset_children(args.hud_base, args.gui_id, args.ctrl, key)
    end
end
---@param hudbase app.GUIHudBase
---@param gui_id app.GUIID.ID
---@param ctrl via.gui.Control
---@param key HudBaseWriteKey
function this:reset_specific(hudbase, gui_id, ctrl, key)
    if not self.initialized then
        return
    end

    self:reset_ctrl(ctrl, key)
    self:reset_children(hudbase, gui_id, ctrl, key)
end

---@param hudbase app.GUIHudBase
---@param gui_id app.GUIID.ID
---@param ctrl via.gui.Control | via.gui.Control[]
---@param key HudBaseWriteKey
function this:reset_children(hudbase, gui_id, ctrl, key)
    local children_keys = self:get_children_keys()
    for i = 1, #children_keys do
        local child = self.children[children_keys[i]]
        if self.write_nodes[child] then
            child:reset_child(hudbase, gui_id, ctrl, key)
        end
    end
end

---@param ctrl via.gui.Control
---@param key HudBaseWriteKey
function this:reset_ctrl(ctrl, key)
    local default = play_object_defaults.get_default(ctrl)
    if default then
        default = util_table.merge_t(default, self.default_overwrite or {})
    else
        ---@diagnostic disable-next-line: cast-local-type
        default = self.default_overwrite or {} --[[@as HudBaseDefaultOverwrite]]
    end

    if self.hide and (not key or key == "hide") and default.hide ~= nil then
        --FIXME: hide_changed = true here?
        self:change_visibility(ctrl, not default.hide, default.display)

        if self.hud_id and not fade_manager.is_active() then
            fade_manager.restore_opacity(self.hud_id, ctrl)
        end
    end

    if self.scale and (not key or key == "scale") and default.scale then
        ctrl:set_Scale(Vector3f.new(default.scale.x, default.scale.y, 0))
    end

    if self.offset and (not key or key == "offset") and default.offset then
        ctrl:set_Position(Vector3f.new(default.offset.x, default.offset.y, 0))
    end

    if self.rot and (not key or key == "rot") and default.rot then
        ctrl:set_Rotation(Vector3f.new(0, 0, default.rot))
    end

    if self.play_state and (not key or key == "play_state") and default.play_state then
        ctrl:set_PlayState(default.play_state)
    end

    if self.opacity and (not key or key == "opacity") and default.opacity then
        self:_set_opacity(ctrl, default.opacity)
    end

    if self.color_scale and (not key or key == "color_scale") and default.color_scale then
        local color_scale = ctrl:get_ColorScale()
        color_scale.x = default.color_scale.x
        color_scale.y = default.color_scale.y
        color_scale.z = default.color_scale.z
        ctrl:set_ColorScale(color_scale)
    end

    if self.segment and (not key or key == "segment") and default.segment then
        ctrl:set_Segment(rl(ace_enum.draw_segment, default.segment))
    end

    if not key then
        self:reset_options()
    end
end

function this:reset_options()
    for k, _ in pairs(self.options) do
        self.apply_option(k, -1)
    end
end

---@param hudbase app.GUIHudBase
---@param gui_id app.GUIID.ID
---@param ctrl via.gui.Control
function this:write(hudbase, gui_id, ctrl)
    if self:any() and not self:_write(ctrl) then
        return
    end

    self:write_children(hudbase, gui_id, ctrl)
end

---@param hudbase app.GUIHudBase
---@param gui_id app.GUIID.ID
---@param ctrl via.gui.Control | via.gui.Control[]
function this:write_children(hudbase, gui_id, ctrl)
    local children_keys = self:get_children_keys()
    for i = 1, #children_keys do
        local child = self.children[children_keys[i]]
        if self.write_nodes[child] then
            child:write_child(hudbase, gui_id, ctrl)
        end
    end
end

---@param child_to_play_state table<string, string>
function this:set_play_states(child_to_play_state)
    for child_name, play_state in pairs(child_to_play_state) do
        local child = self.children[child_name]
        child.play_state = play_state
        child:mark_write("play_state")
    end
end

---@param child_to_play_state table<string, string>
function this:reset_play_states(child_to_play_state)
    for child_name, _ in pairs(child_to_play_state) do
        local child = self.children[child_name]
        for property, _ in pairs(child:get_changed()) do
            child:reset(property)
            ---@diagnostic disable-next-line: no-unknown
            child[property] = nil
            child:mark_idle("play_state")
        end
    end
end

---@protected
---@param root_window via.gui.Control
---@return boolean
function this:_is_fade_state_finished(root_window)
    local play_state = self.hide and "DISABLE" or "DEFAULT"
    return root_window:get_PlayState() == play_state
end

---@protected
---@param ctrl via.gui.Control
---@return boolean
function this:_write(ctrl)
    play_object_defaults.check(ctrl)

    if self.hide and (not self.hud_id or (self.hud_id and not fade_manager.is_active())) then
        self:change_visibility(ctrl, not self.hide)
        if not self.hide_write then
            return false
        end
    end

    if self.offset then
        ctrl:set_Position(self.offset)
    end

    if self.scale then
        ctrl:set_Scale(self.scale)
    end

    if self.rot then
        ctrl:set_Rotation(self.rot)
    end

    if self.play_state then
        ctrl:set_PlayState(self.play_state)
    end

    if self.opacity and (not self.hud_id or (self.hud_id and not fade_manager.is_active())) then
        self:_set_opacity(ctrl, self.opacity)
    end

    if self.color_scale then
        local color = ctrl:get_ColorScale()
        self.color_scale.w = color.w
        ctrl:set_ColorScale(self.color_scale)
    end

    if self.segment then
        ctrl:set_Segment(self.segment)
    end

    return true
end

---@protected
---@param ctrl via.gui.Control
---@param val number
function this:_set_opacity(ctrl, val)
    local color = ctrl:get_ColorScale()
    color.w = val
    ctrl:set_ColorScale(color)
end

function this:clear()
    self:reset()
    for key in pairs(self.properties) do
        if self[key] then
            if self[key] == true then
                ---@diagnostic disable-next-line: no-unknown
                self[key] = false
            else
                ---@diagnostic disable-next-line: no-unknown
                self[key] = nil
            end
            self:mark_idle(key)
        end
    end
end

---@param other HudBase
function this:apply_other(other)
    for key in pairs(other.properties) do
        ---@diagnostic disable-next-line: no-unknown
        local value = other[key]
        if value and not self[key] then
            self:mark_write(key)
        elseif not value and self[key] then
            self:reset(key)
            self:mark_idle(key)
        end
        ---@diagnostic disable-next-line: no-unknown
        self[key] = value
    end
end

---@return HudBaseConfig
function this:get_current_config()
    if not hud then
        hud = require("HudController.hud")
    end

    local current_hud = hud.get_current() --[[@as HudProfileConfig]]
    local keys = { self.name_key }
    local parent = self.parent

    while parent do
        util_table.insert_front(keys, parent.name_key, "children")
        parent = parent.parent --[[@as HudBase]]
    end
    return util_table.get_by_key(current_hud.elements, table.concat(keys, "."))
end

function this.restore_all_force_invis()
    local all_hud = play_object.control.get_all_hud_control()
    for hud_id, ctrls in pairs(all_hud) do
        if not ace_map.hudid_to_can_hide[hud_id] then
            goto continue
        end

        for _, ctrl in pairs(ctrls) do
            local root_window = play_object.control.get_parent(ctrl, "RootWindow", true)
            if root_window then
                root_window:set_ForceInvisible(false)
            end
        end

        ::continue::
    end
end

---@param hud_id app.GUIHudDef.TYPE
---@param name_key string
---@return HudBaseConfig
function this.get_config(hud_id, name_key)
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
        hud_id = hud_id,
        name_key = name_key,
        key = -1,
        hud_type = mod.enum.hud_type.BASE,
        hud_sub_type = mod.enum.hud_sub_type.BASE,
    }
end

return this
