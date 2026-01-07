---@class (exact) ItembarSlider : HudChild
---@field get_config fun(): ItembarSliderConfig
---@field parent Itembar
---@field appear_open boolean
---@field move_next boolean
---@field input_ctrl ace.cGUIInputCtrl
---@field part app.GUI020006PartsSlider
---@field ctrl_getter fun(self: ItembarSlider, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?
---@field ctrl_writer (fun(self: ItembarSlider, ctrl: via.gui.Control): boolean)?
---@field children {
--- keys: HudChild,
--- text: CtrlChild,
--- background: CtrlChild,
--- frame: CtrlChild,
--- icon_frame: CtrlChild,
--- cursor: CtrlChild,
--- slider_part: HudChild,
--- slider_state: HudChild,
--- slider_animation: HudChild,
--- mantle_state: HudChild,
--- cursor_state: HudChild,
--- }

---@class (exact) ItembarSliderConfig : HudChildConfig
---@field appear_open boolean
---@field move_next boolean
---@field children {
--- keys: HudChildConfig,
--- text: CtrlChildConfig,
--- background: CtrlChildConfig,
--- frame: CtrlChildConfig,
--- icon_frame: CtrlChildConfig,
--- cursor: CtrlChildConfig,
--- slider_part: HudChildConfig,
--- slider_state: HudChildConfig,
--- slider_animation: HudChildConfig,
--- mantle_state: HudChildConfig,
--- cursor_state: HudChildConfig,
--- }

---@class (exact) ItembarSliderControlArguments
---@field keys PlayObjectGetterFn[]
---@field text PlayObjectGetterFn[]
---@field background PlayObjectGetterFn[]
---@field frame PlayObjectGetterFn[]
---@field icon_frame PlayObjectGetterFn[]
---@field cursor PlayObjectGetterFn[]
---@field slider_state PlayObjectGetterFn[]
---@field slider_animation PlayObjectGetterFn[]
---@field mantle_state PlayObjectGetterFn[]
---@field cursor_state PlayObjectGetterFn[]
---@field slider PlayObjectGetterFn[]

local ctrl_child = require("HudController.hud.def.ctrl_child")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object.init")
local play_object_defaults = require("HudController.hud.defaults.init").play_object
local util_table = require("HudController.util.misc.table")

---@class ItembarSlider
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_itemSlider
---@type ItembarSliderControlArguments
local control_arguments = {
    keys = {
        {
            play_object.control.all,
            {
                "PNL_ISActive",
            },
            "PNL_ref_Key",
        },
    },
    text = {
        {
            play_object.child.get,
            {
                "PNL_ISActive",
                "PNL_ISList",
            },
            "txt_item",
            "via.gui.Text",
        },
    },
    background = {
        {
            play_object.child.get,
            {
                "PNL_ISActive",
                "PNL_ISList",
            },
            "tex_base01",
            "via.gui.Texture",
        },
        {
            play_object.child.get,
            {
                "PNL_ISActive",
                "PNL_ISList",
            },
            "tex_base02",
            "via.gui.Texture",
        },
        {
            play_object.control.get,
            {
                "PNL_ISActive",
                "PNL_ISList",
                "PNL_blur1",
            },
        },
        {
            play_object.control.get,
            {
                "PNL_ISActive",
                "PNL_ISList",
                "PNL_blur0",
            },
        },
    },
    frame = {
        {
            play_object.child.get,
            {
                "PNL_ISActive",
                "PNL_ISList",
            },
            "mat_frame03",
            "via.gui.Material",
        },
        {
            play_object.child.get,
            {
                "PNL_ISActive",
                "PNL_ISList",
            },
            "mat_frame04",
            "via.gui.Material",
        },
    },
    icon_frame = {
        {
            play_object.child.get,
            {
                "PNL_ISActive",
                "PNL_ISList",
            },
            "mat_frame02",
            "via.gui.Material",
        },
        {
            play_object.child.get,
            {
                "PNL_ISActive",
                "PNL_ISList",
            },
            "tex_base00",
            "via.gui.Texture",
        },
    },
    cursor = {
        {
            play_object.child.get,
            {
                "PNL_ISActive",
                "PNL_ISList",
            },
            "tex_Active",
            "via.gui.Texture",
        },
        {
            play_object.child.get,
            {
                "PNL_ISActive",
                "PNL_ISList",
            },
            "tex_Active1",
            "via.gui.Texture",
        },
    },
    slider_state = {
        {
            play_object.control.get,
            {
                "PNL_ISActive",
            },
        },
    },
    slider_animation = {
        {
            play_object.control.get,
            {
                "PNL_ISActive",
                "PNL_ISList",
            },
        },
    },
    mantle_state = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_mantleSet",
                "PNL_mantleSetMove",
            },
        },
    },
    cursor_state = {
        {
            play_object.child.get,
            {
                "PNL_ISActive",
                "PNL_ISList",
            },
            "tex_Active",
            "via.gui.Texture",
        },
    },
    slider = {
        {
            play_object.control.get,
            {
                "PNL_Pat00",
                "PNL_itemSlider",
            },
        },
    },
}

local appear_open_states = {
    slider_state = "dummy",
    slider_animation = "dummy",
    mantle_state = "dummy",
    cursor_state = "dummy",
}

