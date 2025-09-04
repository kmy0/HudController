---@class (exact) ItembarAllSlider : HudChild
---@field get_config fun(): ItembarAllSliderConfig
---@field appear_open boolean
---@field disable_right_stick boolean
---@field enable_mouse_control boolean
---@field control integer
---@field decide_key string
---@field slinger_visible boolean
---@field ammo_visible boolean
---@field parent Itembar
---@field input_ctrl ace.cGUIInputCtrl_FluentScrollGrid
---@field part app.GUI020006PartsAllSlider
---@field properties ItembarAllSliderProperties
---@field input_default ItembarAllSliderInputDefault
---@field protected _icon_first_update boolean
---@field reset fun(self: ItembarAllSlider, key: ItembarAllSliderWriteKey)
---@field mark_write fun(self: ItembarAllSlider, key: ItembarAllSliderProperty)
---@field mark_idle fun(self: ItembarAllSlider, key: ItembarAllSliderProperty)
---@field ctrl_getter fun(self: ItembarAllSlider, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?
---@field ctrl_writer (fun(self: ItembarAllSlider, ctrl: via.gui.Control): boolean)?
---@field children {
--- keys: HudChild,
--- text: CtrlChild,
--- background: CtrlChild,
--- right_stick_key: HudChild,
--- icon_state: HudChild,
--- text_num: HudChild,
--- text_pnl: HudChild,
--- cursor_state: HudChild,
--- ref_icon: HudChild,
--- color_scale: HudChild,
--- icon_color_scale: HudChild,
--- keys_state: HudChild,
--- appear_open: HudChild,
--- }

---@class (exact) ItembarAllSliderConfig : HudChildConfig
---@field appear_open boolean
---@field disable_right_stick boolean
---@field enable_mouse_control boolean
---@field control integer
---@field decide_key string
---@field slinger_visible boolean
---@field ammo_visible boolean
---@field children {
--- keys: HudChildConfig,
--- text: CtrlChildConfig,
--- background: CtrlChildConfig,
--- right_stick_key: HudChildConfig,
--- icon_state: HudChildConfig,
--- text_num: HudChildConfig,
--- text_pnl: HudChildConfig,
--- cursor_state: HudChildConfig,
--- ref_icon: HudChildConfig,
--- color_scale: HudChildConfig,
--- icon_color_scale: HudChildConfig,
--- keys_state: HudChildConfig,
--- appear_open: HudChildConfig,
--- }

---@class (exact) ItembarAllSliderChangedProperties : HudChildChangedProperties
---@field control boolean?
---@field decide_key boolean?
---@field appear_open boolean?

---@class (exact) ItembarAllSliderProperties : {[ItembarAllSliderProperty]: boolean}, HudChildProperties
---@field control integer
---@field decide_key string
---@field appear_open boolean

---@class (exact) ItembarAllSliderInputDefault
---@field input_bit integer
---@field buttons [app.GUIFunc.TYPE, app.GUIFunc.TYPE, app.GUIFunc.TYPE]

---@alias ItembarAllSliderProperty HudChildProperty | "control" | "decide_key" | "appear_open" | "disable_right_stick"
---@alias ItembarAllSliderWriteKey HudChildWriteKey | ItembarAllSliderProperty | "input"

---@class (exact) ItembarAllSliderControlArguments
---@field keys PlayObjectGetterFn[]
---@field text PlayObjectGetterFn[]
---@field background PlayObjectGetterFn[]
---@field right_stick_key PlayObjectGetterFn[]
---@field icons PlayObjectGetterFn[]
---@field icon_state PlayObjectGetterFn[]
---@field text_num PlayObjectGetterFn[]
---@field cursor_state PlayObjectGetterFn[]
---@field text_pnl PlayObjectGetterFn[]
---@field ref_icon PlayObjectGetterFn[]
---@field color_scale PlayObjectGetterFn[]

local ctrl_child = require("HudController.hud.def.ctrl_child")
local data = require("HudController.data")
local frame_cache = require("HudController.util.misc.frame_cache")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local play_object = require("HudController.hud.play_object")
local play_object_defaults = require("HudController.hud.defaults.play_object")
local s = require("HudController.util.ref.singletons")
local util_game = require("HudController.util.game")
local util_ref = require("HudController.util.ref")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local rl = game_data.reverse_lookup

---@class ItembarAllSlider
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- PNL_allSlider
---@type ItembarAllSliderControlArguments
local control_arguments = {
    keys = {
        {
            play_object.control.all,
            {},
            "PNL_keyInfo",
            true,
        },
    },
    text = {
        {
            play_object.child.get,
            {
                "PNL_ASL_Pos",
                "PNL_info",
            },
            "txt_item0",
            "via.gui.Text",
        },
    },
    background = {
        {
            play_object.control.get,
            {
                "PNL_itemAll",
                "PNL_itemAS_inout",
                "PNL_base",
            },
        },
    },
    icons = {
        {
            play_object.control.all,
            {
                "PNL_ASL_Pos",
                "FSG_ASList",
            },
            "Item",
            true,
        },
    },
    right_stick_key = {
        {
            play_object.control.get,
            {
                "PNL_keyInfo",
            },
        },
    },
    -- Item_X
    icon_state = {
        {
            play_object.control.get,
            {
                "PNL_itemAll",
                "PNL_itemAS_inout",
            },
        },
    },
    -- Item_X
    cursor_state = {
        {
            play_object.child.get,
            {
                "PNL_itemAll",
                "PNL_itemAS_inout",
                "PNL_cursor",
            },
            "tex_Active0",
            "via.gui.Texture",
        },
    },
    text_num = {
        {
            play_object.child.get,
            {
                "PNL_ASL_Pos",
                "PNL_info",
            },
            "txt_num0",
            "via.gui.Text",
        },
    },
    text_pnl = {
        {
            play_object.control.get,
            {
                "PNL_ASL_Pos",
                "PNL_info",
            },
        },
    },
    ref_icon = {
        {
            play_object.control.get,
            {
                "PNL_ASL_Pos",
                "FSG_ASList",
                "ITM_itemA00",
                "PNL_itemAll",
                "PNL_itemAS_inout",
                "PNL_icon",
                "PNL_equip0",
            },
        },
    },
    color_scale = {
        {
            play_object.control.get,
            {
                "PNL_ASL_Pos",
            },
        },
    },
}

local appear_open_states = {
    icon_state = "dummy",
    text_num = "dummy",
    text_pnl = "dummy",
    cursor_state = "dummy",
    ref_icon = "dummy",
    color_scale = "dummy",
    icon_color_scale = "dummy",
    keys_state = "dummy",
    appear_open = "dummy",
}

---@param ctrl via.gui.Control
local function get_icons(ctrl)
    return play_object.iter_args(ctrl, control_arguments.icons)
end

---@param args ItembarAllSliderConfig
---@param parent Itembar
---@param ctrl_getter fun(self: ItembarAllSlider, hudbase: app.GUIHudBase, gui_id: app.GUIID.ID, ctrl: via.gui.Control): via.gui.Control[] | via.gui.Control?
---@param ctrl_writer (fun(self: ItembarAllSlider, ctrl: via.gui.Control): boolean)?
---@param default_overwrite HudChildDefaultOverwrite?
---@param gui_ignore boolean?
function this:new(args, parent, ctrl_getter, ctrl_writer, default_overwrite, gui_ignore)
    local o = hud_child:new(args, parent, ctrl_getter, ctrl_writer, default_overwrite, gui_ignore)
    setmetatable(o, self)
    ---@cast o ItembarAllSlider

    o.properties = util_table.merge_t(o.properties, {
        control = true,
        decide_key = true,
        appear_open = true,
        disable_right_stick = true,
    })

    o._icon_first_update = true

    o.children.keys = hud_child:new(args.children.keys, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.keys)
    end)
    o.children.text = ctrl_child:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text)
    end)
    o.children.background = ctrl_child:new(args.children.background, o, function(s, hudbase, gui_id, ctrl)
        local icons = get_icons(ctrl)
        return play_object.iter_args(icons, control_arguments.background)
    end)
    o.children.right_stick_key = hud_child:new(args.children.right_stick_key, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.right_stick_key)
    end, nil, nil, true)

    o:_init_appear_open(args)

    if args.appear_open then
        o:set_appear_open(args.appear_open)
    end

    if args.decide_key ~= "option_disable" then
        o:set_decide_key(args.decide_key)
    else
        o.decide_key = "option_disable"
    end

    if args.disable_right_stick then
        o:set_disable_right_stick(args.disable_right_stick)
    end

    if args.control ~= -1 then
        o:set_control(args.control)
    else
        o.control = -1
    end

    o:set_ammo_visible(args.ammo_visible)
    o:set_slinger_visible(args.slinger_visible)
    o:set_enable_mouse_control(args.enable_mouse_control)
    return o
