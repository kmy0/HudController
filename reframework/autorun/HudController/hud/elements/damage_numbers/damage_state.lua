---@class (exact) DamageNumbersDamageState : HudChild
---@field get_config fun(name_key: string): DamageNumbersDamageStateConfig
---@field parent DamageNumbers
---@field root DamageNumbers
---@field pos_cache table<via.gui.Control, Vector2f>
---@field box {x: integer, y: integer, w: integer, h: integer}?
---@field protected _add_critical_state fun(config: HudChildConfig, NONE: boolean?, CRITICAL: boolean?, MINUS_CRITICAL: boolean?)
---@field children {
--- circle: HudChild,
--- horizontal_line: DamageNumbersDamageStateMaterial,
--- text: DamageNumbersDamageStateText,
--- wound: DamageNumbersDamageStateMaterial,
--- affinity: DamageNumbersDamageStateMaterial,
--- negative_affinity: DamageNumbersDamageStateMaterial,
--- shield: HudChild,
---}

---@class DamageNumbersDamageStateCls : CtrlChild
---@field children {
--- NONE: DamageNumbersCriticalState?,
--- CRITICAL: DamageNumbersCriticalState?,
--- MINUS_CRITICAL: DamageNumbersCriticalState?,
--- }?

---@class (exact) DamageNumbersDamageStateMaterial : DamageNumbersDamageStateCls, Material
---@class (exact) DamageNumbersDamageStateText : DamageNumbersDamageStateCls, Text

---@class (exact) DamageNumbersDamageStateConfig : HudChildConfig
---@field hud_sub_type HudSubType
---@field enabled_box boolean
---@field box {x: integer, y: integer, w: integer, h: integer}
---@field children {
--- circle: HudChildConfig,
--- horizontal_line: DamageNumbersDamageStateMaterialConfig,
--- text: DamageNumbersDamageStateTextConfig,
--- wound: DamageNumbersDamageStateMaterialConfig,
--- affinity: DamageNumbersDamageStateMaterialConfig,
--- negative_affinity: DamageNumbersDamageStateMaterialConfig,
--- shield: HudChildConfig,
--- }

---@class (exact) DamageNumbersDamageStateClsConfig : CtrlChildConfig
---@field children {
--- NONE: CtrlChildConfig?,
--- CRITICAL: CtrlChildConfig?,
--- MINUS_CRITICAL: CtrlChildConfig?,
--- }?

---@class (exact) DamageNumbersDamageStateMaterialConfig : MaterialConfig, DamageNumbersDamageStateClsConfig
---@class (exact) DamageNumbersDamageStateTextConfig : TextConfig, DamageNumbersDamageStateClsConfig

local critical_state = require("HudController.hud.elements.damage_numbers.critical_state")
local data = require("HudController.data")
local hud_child = require("HudController.hud.def.hud_child")
local material = require("HudController.hud.def.material")
local play_object = require("HudController.hud.play_object")
local text = require("HudController.hud.def.text")
local util_table = require("HudController.util.misc.table")

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
---@param parent DamageNumbers
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

        if
            args.name_key == "ALL"
            or ace_enum.damage_state[hudbase:get_field("<State>k__BackingField")] == args.name_key
        then
            s:adjust_offset(hudbase)
            return ctrl
        end
    end)
    setmetatable(o, self)
    ---@cast o DamageNumbersDamageState

    o.pos_cache = {}
    o.children.horizontal_line = material:new(args.children.horizontal_line, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.horizontal_line)
    end) --[[@as DamageNumbersDamageStateMaterial]]
    for _, state in pairs(ace_enum.critical_state) do
        o.children.horizontal_line.children[state] =
            critical_state:new(args.children.horizontal_line.children[state], o.children.horizontal_line, material)
    end

    o.children.text = text:new(args.children.text, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.text)
    end) --[[@as DamageNumbersDamageStateText]]
    for _, state in pairs(ace_enum.critical_state) do
        o.children.text.children[state] = critical_state:new(args.children.text.children[state], o.children.text, text)
    end

    o.children.wound = material:new(args.children.wound, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.wound)
    end) --[[@as DamageNumbersDamageStateMaterial]]
    for _, state in pairs(ace_enum.critical_state) do
        o.children.wound.children[state] =
            critical_state:new(args.children.wound.children[state], o.children.wound, material)
    end

    o.children.circle = hud_child:new(args.children.circle, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.control.get, ctrl, ctrl_args.circle)
    end)
    o.children.affinity = material:new(args.children.affinity, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.affinity)
    end) --[[@as DamageNumbersDamageStateMaterial]]
    o.children.negative_affinity = material:new(args.children.negative_affinity, o, function(s, hudbase, gui_id, ctrl)
        return play_object.iter_args(play_object.child.get, ctrl, ctrl_args.negative_affinity)
    end) --[[@as DamageNumbersDamageStateMaterial]]
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

    if args.enabled_box then
        o:set_box(args.box)
    end
    return o
