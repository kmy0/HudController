---@class (exact) Itembar : HudBase
---@field get_config fun(): ItembarConfig
---@field start_expanded boolean
---@field mantle_always_visible boolean
---@field GUI020006 app.GUI020006
---@field children {
--- mantle: ItembarMantle,
--- slider: ItembarSlider,
--- all_slider: ItembarAllSlider,
--- akuma_bar: HudChild,
--- slider_part: HudChild,
--- }

---@class (exact) ItembarConfig : HudBaseConfig
---@field start_expanded boolean
---@field children {
--- mantle: ItembarMantleConfig,
--- slider: ItembarSliderConfig,
--- all_slider: ItembarAllSliderConfig,
--- akuma_bar: HudChildConfig,
--- slider_part: HudChildConfig,
--- }

local all_slider = require("HudController.hud.elements.itembar.all_slider")
local hud_base = require("HudController.hud.def.hud_base")
local hud_child = require("HudController.hud.def.hud_child")
local mantle = require("HudController.hud.elements.itembar.mantle")
local play_object = require("HudController.hud.play_object")
local play_object_defaults = require("HudController.hud.defaults.play_object")
local s = require("HudController.util.ref.singletons")
local slider = require("HudController.hud.elements.itembar.slider")
local util_table = require("HudController.util.misc.table")

local data = require("HudController.data")
local game_data = require("HudController.util.game.data")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class Itembar
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

-- ctrl = PNL_Scale
local ctrl_args = {
    slider = {
        {
            {
                "PNL_Pat00",
                "PNL_itemSlider",
            },
        },
    },
    akuma_bar = {
        {
            {
                "PNL_Pat00",
                "PNL_itemSlider",
                "PNL_ISActive",
                "PNL_COLLAB_00",
            },
        },
    },
    all_slider = {
        {
            {
                "PNL_Pat00",
                "PNL_allSlider",
            },
        },
    },
    mantle = {
        {
            {
                "PNL_Pat00",
                "PNL_mantleSet",
                "PNL_mantleSetMove",
                "PNL_mantleSetMode",
            },
        },
    },
}

---@param args ItembarConfig
---@param default_overwrite HudBaseDefaultOverwrite?
---@return Itembar
function this:new(args, default_overwrite)
    local o = hud_base.new(self, args, nil, default_overwrite)
    setmetatable(o, self)
    ---@cast o Itembar

    o.children.slider = slider:new(args.children.slider, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.slider)
    end)
    o.children.all_slider = all_slider:new(args.children.all_slider, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.all_slider)
    end)
    o.children.akuma_bar = hud_child:new(args.children.akuma_bar, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.akuma_bar)
    end)
    o.children.mantle = mantle:new(args.children.mantle, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.mantle)
    end)
    o.children.slider_part = hud_child:new(args.children.slider, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.slider)
    end, function(s, ctrl)
        play_object_defaults.check(ctrl)

        if s.hide then
            if self:get_GUI020006():get_IsAllSliderMode() or ctrl:get_PlayState() == "FADE_OUT" then
                ctrl:set_ForceInvisible(true)
                return false
            else
                ctrl:set_ForceInvisible(false)
            end
        end
        return true
    end, nil, true)

    if args.start_expanded then
        o:set_start_expanded(args.start_expanded)
    end

    return o
end

---@param start_expanded boolean
function this:set_start_expanded(start_expanded)
    self.start_expanded = start_expanded
    if self.start_expanded then
        self.children.slider_part:set_hide(true)
    else
        self.children.slider_part:set_hide(false)
    end
end

function this:keep_mantle_in_place()
    local mantle = self:get_mantle()
    if mantle then
        mantle:set_PlayState("DEFAULT")
    end
end

function this:keep_akuma_in_place()
    if self.children.akuma_bar.offset then
        ---@diagnostic disable-next-line: invisible
        for _, ctrl in pairs(self.children.akuma_bar._getter_cache) do
            ctrl:set_Position(self.children.akuma_bar.offset)
        end
    end
end

---@return via.gui.Control?
function this:get_mantle()
    local GUI020006 = self:get_GUI020006()
    local disp_ctrl = GUI020006._DisplayControl
    ---@diagnostic disable-next-line: param-type-mismatch
    local mantle_ctrl = util_table.normalize(self.children.mantle:ctrl_getter(GUI020006, nil, disp_ctrl._TargetControl))
    if not mantle_ctrl then
        return
    end
    ---@diagnostic disable-next-line: param-type-mismatch
    return util_table.normalize(self.children.mantle.children.visible_state:ctrl_getter(GUI020006, nil, mantle_ctrl))
end

---@return app.GUI020006
function this:get_GUI020006()
    if not self.GUI020006 then
        local accessor = s.get("app.GUIManager"):get_GUI020006Accessor()
        self.GUI020006 = accessor.GUIs:get_Item(0)
    end

    return self.GUI020006
end

---@return ItembarConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "SLIDER_ITEM"), "SLIDER_ITEM") --[[@as ItembarConfig]]
    local children = base.children
    base.hud_type = mod.enum.hud_type.ITEMBAR

    base.start_expanded = false

    children.mantle = mantle.get_config()
    children.slider = slider.get_config()
    children.all_slider = all_slider.get_config()
    children.akuma_bar = hud_child.get_config("akuma_bar")
    children.slider_part = { name_key = "__slider_part", hide = false }

    return base
end

return this