end

---@protected
---@param args ItembarAllSliderConfig
function this:_init_appear_open(args)
    -- makes expanded itembar visible when expanded itembar is hidden
    self.children.appear_open = hud_child:new(args.children.appear_open, self, function(s, hudbase, gui_id, ctrl)
        return ctrl
    end, function(s, ctrl)
        play_object_defaults.check(ctrl)

        if s.play_state and not self.parent:get_GUI020006():get_IsAllSliderMode() then
            ctrl:set_PlayState("HIDDEN")
        end

        return true
    end, nil, true)
    -- makes icons visible when expanded itembar is hidden
    self.children.icon_state = hud_child:new(args.children.icon_state, self, function(s, hudbase, gui_id, ctrl)
        local icons = get_icons(ctrl)
        return play_object.iter_args(icons, control_arguments.icon_state)
    end, function(s, ctrl)
        play_object_defaults.check(ctrl)

        if s.play_state and not self:is_visible() then
            ctrl:set_PlayState("HIDDEN")
        end

        return true
    end, nil, true)
    -- hides cursor select when expanded itembar is hidden
    self.children.cursor_state = hud_child:new(args.children.cursor_state, self, function(s, hudbase, gui_id, ctrl)
        local icons = get_icons(ctrl)
        return play_object.iter_args(icons, control_arguments.cursor_state)
    end, function(s, ctrl)
        play_object_defaults.check(ctrl)

        if
            s.play_state
            and not self.parent:get_GUI020006():get_IsAllSliderMode()
            and not self.parent:get_GUI020006():get_getIsItemSliderMode()
        then
            ctrl:set_ForceInvisible(true)
            s.hide = true
            return false
        else
            ctrl:set_ForceInvisible(false)
            s.hide = false
            return true
        end
    end, nil, true)
    -- forces item number to appear
    self.children.text_num = hud_child:new(args.children.text_num, self, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text_num)
    end, function(s, ctrl)
        play_object_defaults.check(ctrl)

        if s.play_state then
            ctrl:set_Visible(true)
        end
        return true
    end, nil, true)
    -- prevents text flicker when opening expanded itembar
    self.children.text_pnl = hud_child:new(args.children.text_pnl, self, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.text_pnl)
    end, function(s, ctrl)
        play_object_defaults.check(ctrl)

        ctrl:set_PlayState("HIDDEN")
        return true
    end, nil, true)
    -- hides ref equip icon thing, for whatever reason its visible and when icons get recreated it flickers
    self.children.ref_icon = hud_child:new(args.children.ref_icon, self, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.ref_icon)
    end, function(s, ctrl)
        play_object_defaults.check(ctrl)

        if s.play_state then
            ctrl:set_Visible(false)
        end
        return true
    end, nil, true)
    -- makes expanded itembar fully visible
    self.children.color_scale = hud_child:new(args.children.color_scale, self, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.color_scale)
    end, nil, nil, true)
    -- fades all icons except selected one when expanded itembar is hidden
    self.children.icon_color_scale = hud_child:new(
        args.children.icon_color_scale,
        self,
        function(s, hudbase, gui_id, ctrl)
            return get_icons(ctrl)
        end,
        function(s, ctrl)
            play_object_defaults.check(ctrl)

            if s.play_state then
                local all_slider = self:get_part()
                local current_item = all_slider:getCurrentItem()

                if current_item then
                    local current_sel = current_item:get__BaseItem()
                    local color = ctrl:get_ColorScale()

                    if ctrl ~= current_sel and not self.parent:get_GUI020006():get_IsAllSliderMode() then
                        color.x = 0.75
                        color.y = 0.75
                        color.z = 0.75
                    else
                        color.x = 1.0
                        color.y = 1.0
                        color.z = 1.0
                    end

                    s.color_scale = color
                    ctrl:set_ColorScale(color)
                end
            end

            return true
        end,
        nil,
        true
    )
    -- hide keys
    self.children.keys_state = hud_child:new(args.children.keys_state, self, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(ctrl, control_arguments.keys)
    end, function(s, ctrl)
        play_object_defaults.check(ctrl)

        if s.play_state and not self.parent:get_GUI020006():get_IsAllSliderMode() then
            ctrl:set_Visible(false)
            return false
        elseif not self.children.keys.hide then
            ctrl:set_Visible(true)
        end

        return true
    end, nil, true)