---@param args ItembarSliderConfig
---@param parent Itembar
function this:new(args, parent)
    local o = hud_child:new(args, parent, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.slider)
    end)
    setmetatable(o, self)
    ---@cast o ItembarSlider

    o.children.keys = hud_child:new(args.children.keys, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.keys)
    end)
    o.children.text = ctrl_child:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text)
    end)
    o.children.background = ctrl_child:new(
        args.children.background,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.background)
        end
    )
    o.children.frame = ctrl_child:new(args.children.frame, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.frame)
    end)
    o.children.icon_frame = ctrl_child:new(
        args.children.icon_frame,
        o,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.icon_frame)
        end
    )
    o.children.cursor = ctrl_child:new(args.children.cursor, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.cursor)
    end)
    o.children.slider_part = hud_child:new(
        args.children.slider_part,
        o,
        function(s, hudbase, gui_id, ctrl)
            return util_table.array_merge_t(
                { ctrl },
                play_object.iter_args(ctrl, control_arguments.slider_state),
                play_object.iter_args(ctrl, control_arguments.slider_animation)
            )
        end,
        function(s, ctrl)
            play_object_defaults:check(ctrl)

            if s.hide then
                if ctrl:get_PlayState() ~= "DEFAULT" then
                    if o.parent:get_GUI020006():get_IsAllSliderMode() then
                        ctrl:set_PlayState("HIDDEN")
                    else
                        ctrl:set_PlayState("DEFAULT")
                    end
                end

                parent:keep_mantle_in_place()
                parent:keep_akuma_in_place()
                return false
            end

            return true
        end
    )

    o:_init_slider_appear_open(args)

    if args.appear_open then
        o:set_appear_open(args.appear_open)
    end

    o:set_move_next(args.move_next)
    return o
end

---@protected
---@param args ItembarSliderConfig
function this:_init_slider_appear_open(args)
    -- show slider
    self.children.slider_state = hud_child:new(
        args.children.slider_state,
        self,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.slider_state)
        end,
        function(s, ctrl)
            play_object_defaults:check(ctrl)

            if s.play_state then
                ctrl:set_PlayState("SELECT")
            end

            self.parent:keep_akuma_in_place()
            return true
        end,
        nil,
        true
    )
    -- slide animation on input
    self.children.slider_animation = hud_child:new(
        args.children.slider_animation,
        self,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.slider_animation)
        end,
        function(s, ctrl)
            play_object_defaults:check(ctrl)

            if s.play_state then
                local state = ctrl:get_PlayState()
                if util_table.contains({ "FOCUS", "UNFOCUS", "DEFAULT" }, state) then
                    ctrl:set_PlayState("SELECT")
                elseif state == "FOCUS_PLUS_INPUT" then
                    ctrl:set_PlayState("PLUS_INPUT")
                elseif state == "FOCUS_MINUS_INPUT" then
                    ctrl:set_PlayState("MINUS_INPUT")
                end
            end

            return true
        end,
        nil,
        true
    )
    -- stops input animations for mantle
    self.children.mantle_state = hud_child:new(
        args.children.mantle_state,
        self,
        function(s, hudbase, gui_id, ctrl)
            ctrl = play_object.control.get_parent(ctrl, "PNL_Scale") --[[@as via.gui.Control]]
            return play_object.iter_args(ctrl, control_arguments.mantle_state)
        end,
        function(s, ctrl)
            play_object_defaults:check(ctrl)

            if s.play_state then
                if
                    util_table.contains(
                        { "FOCUS", "UNFOCUS", "FOCUS_PLUS_INPUT", "FOCUS_MINUS_INPUT", "DEFAULT" },
                        ctrl:get_PlayState()
                    )
                then
                    ctrl:set_PlayState("SELECT")
                end
            end

            return true
        end,
        nil,
        true
    )
    -- hides cursor select thing when appear open is enabled
    self.children.cursor_state = hud_child:new(
        args.children.cursor_state,
        self,
        function(s, hudbase, gui_id, ctrl)
            return play_object.iter_args(ctrl, control_arguments.cursor_state)
        end,
        function(s, ctrl)
            play_object_defaults:check(ctrl)

            if s.play_state and not self.parent:get_GUI020006():get_getIsItemSliderMode() then
                ctrl:set_ForceInvisible(true)
            else
                ctrl:set_ForceInvisible(false)
            end

            return true
        end,
        nil,
        true
    )
end

---@param move_next boolean
function this:set_move_next(move_next)
    self.move_next = move_next
end

---@param appear_open boolean
function this:set_appear_open(appear_open)
    if appear_open then
        self:set_play_states(appear_open_states)
    else
        self:reset_play_states(appear_open_states)
    end
    self.appear_open = appear_open
end

---@return ace.cGUIInputCtrl
function this:get_input_ctrl()
    if not self.input_ctrl then
        self.input_ctrl = self:get_part():get__SliderCtrl()
    end
    return self.input_ctrl
end

---@return app.GUI020006PartsSlider
function this:get_part()
    if not self.part then
        self.part = self.parent:get_GUI020006():get__PartsSlider()
    end
    return self.part
end

---@return ItembarSliderConfig
function this.get_config()
    local base = hud_child.get_config("slider") --[[@as ItembarSliderConfig]]
    local children = base.children

    base.appear_open = false
    base.move_next = false

    children.keys = { name_key = "keybind", hide = false }
    children.text = { name_key = "text", hide = false }
    children.background = { name_key = "background", hide = false }
    children.frame = { name_key = "frame", hide = false }
    children.icon_frame = { name_key = "icon_frame", hide = false }
    children.cursor = { name_key = "cursor", hide = false }
    children.slider_part = { name_key = "slider_part", hide = false }
    children.slider_state = { name_key = "__slider_state", play_state = "" }
    children.slider_animation = { name_key = "__slider_animation", play_state = "" }
    children.mantle_state = { name_key = "__mantle_state", play_state = "" }
    children.cursor_state = { name_key = "__cursor_state", play_state = "" }

    return base
end

return this
