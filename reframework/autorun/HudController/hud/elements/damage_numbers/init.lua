---@class (exact) DamageNumbers : HudBase
---@field get_config fun(): DamageNumbersConfig
---@field GUI020020 app.GUI020020?
---@field previous_state table<via.gui.Control, {damage_state: app.GUI020020.State, critical_state: app.GUI020020.CRITICAL_STATE}>
---@field protected _get_real_text_size fun(text: via.gui.Text): number, number
---@field protected _clamp_offset fun(pos_x: number, pos_y: number, text_x: number, text_y: number): number, number
---@field children {[string]: DamageNumbersDamageState}

---@class (exact) DamageNumbersConfig : HudBaseConfig
---@field children {[string]: DamageNumbersDamageStateConfig}

local damage_state = require("HudController.hud.elements.damage_numbers.damage_state")
local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local util_game = require("HudController.util.game")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class DamageNumbers
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args DamageNumbersConfig
---@return DamageNumbers
function this:new(args)
    local o = hud_base.new(self, args)
    setmetatable(o, self)
    ---@cast o DamageNumbers

    o.previous_state = {}

    for _, state in pairs(ace_enum.damage_state) do
        o.children[state] = damage_state:new(args.children[state], o)
    end

    o.children.ALL = damage_state:new(args.children.ALL, o)

    return o
end

---@return app.GUI020020
function this:get_GUI020020()
    if not self.GUI020020 then
        self.GUI020020 = util_game.get_component_any("app.GUI020020")
    end

    return self.GUI020020
end

---@return via.gui.Panel[]
function this:get_all_panels()
    local ret = {}
    local arr = self:get_GUI020020()._DamageInfo
    if arr then
        util_game.do_something(arr, function(system_array, index, value)
            table.insert(ret, value:get_field("<ParentPanel>k__BackingField") --[[@as via.gui.Panel]])
        end)
    end

    return ret
end

---@param active_only boolean?
---@return app.GUI020020.DAMAGE_INFO[]
function this:get_dmg(active_only)
    local ret = {}
    local arr = self:get_GUI020020()._DamageInfo
    if arr then
        util_game.do_something(arr, function(system_array, index, value)
            if not active_only or value:get_field("<DispTimer>k__BackingField") > 0 then
                table.insert(ret, value)
            end
        end)
    end

    return ret
end

---@param key HudBaseWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    util_table.do_something(self:get_all_panels(), function(_, _, value)
        self:reset_ctrl(value, key)
        util_table.do_something(self.children, function(_, _, child)
            if self.write_nodes[child] then
                ---@diagnostic disable-next-line: param-type-mismatch
                child:reset_child(nil, nil, value, key)
            end
        end)
    end)
end

---@param hudbase app.GUI020020.DAMAGE_INFO
---@param gui_id app.GUIID.ID
---@param ctrl via.gui.Control
function this:write(hudbase, gui_id, ctrl)
    self:_reset_on_state(hudbase, ctrl)
    if self.offset then
        self:set_offset_from_original_pos(hudbase)
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    hud_base.write(self, hudbase, gui_id, ctrl)
end

---@return DamageNumbersConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "DAMAGE_NUMBERS"), "DAMAGE_NUMBERS") --[[@as DamageNumbersConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.DAMAGE_NUMBERS

    for _, state in pairs(ace_enum.damage_state) do
        children[state] = damage_state.get_config(state)
    end
    children.ALL = damage_state.get_config("ALL")

    return base
end

---@param hudbase app.GUI020020.DAMAGE_INFO
---@param ctrl via.gui.Control
function this:_reset_on_state(hudbase, ctrl)
    local dmg_state = hudbase:get_field("<State>k__BackingField") --[[@as app.GUI020020.State]]
    local critical_state = hudbase:get_field("<criticalState>k__BackingField") --[[@as app.GUI020020.CRITICAL_STATE]]

    if not self.previous_state[ctrl] then
        self.previous_state[ctrl] = {
            damage_state = dmg_state,
            critical_state = critical_state,
        }
    elseif
        self.previous_state[ctrl] and self.previous_state[ctrl].damage_state ~= dmg_state
        or self.previous_state[ctrl].critical_state ~= critical_state
    then
        ---@diagnostic disable-next-line: param-type-mismatch
        self.children.ALL:reset_child(nil, nil, ctrl)
        ---@diagnostic disable-next-line: param-type-mismatch
        self.children[ace_enum.damage_state[self.previous_state[ctrl].damage_state]]:reset_child(nil, nil, ctrl)
        self.previous_state[ctrl].damage_state = dmg_state
        self.previous_state[ctrl].critical_state = critical_state
    end
end

---@param hudbase app.GUI020020.DAMAGE_INFO
function this:set_offset_from_original_pos(hudbase)
    local pos = hudbase:get_field("<ScreenPos>k__BackingField") --[[@as Vector2f]]
    if pos.x ~= 0 or pos.y ~= 0 then
        ---@type number, number
        local x, y
        local self_config = self:get_current_config()
        local text_x, text_y =
            this._get_real_text_size(hudbase:get_field("<TextDamage>k__BackingField") --[[@as via.gui.Text]])
        x, y = this._clamp_offset(pos.x + self_config.offset.x, pos.y + self_config.offset.y, text_x, text_y)
        self.offset = Vector3f.new(x, y, 0)
    end
end

---@protected
---@param pos_x number
---@param pos_y number
---@param text_x number
---@param text_y number
---@return number, number
function this._clamp_offset(pos_x, pos_y, text_x, text_y)
    local max_x = 1920
    local max_y = 1080

    if pos_x > max_x then
        pos_x = max_x - text_x / 2
    end

    if pos_y > max_y then
        pos_y = max_y - text_y / 2
    end

    if pos_x < 0 then
        pos_x = text_x / 2
    end

    if pos_y < 0 then
        pos_y = text_y / 2
    end

    return pos_x, pos_y
end

---@protected
---@param text via.gui.Text
---@return number, number
function this._get_real_text_size(text)
    local size = text:get_FontSize()
    local x, y = size.w, size.h
    local parent = text:get_Parent()

    while parent do
        local scale = parent:get_Scale()
        x = x * scale.x --[[@as number]]
        y = y * scale.y --[[@as number]]
        parent = parent:get_Parent()
    end

    return x, y
end

return this