end

---@param appear_open boolean
function this:set_appear_open(appear_open)
    if appear_open then
        self:set_play_states(appear_open_states)
        self.children.color_scale:set_color_scale({ x = 1, y = 1, z = 1 })
        self.children.text_pnl:set_play_state("HIDDEN")
    else
        self:reset_play_states(appear_open_states)
        self.children.color_scale:set_color_scale()
        self.children.text_pnl:set_play_state()
    end
    self.appear_open = appear_open
end

---@param val integer
function this:set_control(val)
    if val ~= -1 then
        self:mark_write("control")
        self.control = val
    else
        self:reset("input")
        self.control = val
        self:mark_idle("control")
    end
end

---@param val string
function this:set_decide_key(val)
    if val ~= "option_disable" then
        self:mark_write("decide_key")
        self.decide_key = val
    else
        self:reset("input")
        self.decide_key = val
        self:mark_idle("decide_key")
    end
end

---@param disable_right_stick boolean
function this:set_disable_right_stick(disable_right_stick) --TODO: TEST
    if disable_right_stick then
        self.children.right_stick_key:set_hide(true)
        self:mark_write("disable_right_stick")
        self.disable_right_stick = disable_right_stick
    else
        self:reset("input")
        self.disable_right_stick = disable_right_stick
        self.children.right_stick_key:set_hide(false)
        self:mark_idle("disable_right_stick")
    end
