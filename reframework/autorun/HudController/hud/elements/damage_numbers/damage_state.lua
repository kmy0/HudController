---@class (exact) DamageNumbersDamageState : DamageNumbersOffset, HudChild
---@field get_config fun(name_key: string): DamageNumbersDamageStateConfig
---@field parent DamageNumbersCriticalState
---@field root DamageNumbers
---@field children {
--- circle: HudChild,
--- horizontal_line: CtrlChild,
--- text: Text,
--- wound: CtrlChild,
--- affinity: CtrlChild,
--- negative_affinity:  CtrlChild,
--- shield: HudChild,
---}

---@class (exact) DamageNumbersDamageStateConfig : DamageNumbersOffsetConfig, HudChildConfig
---@field children {
--- circle: HudChildConfig,
--- horizontal_line: CtrlChildConfig,
--- text: TextConfig,
--- wound: CtrlChildConfig,
--- affinity: CtrlChildConfig,
--- negative_affinity: CtrlChildConfig,
--- shield: HudChildConfig,
--- }

local ctrl_child = require("HudController.hud.def.ctrl_child")
local data = require("HudController.data")
local hud_child = require("HudController.hud.def.hud_child")
local numbers_offset = require("HudController.hud.elements.damage_numbers.numbers_offset")
local play_object = require("HudController.hud.play_object")
local text = require("HudController.hud.def.text")

local ace_enum = data.ace.enum
local mod = data.mod

---@class DamageNumbersDamageState
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_child })

-- ctrl = PNL_ALL
local ctrl_args = {
    circle = {
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_EffectCircle",
            },
        },
    },
    horizontal_line = {
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_EffectHolizontalLine",
                "PNL_Line",
            },
            "tex_Effect",
            "via.gui.Texture",
        },
    },
    text = {
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_TextWrap",
                "PNL_Text",
            },
            "txt_Damage",
            "via.gui.Text",
        },
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_TextWrap",
                "PNL_TextForDesign",
            },
            "txt_Damage",
            "via.gui.Text",
        },
    },
    wound = {
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_TextWrap",
                "PNL_TextForDesign",
            },
            "tex_BrokenSpot",
            "via.gui.Texture",
        },
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_TextWrap",
                "PNL_Text",
            },
            "tex_BrokenSpot",
            "via.gui.Texture",
        },
    },
    affinity = {
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_TextureAffinity",
            },
            "tex_Critical",
            "via.gui.Texture",
        },
    },
    negative_affinity = {
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_TextureNegativeAffinity",
            },
            "tex_MinusCritical",
            "via.gui.Texture",
        },
    },
    shield = {
        {
            {
                "PNL_Scale",
                "PNL_Pat00",
                "PNL_ShieldIcon",
            },
        },
    },
}

---@param args DamageNumbersDamageStateConfig
---@param parent DamageNumbersCriticalState
---@return DamageNumbersDamageState
function this:new(args, parent)
    local o = hud_child.new(self, args, parent, function(s, hudbase, gui_id, ctrl)
        ---@cast hudbase app.GUI020020.DAMAGE_INFO?
        ---@cast s DamageNumbersDamageState

        if
            not hudbase -- reset only
        then
            return ctrl
        end

        local state = s.root:get_state_value(hudbase, "<State>k__BackingField") --[[@as app.GUI020020.State]]
        if args.name_key == "ALL" or ace_enum.damage_state[state] == args.name_key then
            s:adjust_offset(hudbase)
            return ctrl
        end
    end)
    setmetatable(o, self)
    numbers_offset.wrap(o, args)
    ---@cast o DamageNumbersDamageState

    o.children.horizontal_line = ctrl_child:new(args.children.horizontal_line, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.horizontal_line)
    end)
    o.children.text = text:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.text)
    end)
    o.children.wound = ctrl_child:new(args.children.wound, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.wound)
    end)
    o.children.circle = hud_child:new(args.children.circle, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.circle)
    end)
    o.children.affinity = ctrl_child:new(args.children.affinity, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.affinity)
    end)
    o.children.negative_affinity = ctrl_child:new(args.children.negative_affinity, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.negative_affinity)
    end)
    o.children.shield = hud_child:new(args.children.shield, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.shield)
    end)

    ---@diagnostic disable-next-line: no-unknown
    for _, child in pairs(o.children) do
        child.reset = function(s, key)
            ---@diagnostic disable-next-line: param-type-mismatch
            o.reset(s, key)
        end
    end

    o.children.text.reset_ctrl = o._text_reset
    o.children.wound.reset_ctrl = o._text_reset

    return o
end

---@param obj via.gui.Text
---@param key TextWriteKey
function this:_text_reset(obj, key)
    ---@cast obj via.gui.Text
    text.reset_ctrl(self, obj, key)
    local p = play_object.control.get_parent(obj, "PNL_Text", true)
    if p then
        local state = p:get_PlayState()
        p:set_PlayState("")
        p:set_PlayState(state)
    end

    p = play_object.control.get_parent(obj, "PNL_TextForDesign", true)
    if p then
        p:set_PlayState("DEFAULT")
    end
end

---@param name_key string
---@return DamageNumbersDamageStateConfig
function this.get_config(name_key)
    local base = hud_child.get_config(name_key) --[[@as DamageNumbersDamageStateConfig]]
    local children = base.children

    base.hud_sub_type = mod.enum.hud_sub_type.DAMAGE_NUMBERS
    base.box = { x = 0, y = 0, w = 0, h = 0 }
    base.enabled_box = false

    children.circle = {
        name_key = "circle",
        hide = false,
    }
    children.horizontal_line = {
        name_key = "horizontal_line",
        hud_sub_type = data.mod.enum.hud_sub_type.CTRL_CHILD,
        enabled_color = false,
        color = 4294967295,
        hide = false,
    }
    children.text = {
        name_key = "text",
        hide = false,
        enabled_color = false,
        color = 4294967295,
        hide_glow = false,
        enabled_glow_color = false,
        glow_color = 4294967295,
        hud_sub_type = data.mod.enum.hud_sub_type.TEXT,
    }
    children.wound = {
        name_key = "wound",
        hide = false,
        hud_sub_type = data.mod.enum.hud_sub_type.CTRL_CHILD,
        enabled_color = false,
        color = 4294967295,
    }
    children.affinity = {
        name_key = "affinity",
        hud_sub_type = data.mod.enum.hud_sub_type.CTRL_CHILD,
        enabled_color = false,
        color = 4294967295,
        hide = false,
    }
    children.negative_affinity = {
        name_key = "negative_affinity",
        hud_sub_type = data.mod.enum.hud_sub_type.CTRL_CHILD,
        enabled_color = false,
        color = 4294967295,
        hide = false,
    }
    children.shield = {
        name_key = "shield",
        hide = false,
    }

    return base
end

return this