end

---@param box {x: integer, y: integer, w: integer, h: integer}?
function this:set_box(box)
    if box then
        self:mark_write()
    else
        self:reset("offset")
        self:mark_idle()
    end
    self.box = box
end

---@param hudbase app.GUI020020.DAMAGE_INFO
function this:adjust_offset(hudbase)
    if self.box then
        self:screen_to_box(hudbase)
    elseif self.offset then
        self.parent.set_offset_from_original_pos(self, hudbase)
    end
end

---@param hudbase app.GUI020020.DAMAGE_INFO
function this:screen_to_box(hudbase)
    local pnl = hudbase:get_field("<ParentPanel>k__BackingField") --[[@as via.gui.Control]]

    if pnl:get_Visible() then
        if not self.pos_cache[pnl] then
            self.pos_cache[pnl] = hudbase:get_field("<ScreenPos>k__BackingField") --[[@as Vector2f]]
        end
    else
        self.pos_cache[pnl] = nil
    end

    if self.pos_cache[pnl] then
        local pos = self.pos_cache[pnl]
        local norm_x = pos.x / 1920
        local norm_y = pos.y / 1080

        local scaled_x = self.box.x + (norm_x * self.box.w)
        local scaled_y = self.box.y + (norm_y * self.box.h)
        self.offset = Vector3f.new(scaled_x, scaled_y, 0)
    end
end

---@param key HudChildWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    self.pos_cache = {}
    util_table.do_something(self.root:get_all_panels(), function(t, _, value)
        ---@diagnostic disable-next-line: param-type-mismatch
        local ctrl = self:ctrl_getter(nil, nil, value)

        if type(ctrl) ~= "table" then
            ctrl = { ctrl }
        end

        for _, c in pairs(ctrl) do
            self:reset_ctrl(c, key)
        end
    end)
end

---@protected
---@param config HudChildConfig
---@param NONE boolean?
---@param CRITICAL boolean?
---@param MINUS_CRITICAL boolean?
function this._add_critical_state(config, NONE, CRITICAL, MINUS_CRITICAL)
    local states = {
        NONE = NONE == nil and true or NONE,
        CRITICAL = CRITICAL == nil and true or CRITICAL,
        MINUS_CRITICAL = MINUS_CRITICAL == nil and true or MINUS_CRITICAL,
    }
    local _config = util_table.deep_copy(config)
    local children = config.children --[[@as table<string, HudChildConfig>]]
    for _, state in pairs(ace_enum.critical_state) do
        if states[state] then
            children[state] = util_table.deep_copy(_config)
            children[state].name_key = state
        end
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
        hud_sub_type = data.mod.enum.hud_sub_type.MATERIAL,
        enabled_color = false,
        color = 4294967295,
        hide = false,
        children = {},
    }
    this._add_critical_state(children.horizontal_line)

    children.text = {
        name_key = "text",
        hide = false,
        enabled_color = false,
        color = 4294967295,
        hide_glow = false,
        enabled_glow_color = false,
        glow_color = 4294967295,
        hud_sub_type = data.mod.enum.hud_sub_type.TEXT,
        children = {},
    }
    this._add_critical_state(children.text)

    children.wound = {
        name_key = "wound",
        hide = false,
        hud_sub_type = data.mod.enum.hud_sub_type.MATERIAL,
        enabled_color = false,
        color = 4294967295,
        children = {},
    }
    this._add_critical_state(children.wound)

    children.affinity = {
        name_key = "affinity",
        hud_sub_type = data.mod.enum.hud_sub_type.MATERIAL,
        enabled_color = false,
        color = 4294967295,
        hide = false,
    }
    children.negative_affinity = {
        name_key = "negative_affinity",
        hud_sub_type = data.mod.enum.hud_sub_type.MATERIAL,
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