end

---@param slinger_visible boolean
function this:set_slinger_visible(slinger_visible)
    self.slinger_visible = slinger_visible
end

---@param enable_mouse_control boolean
function this:set_enable_mouse_control(enable_mouse_control)
    self.enable_mouse_control = enable_mouse_control
end

---@param ammo_visible boolean
function this:set_ammo_visible(ammo_visible)
    self.ammo_visible = ammo_visible
end

---@param ctrl via.gui.Control
---@param key ItembarAllSliderWriteKey
function this:reset_ctrl(ctrl, key)
    if (not key or key == "input") and self.input_default then
        self:_set_input_bit(self.input_default.input_bit)
        self:_set_input_buttons(self.input_default.buttons)
    end
    ---@cast key HudChildProperty
    return hud_child.reset_ctrl(self, ctrl, key)
end

function this:update_all_icons()
    if self._icon_first_update then
        self.parent:get_GUI020006():initAllList()
        self._icon_first_update = false
    end

    if not self.parent:get_GUI020006():get_IsAllSliderMode() then
        local pouch = self.parent:get_GUI020006():get_ItemPouchDisp()
        local items = pouch:get_PouchItemCopy()
        local guiman = s.get("app.GUIManager")

        util_game.do_something(items, function(system_array, index, item)
            if item then
                guiman:addActiveItem(item:get_ItemId(), false)
            end
        end)

        local all_slider = self.parent:get_GUI020006():get__PartsAllSlider()
        local item_id = self.parent:get_GUI020006():get_SelectedItemId()
        local item = all_slider:getGridPartsFromItemId(item_id)

        if item and all_slider:getCurrentItem() ~= item then
            local new_sel = item:get__BaseItem()
            local int2 = util_ref.value_type("via.Int2")
            self:get_input_ctrl():getIndexFromItemCore(new_sel, int2)
            self:get_input_ctrl():requestSelectIndexCore(int2.x, int2.y)
            all_slider:setPanelActivePanelInfo(item)
        end
    end
