---@class (exact) DamageNumbersOffset : HudBase
---@field offset Vector3f?
---@field root DamageNumbers
---@field pos_cache table<via.gui.Control, Vector2f>
---@field box {x: integer, y: integer, w: integer, h: integer}?
---@field protected _get_real_text_size fun(text: via.gui.Text): number, number
---@field protected _clamp_offset fun(pos_x: number, pos_y: number, text_x: number, text_y: number): number, number

---@class (exact) DamageNumbersOffsetConfig
---@field enabled_box boolean
---@field box {x: integer, y: integer, w: integer, h: integer}

local this = {}
---@class DamageNumbersOffset
local cls = {}

---@param o_cls HudBase | HudChild
---@param args DamageNumbersConfig | DamageNumbersDamageStateConfig | DamageNumbersCriticalStateConfig
function this.wrap(o_cls, args)
    ---@cast o_cls DamageNumbersDamageState | DamageNumbers | DamageNumbersCriticalState
    o_cls.pos_cache = {}

    ---@diagnostic disable-next-line: no-unknown
    for k, v in pairs(cls) do
        if type(v) == "function" and not o_cls[k] then
            ---@diagnostic disable-next-line: no-unknown
            o_cls[k] = v
        end
    end

    if args.enabled_box then
        o_cls:set_box(args.box)
    end
end

---@param box {x: integer, y: integer, w: integer, h: integer}?
function cls:set_box(box)
    if box then
        self:mark_write("offset")
    else
        self:reset("offset")
        self:mark_idle("offset")

        local current_config = self:get_current_config()
        if current_config.enabled_offset then
            self.offset = Vector3f.new(current_config.offset.x, current_config.offset.y, 0)
        else
            self.offset = nil
        end
    end
    self.box = box
end

---@param hudbase app.GUI020020.DAMAGE_INFO
function cls:adjust_offset(hudbase)
    if self.box then
        self:screen_to_box(hudbase)
    elseif self.offset then
        self:set_offset_from_original_pos(hudbase)
    end
end

---@param hudbase app.GUI020020.DAMAGE_INFO
function cls:screen_to_box(hudbase)
    local pnl = self.root:get_state_value(hudbase, "<PanelWrap>k__BackingField") --[[@as via.gui.Control]]
    if not self.pos_cache[pnl] then
        self.pos_cache[pnl] = hudbase:get_field("<ScreenPos>k__BackingField") --[[@as Vector2f]]
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

---@param hudbase app.GUI020020.DAMAGE_INFO
function cls:set_offset_from_original_pos(hudbase)
    local pos = hudbase:get_field("<ScreenPos>k__BackingField") --[[@as Vector2f]]
    if pos.x ~= 0 or pos.y ~= 0 then
        ---@type number, number
        local x, y
        local self_config = self:get_current_config()
        local text_x, text_y = self._get_real_text_size(
            self.root:get_state_value(hudbase, "<TextDamage>k__BackingField") --[[@as via.gui.Text]]
        )
        x, y = self._clamp_offset(pos.x + self_config.offset.x, pos.y + self_config.offset.y, text_x, text_y)
        self.offset = Vector3f.new(x, y, 0)
    end
end

---@protected
---@param pos_x number
---@param pos_y number
---@param text_x number
---@param text_y number
---@return number, number
function cls._clamp_offset(pos_x, pos_y, text_x, text_y)
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
function cls._get_real_text_size(text)
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