end

---@return boolean
function this:is_visible()
    if not self.parent:get_GUI020006():get_IsAllSliderMode() then
        return false
    end

    local pnl = self.parent:get_GUI020006():get__PanelAllSlider()
    return pnl:get_PlayState() == "HIDDEN"
end

---@return ace.cGUIInputCtrl_FluentScrollGrid
function this:get_input_ctrl()
    if not self.input_ctrl and self:get_part() then
        self.input_ctrl = self:get_part():get__AllSliderCtrl()
    end
    return self.input_ctrl
end

---@return app.GUI020006PartsAllSlider
function this:get_part()
    if not self.part then
        self.part = self.parent:get_GUI020006():get__PartsAllSlider()
    end
    return self.part
end

---@protected
---@return ItembarAllSliderInputDefault?
function this:_get_input_default()
    local input = self:get_input_ctrl()

    if not input then
        return
    end

    local callback = input:get_Callback()
    local slots = callback._SlotBtns
    ---@type ItembarAllSliderInputDefault
    local ret = {
        input_bit = input._InputBit._Value,
        buttons = {},
    }

    for i = 0, 2 do
        table.insert(ret.buttons, i + 1, slots:get_Item(i))
    end

    return ret
end

---@protected
---@param bit integer
function this:_set_input_bit(bit)
    local input = self:get_input_ctrl()
    local bit_flag = input._InputBit
    bit_flag._Value = bit
    input._InputBit = bit_flag
end

---@protected
---@param buttons [app.GUIFunc.TYPE, app.GUIFunc.TYPE, app.GUIFunc.TYPE]
function this:_set_input_buttons(buttons)
    local input = self:get_input_ctrl()
    local callback = input:get_Callback()

    if not callback then
        return
    end

    local slots = callback._SlotBtns

    for i = 1, #buttons do
        local func = buttons[i]
        slots:set_Item(i - 1, func)
    end
end

---@protected
---@param ctrl via.gui.Control
---@return boolean
function this:_write(ctrl)
    if not self.input_default then
        ---@diagnostic disable-next-line: assign-type-mismatch
        self.input_default = self:_get_input_default()
    end

    if not self.input_default then
        return false
    end

    if self.appear_open then
        self:update_all_icons()
    end

    if self.control ~= -1 or self.disable_right_stick or self.decide_key ~= "option_disable" then
        local device = ace_enum.input_device[s.get("app.GUIManager"):get_LastInputDeviceIgnoreMouseMove()]
        local input = util_table.deep_copy(self.input_default)

        if device == "PAD" then
            local input_ctrl = self:get_input_ctrl()

            input.input_bit = 0
            if not self.disable_right_stick then
                input.input_bit = input.input_bit
                    | input_ctrl.INPUT_FLAG_UP_DOWN_RS
                    | input_ctrl.INPUT_FLAG_LEFT_RIGHT_RS
            end

            if self.control == 0 then
                input.input_bit = input.input_bit
                    | input_ctrl.INPUT_FLAG_UP_DOWN_RIGHT_KEY
                    | input_ctrl.INPUT_FLAG_LEFT_RIGHT_RIGHT_KEY
                input.buttons[2] = -1
                input.buttons[3] = -1
            elseif self.control == 1 then
                input.input_bit = input.input_bit
                    | input_ctrl.INPUT_FLAG_UP_DOWN_KEY
                    | input_ctrl.INPUT_FLAG_LEFT_RIGHT_KEY
                input.buttons[2] = -1
                input.buttons[3] = -1
            else
                input.input_bit = input.input_bit
                    | input_ctrl.INPUT_FLAG_UP_DOWN_KEY
                    | input_ctrl.INPUT_FLAG_LEFT_RIGHT_KEY
                    | input_ctrl.INPUT_FLAG_UP_DOWN_RIGHT_KEY
                    | input_ctrl.INPUT_FLAG_LEFT_RIGHT_RIGHT_KEY
                input.buttons[2] = -1
                input.buttons[3] = -1
            end

            if self.decide_key ~= "option_disable" then
                input.buttons[1] = rl(ace_enum.gui_func, self.decide_key)
            end
        end

        self:_set_input_bit(input.input_bit)
        self:_set_input_buttons(input.buttons)
    end

    return hud_base._write(self, ctrl)
end

---@return boolean
function this:any()
    return self.control ~= -1 or self.decide_key ~= "option_disable" or self.appear_open or hud_child.any(self)
end

---@return boolean
function this:any_gui()
    return util_table.any(self.properties, function(key, value)
        if not util_table.contains({ "control", "appear_open", "decide_key" }, key) and self[key] then
            return true
        end
        return false
    end)
end

---@return ItembarAllSliderChangedProperties
function this:get_changed()
    ---@type ItembarAllSliderChangedProperties
    local ret = {}
    for k, _ in pairs(self.properties) do
        if
            k == "control" and self[k] == -1
            or k == "decide_key" and self[k] == "option_disable"
            or k == "appear_open" and not self[k]
            or self[k] == nil
        then
            goto continue
        end

        ---@diagnostic disable-next-line: no-unknown
        ret[k] = self[k]
        ::continue::
    end
    return ret
end

---@return ItembarAllSliderConfig
function this.get_config()
    local base = hud_child.get_config("all_slider") --[[@as ItembarAllSliderConfig]]
    local children = base.children

    base.ammo_visible = false
    base.slinger_visible = false
    base.disable_right_stick = false
    base.control = -1
    base.decide_key = "option_disable"
    base.enable_mouse_control = false
    base.appear_open = false

    children.keys = { name_key = "keybind", hide = false }
    children.text = { name_key = "text", hide = false }
    children.background = { name_key = "background", hide = false }
    children.right_stick_key = { name_key = "__right_stick_key", hide = false }
    children.icon_state = { name_key = "__icon_state", play_state = "" }
    children.text_num = { name_key = "__text_num", play_state = "" }
    children.text_pnl = { name_key = "__text_pnl", play_state = "" }
    children.cursor_state = { name_key = "__cursor_state", play_state = "", hide = false }
    children.color_scale = { name_key = "__color_scale", color_scale = { x = 1, y = 1, z = 1 } }
    children.icon_color_scale = { name_key = "__icon_color_scale", color_scale = { x = 1, y = 1, z = 1 } }
    children.keys_state = { name_key = "__keys_state", play_state = "" }
    children.ref_icon = { name_key = "__ref_icon", play_state = "" }
    children.appear_open = { name_key = "__appear_open", play_state = "" }

    return base
end

get_icons = frame_cache.memoize(get_icons)

return this
